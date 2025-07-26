//
//  TTSPlayer.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 3/9/25.
//

import Foundation
import AVFoundation

protocol TTSPlayerInterface {
    func play(_ text: String, language: Language) async throws
}

final class TTSPlayer: TTSPlayerInterface {

    static let shared: TTSPlayerInterface = TTSPlayer()

    private var player: AVAudioPlayer?
    private var speechSynthesizer: AVSpeechSynthesizer?

    private init() {
        speechSynthesizer = AVSpeechSynthesizer()
    }

    func play(_ text: String, language: Language) async throws {
        guard !text.isEmpty else { return }

        // Try online TTS first, fallback to offline if it fails
        do {
            try await playOnlineTTS(text, language: language)
        } catch {
            // Fallback to offline TTS
            try await playOfflineTTS(text, language: language)
        }
    }
    
    // MARK: - Online TTS (Google Translate)
    
    private func playOnlineTTS(_ text: String, language: Language) async throws {
        let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).orEmpty
        let urlString = "https://translate.google.com/translate_tts?ie=UTF-8&client=gtx&q=\(escapedText)&tl=\(language.voiceOverCode)"
        guard let url = URL(string: urlString) else { 
            throw TTSError.invalidURL 
        }

        guard player?.isPlaying == false || player == nil else { 
            throw TTSError.alreadyPlaying 
        }

        #if os(iOS)
        let _ = try setupAudioSession()
        #endif
        
        let temporaryDownloadURL = try await temporaryDownloadURL(for: url)
        try await play(from: temporaryDownloadURL)
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
        
        // Play the speech
        synthesizer.speak(utterance)
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

    private func temporaryDownloadURL(for url: URL) async throws -> URL {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        let (url, _) = try await URLSession.shared.download(for: request)
        return url
    }

    @MainActor
    private func play(from url: URL) throws {
        player = try AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
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
