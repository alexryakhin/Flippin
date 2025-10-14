//
//  TTSPlayer.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 3/9/25.
//

import Combine
import Foundation
import AVFoundation

final class TTSPlayer: NSObject, ObservableObject {

    static let shared = TTSPlayer()

    @Published var isPlaying = false

    private var player: AVAudioPlayer?
    private var speechSynthesizer: AVSpeechSynthesizer?
    private let speechifyService = SpeechifyService.shared
    private let purchaseService = PurchaseService.shared
    private let audioCacheService = AudioCacheService.shared
    private var cancellables: Set<AnyCancellable> = []

    private override init() {
        speechSynthesizer = AVSpeechSynthesizer()
        super.init()
        speechSynthesizer?.delegate = self
        setupBindings()
        
        // Clear corrupted Speechify cache files on startup
        Task {
            do {
                try audioCacheService.clearCorruptedSpeechifyCache()
            } catch {
                debugPrint("Failed to clear corrupted Speechify cache on startup: \(error)")
            }
        }
    }

    func play(_ text: String, language: Language) async throws {
        debugPrint("🎵 [TTSPlayer] Starting play() - Thread: \(Thread.isMainThread ? "Main" : "Background")")
        guard !text.isEmpty else { return }

        // Try Speechify first for premium users
        if purchaseService.hasPremiumAccess {
            debugPrint("🎵 [TTSPlayer] Premium user detected, trying Speechify first")
            
            // Check for cached Speechify audio first
            if let cachedAudioURL = audioCacheService.getCachedAudioURL(for: text, language: language, provider: .speechify) {
                debugPrint("🎵 [TTSPlayer] Found cached Speechify audio, playing immediately")
                try await playCachedAudio(from: cachedAudioURL)
                return
            }
            
            debugPrint("🎵 [TTSPlayer] No cached Speechify audio, generating new...")
            // Try to generate and cache Speechify audio with timeout protection
            do {
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask {
                        try await self.playSpeechifyTTS(text, language: language)
                    }
                    
                    group.addTask {
                        try await Task.sleep(nanoseconds: 20_000_000_000) // 20 second timeout
                        throw NSError(domain: "TTSPlayer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speechify request timeout"])
                    }
                    
                    try await group.next()
                    group.cancelAll()
                }
                debugPrint("🎵 [TTSPlayer] Speechify TTS completed successfully")
                return
            } catch {
                debugPrint("🎤 [TTSPlayer] Speechify TTS failed, falling back to Google TTS: \(error)")
            }
        }
        
        debugPrint("🎵 [TTSPlayer] Trying Google TTS fallback")
        // Check for cached Google TTS audio
        if let cachedAudioURL = audioCacheService.getCachedAudioURL(for: text, language: language, provider: .google) {
            debugPrint("🎵 [TTSPlayer] Found cached Google audio, playing immediately")
            try await playCachedAudio(from: cachedAudioURL)
            return
        }
        
        // Try Google TTS, fallback to offline if it fails
        do {
            debugPrint("🎵 [TTSPlayer] Generating new Google TTS audio...")
            try await playOnlineTTS(text, language: language)
        } catch {
            debugPrint("🎵 [TTSPlayer] Google TTS failed, falling back to offline TTS")
            // Fallback to offline TTS
            try await playOfflineTTS(text, language: language)
        }
    }
    
    /// Stops all audio playback
    func stop() {
        Task { @MainActor in
            // Stop AVAudioPlayer (for all audio types: cached, Google TTS, and Speechify)
            player?.stop()
            player = nil
            
            // Stop AVSpeechSynthesizer (for offline TTS)
            speechSynthesizer?.stopSpeaking(at: .immediate)
            
            // Update isPlaying state
            isPlaying = false
        }
    }
    
    #if DEBUG
    /// Debug method to test Speechify TTS without caching
    func debugTestSpeechify(_ text: String, language: Language) async throws {
        debugPrint("🔍 [TTSPlayer] DEBUG: Testing Speechify TTS directly...")
        debugPrint("🔍 [TTSPlayer] DEBUG: Thread: \(Thread.isMainThread ? "Main" : "Background")")
        
        do {
            let audioData = try await SpeechifyService.shared.synthesizeText(text, language: language)
            debugPrint("🔍 [TTSPlayer] DEBUG: Speechify synthesis successful, got \(audioData.count) bytes")
            
            // Save to temporary file first (this often fixes format issues)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("debug_speechify_\(UUID().uuidString).mp3")
            try audioData.write(to: tempURL)
            debugPrint("🔍 [TTSPlayer] DEBUG: Saved audio to temp file: \(tempURL.lastPathComponent)")
            
            // Play from file instead of data
            player = try AVAudioPlayer(contentsOf: tempURL)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            
            await MainActor.run {
                isPlaying = true
            }
            
            debugPrint("🔍 [TTSPlayer] DEBUG: Audio playback started from file")
            
            // Clean up temp file after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                try? FileManager.default.removeItem(at: tempURL)
            }
        } catch {
            debugPrint("🔍 [TTSPlayer] DEBUG: Speechify test failed: \(error)")
            throw error
        }
    }
    #endif
    
    /// Check if we can use Speechify for the given text without making an API call
    func canUseSpeechify(for text: String) -> Bool {
        guard purchaseService.hasPremiumAccess else { return false }
        return SpeechifyService.shared.canSynthesizeText(text)
    }
    
    /// Plays audio for a card's front or back text, using cached audio if available
    func playCardText(_ card: CardItem, isFront: Bool) async throws {
        let text = isFront ? card.frontText : card.backText
        let language = isFront ? card.frontLanguage : card.backLanguage
        let audioURL = isFront ? card.frontAudioURL : card.backAudioURL
        
        guard let text = text, let language = language, !text.isEmpty else {
            throw TTSError.invalidURL
        }
        
        // Check if we have cached audio URL
        if let audioURLString = audioURL, let url = URL(string: audioURLString) {
            try await playCachedAudio(from: url)
            return
        }
        
        // No cached audio - play and cache for future use
        try await playAndCache(text, language: language, card: card, isFront: isFront)
    }


    // MARK: - Cached Audio
    
    private func playCachedAudio(from url: URL) async throws {
        guard player?.isPlaying == false || player == nil else { 
            throw TTSError.alreadyPlaying 
        }

        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        
        // Set isPlaying to true before starting playback
        await MainActor.run {
            isPlaying = true
        }
        
        debugPrint("🎵 [TTSPlayer] Playing cached audio from file: \(url.lastPathComponent)")
        try await play(from: url)
    }
    
    /// Plays audio and caches it for future use
    private func playAndCache(_ text: String, language: Language, card: CardItem, isFront: Bool) async throws {
        // Play the audio (this will automatically cache it via playOnlineTTS)
        try await play(text, language: language)
        
        // Update the card with the cached audio URL
        if let cachedURL = audioCacheService.getCachedAudioURL(for: text, language: language) {
            if isFront {
                card.frontAudioURL = cachedURL.path
            } else {
                card.backAudioURL = cachedURL.path
            }
            
            // Save the updated card to Core Data
            try CoreDataService.shared.saveContext()
            debugPrint("🎵 [TTSPlayer] Updated card with cached audio URL: \(text.prefix(30))...")
        }
    }
    
    // MARK: - Speechify TTS
    
    private func playSpeechifyTTS(_ text: String, language: Language) async throws {
        debugPrint("🎤 [TTSPlayer] playSpeechifyTTS() started - Thread: \(Thread.isMainThread ? "Main" : "Background")")
        
        // Use AudioCacheService to get or create cached Speechify audio
        debugPrint("🎤 [TTSPlayer] Calling AudioCacheService.cacheAudio() for Speechify...")
        let cachedURL = try await audioCacheService.cacheAudio(for: text, language: language, provider: .speechify)
        debugPrint("🎤 [TTSPlayer] AudioCacheService.cacheAudio() completed, got URL: \(cachedURL.lastPathComponent)")
        
        guard player?.isPlaying == false || player == nil else { 
            debugPrint("🎤 [TTSPlayer] Player already playing, throwing error")
            throw TTSError.alreadyPlaying 
        }

        debugPrint("🎤 [TTSPlayer] Setting up audio session...")
        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        
        debugPrint("🎤 [TTSPlayer] Setting isPlaying to true...")
        // Set isPlaying to true before starting playback
        await MainActor.run {
            isPlaying = true
        }
        
        debugPrint("🎤 [TTSPlayer] Starting audio playback...")
        try await play(from: cachedURL)
        debugPrint("🎤 [TTSPlayer] Speechify audio playback completed")
    }
    
    // MARK: - Online TTS (Google Translate)
    
    private func playOnlineTTS(_ text: String, language: Language) async throws {
        // Use AudioCacheService to get or create cached Google TTS audio
        let cachedURL = try await audioCacheService.cacheAudio(for: text, language: language, provider: .google)
        
        guard player?.isPlaying == false || player == nil else { 
            throw TTSError.alreadyPlaying 
        }

        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        
        // Set isPlaying to true before starting playback
        await MainActor.run {
            isPlaying = true
        }
        
        try await play(from: cachedURL)
    }
    
    // MARK: - Offline TTS (AVSpeechSynthesizer)
    
    private func playOfflineTTS(_ text: String, language: Language) async throws {
        guard let synthesizer = speechSynthesizer else {
            throw TTSError.synthesizerNotAvailable
        }
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create speech utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = getVoiceForLanguage(language)
        utterance.rate = 0.3 // Adjustable speed (0.0 to 1.0)
        utterance.pitchMultiplier = 1.0 // Adjustable pitch
        utterance.volume = 0.8 // Adjustable volume
        
        // Setup audio session for offline TTS
        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        
        // Set isPlaying to true before starting speech
        await MainActor.run {
            isPlaying = true
        }
        
        // Play the speech
        synthesizer.speak(utterance)
    }

    private func setupBindings() {
        // No longer needed since SpeechifyService no longer manages playback state
        // TTSPlayer is now the single source of truth for audio playback
    }

    private func getVoiceForLanguage(_ language: Language) -> AVSpeechSynthesisVoice? {
        // Map our Language enum to iOS voice identifiers
        let voiceIdentifier = getVoiceIdentifier(for: language)
        
        // Try to get the specific voice first
        if let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            return voice
        }
        
        // Fallback to any available voice for the language
        return AVSpeechSynthesisVoice(language: getLanguageCode(for: language))
    }
    
    private func getVoiceIdentifier(for language: Language) -> String {
        switch language {
        case .english:
            return "com.apple.ttsbundle.siri_female_en-US_compact"
        case .spanish:
            return "com.apple.ttsbundle.Monica-compact"
        case .french:
            return "com.apple.ttsbundle.Aurelie-compact"
        case .german:
            return "com.apple.ttsbundle.Anna-compact"
        case .italian:
            return "com.apple.ttsbundle.Alice-compact"
        case .portuguese:
            return "com.apple.ttsbundle.Joana-compact"
        case .dutch:
            return "com.apple.ttsbundle.Xander-compact"
        case .swedish:
            return "com.apple.ttsbundle.Alva-compact"
        case .chinese:
            return "com.apple.ttsbundle.Ting-Ting-compact"
        case .japanese:
            return "com.apple.ttsbundle.Kyoko-compact"
        case .korean:
            return "com.apple.ttsbundle.Yuna-compact"
        case .vietnamese:
            return "com.apple.ttsbundle.Lan-compact"
        case .russian:
            return "com.apple.ttsbundle.Katya-compact"
        case .arabic:
            return "com.apple.ttsbundle.Tarik-compact"
        case .hindi:
            return "com.apple.ttsbundle.Lekha-compact"
        case .croatian:
            return "com.apple.ttsbundle.Petra-compact"
        case .ukranian:
            return "com.apple.ttsbundle.Lesya-compact"
        }
    }
    
    private func getLanguageCode(for language: Language) -> String {
        switch language {
        case .english:
            return "en-US"
        case .spanish:
            return "es-ES"
        case .french:
            return "fr-FR"
        case .german:
            return "de-DE"
        case .italian:
            return "it-IT"
        case .portuguese:
            return "pt-BR"
        case .dutch:
            return "nl-NL"
        case .swedish:
            return "sv-SE"
        case .chinese:
            return "zh-CN"
        case .japanese:
            return "ja-JP"
        case .korean:
            return "ko-KR"
        case .vietnamese:
            return "vi-VN"
        case .russian:
            return "ru-RU"
        case .arabic:
            return "ar-SA"
        case .hindi:
            return "hi-IN"
        case .croatian:
            return "hr-HR"
        case .ukranian:
            return "uk-UA"
        }
    }

    #if os(iOS)
    private func setupAudioSession() throws -> AVAudioSession {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
        try session.setActive(true)
        return session
    }
    #endif
    
    /// Creates a properly configured URLRequest for audio downloads
    private func createAudioRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        return request
    }


    @MainActor
    private func play(from url: URL) throws {
        debugPrint("🎵 [TTSPlayer] Playing audio from URL: \(url.lastPathComponent)")
        
        // Stop any currently playing audio
        player?.stop()
        player = nil
        
        // Set up audio session first
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            debugPrint("🎵 [TTSPlayer] Failed to set up audio session: \(error)")
        }
        
        // Create new player with better error handling
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            
            // Start playback
            let success = player?.play() ?? false
            if success {
                isPlaying = true
                debugPrint("🎵 [TTSPlayer] Audio playback started successfully")
            } else {
                debugPrint("🎵 [TTSPlayer] Failed to start audio playback")
                throw TTSError.playbackFailed
            }
        } catch {
            debugPrint("🎵 [TTSPlayer] Failed to create AVAudioPlayer: \(error)")
            // Try to provide more specific error information
            if let nsError = error as NSError? {
                debugPrint("🎵 [TTSPlayer] Error domain: \(nsError.domain), code: \(nsError.code)")
                if nsError.domain == "NSOSStatusErrorDomain" {
                    debugPrint("🎵 [TTSPlayer] Audio format may not be supported by AVAudioPlayer")
                }
            }
            throw TTSError.invalidAudioFormat
        }
    }
}

extension TTSPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}

extension TTSPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            isPlaying = false
        }
    }
}

// MARK: - TTS Errors

enum TTSError: Error, LocalizedError {
    case invalidURL
    case alreadyPlaying
    case synthesizerNotAvailable
    case networkError
    case invalidAudioFormat
    case playbackFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid TTS URL"
        case .alreadyPlaying:
            return "TTS is already playing"
        case .synthesizerNotAvailable:
            return "Speech synthesizer not available"
        case .networkError:
            return "Network error occurred"
        case .invalidAudioFormat:
            return "Invalid audio format"
        case .playbackFailed:
            return "Audio playback failed"
        }
    }
}
