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
    }

    func play(_ text: String, language: Language) async throws {
        guard !text.isEmpty else { return }

        // Check for cached audio first
        if let cachedAudioURL = audioCacheService.getCachedAudioURL(for: text, language: language) {
            try await playCachedAudio(from: cachedAudioURL)
            return
        }

        // Try Speechify first for premium users, then Google TTS, then offline
        if purchaseService.hasPremiumAccess {
            do {
                try await playSpeechifyTTS(text, language: language)
                return
            } catch {
                print("🎤 Speechify TTS failed, falling back to Google TTS: \(error)")
            }
        }
        
        // Try Google TTS, fallback to offline if it fails
        do {
            try await playOnlineTTS(text, language: language)
        } catch {
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

    func previewSpeechifyVoice(_ voice: SpeechifyVoice) async throws {
        // Use the actual preview audio if available
        if let previewAudioURL = voice.bestPreviewAudioURL,
           let url = URL(string: previewAudioURL) {
            // Download the remote audio file first, then play it
            let request = createAudioRequest(for: url)
            let (tempURL, response) = try await URLSession.shared.download(for: request)
            
            // Verify the response
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    throw TTSError.networkError
                }
            }
            
            try await play(from: tempURL)
        } else {
            // Fallback to text-to-speech if no preview audio is available
            try await playSpeechifyTTS(
                "Hello, world! This is a preview of your voice.",
                language: .english
            )
        }
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
        
        try await play(from: url)
        print("🎵 [TTSPlayer] Playing cached audio from \(url.lastPathComponent)")
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
            print("🎵 [TTSPlayer] Updated card with cached audio URL: \(text.prefix(30))...")
        }
    }
    
    // MARK: - Speechify TTS
    
    private func playSpeechifyTTS(_ text: String, language: Language) async throws {
        // Get audio data from Speechify
        let audioData = try await speechifyService.synthesizeText(text, language: language)
        
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
        
        // Create and play audio from data
        player = try AVAudioPlayer(data: audioData)
        player?.delegate = self
        player?.prepareToPlay()
        player?.play()
        
        print("🎤 [TTSPlayer] Playing Speechify audio")
    }
    
    // MARK: - Online TTS (Google Translate)
    
    private func playOnlineTTS(_ text: String, language: Language) async throws {
        // Use AudioCacheService to get or create cached audio
        let cachedURL = try await audioCacheService.cacheAudio(for: text, language: language)
        
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
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        player?.delegate = self
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
        }
    }
}
