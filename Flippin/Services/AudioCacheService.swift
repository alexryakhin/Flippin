//
//  AudioCacheService.swift
//  Flippin
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation
import AVFoundation

// MARK: - TTS Provider

enum TTSProvider: String, CaseIterable {
    case google = "google"
    case speechify = "speechify"
    case offline = "offline"
}

final class AudioCacheService {
    static let shared = AudioCacheService()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Create cache directory in Documents/AudioCache
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("AudioCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    /// Generates a cache key for the given text and language
    private func cacheKey(for text: String, language: Language, provider: TTSProvider = .google) -> String {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = normalizedText.hash
        return "\(provider.rawValue)_\(language.rawValue)_\(abs(hash)).mp3"
    }
    
    /// Creates a properly configured URLRequest for TTS audio downloads
    private func createTTSRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        return request
    }
    
    /// Gets the local file URL for cached audio
    private func cachedAudioURL(for text: String, language: Language, provider: TTSProvider = .google) -> URL {
        let fileName = cacheKey(for: text, language: language, provider: provider)
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    /// Checks if audio is already cached for the given text and language
    func isAudioCached(for text: String, language: Language, provider: TTSProvider = .google) -> Bool {
        let url = cachedAudioURL(for: text, language: language, provider: provider)
        return fileManager.fileExists(atPath: url.path)
    }
    
    /// Gets the cached audio URL if it exists and is valid
    func getCachedAudioURL(for text: String, language: Language, provider: TTSProvider = .google) -> URL? {
        let url = cachedAudioURL(for: text, language: language, provider: provider)
        
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        
        // For Speechify, validate the file can be played
        if provider == .speechify {
            do {
                let _ = try AVAudioPlayer(contentsOf: url)
                return url
            } catch {
                print("🎵 [AudioCacheService] Corrupted Speechify cache file detected: \(url.lastPathComponent)")
                // Remove the corrupted file
                try? fileManager.removeItem(at: url)
                return nil
            }
        }
        
        return url
    }
    
    /// Downloads and caches audio for the given text and language
    func cacheAudio(for text: String, language: Language, provider: TTSProvider = .google) async throws -> URL {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AudioCacheError.emptyText
        }
        
        // Check if already cached
        if let cachedURL = getCachedAudioURL(for: text, language: language, provider: provider) {
            return cachedURL
        }
        
        // Generate audio using the specified provider
        let audioURL = try await generateAndCacheAudio(for: text, language: language, provider: provider)
        return audioURL
    }
    
    /// Caches audio data directly (for Speechify and other providers that return Data)
    func cacheAudioData(_ audioData: Data, for text: String, language: Language, provider: TTSProvider) async throws -> URL {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AudioCacheError.emptyText
        }
        
        // Check if already cached
        if let cachedURL = getCachedAudioURL(for: text, language: language, provider: provider) {
            return cachedURL
        }
        
        let cacheURL = cachedAudioURL(for: text, language: language, provider: provider)
        
        // Save audio data to file
        try audioData.write(to: cacheURL)
        
        print("🎵 [AudioCacheService] Cached \(provider.rawValue) audio for '\(text.prefix(50))...' in \(language.rawValue)")
        return cacheURL
    }
    
    /// Generates audio using the specified provider and saves it to cache
    private func generateAndCacheAudio(for text: String, language: Language, provider: TTSProvider) async throws -> URL {
        switch provider {
        case .google:
            return try await generateGoogleTTSAudio(for: text, language: language)
        case .speechify:
            return try await generateSpeechifyTTSAudio(for: text, language: language)
        case .offline:
            throw AudioCacheError.unsupportedProvider
        }
    }
    
    /// Generates audio using Google TTS and saves it to cache
    private func generateGoogleTTSAudio(for text: String, language: Language) async throws -> URL {
        let cacheURL = cachedAudioURL(for: text, language: language, provider: .google)
        
        // Use Google TTS API
        let escapedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).orEmpty
        let urlString = "https://translate.google.com/translate_tts?ie=UTF-8&client=gtx&q=\(escapedText)&tl=\(language.voiceOverCode)"
        guard let url = URL(string: urlString) else {
            throw AudioCacheError.invalidURL
        }
        
        // Download the audio file with proper caching policy
        let request = createTTSRequest(for: url)
        let (tempURL, response) = try await URLSession.shared.download(for: request)
        
        // Verify the response
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw AudioCacheError.downloadFailed
            }
        }
        
        // Move to permanent cache location
        try fileManager.moveItem(at: tempURL, to: cacheURL)
        
        print("🎵 [AudioCacheService] Cached Google TTS audio for '\(text.prefix(50))...' in \(language.rawValue)")
        return cacheURL
    }
    
    /// Generates audio using Speechify TTS and saves it to cache
    private func generateSpeechifyTTSAudio(for text: String, language: Language) async throws -> URL {
        print("🎵 [AudioCacheService] generateSpeechifyTTSAudio() started - Thread: \(Thread.isMainThread ? "Main" : "Background")")
        let cacheURL = cachedAudioURL(for: text, language: language, provider: .speechify)
        print("🎵 [AudioCacheService] Cache URL: \(cacheURL.lastPathComponent)")
        
        // Check if we have enough characters before making API call
        guard SpeechifyService.shared.canSynthesizeText(text) else {
            print("🎵 [AudioCacheService] Not enough Speechify characters remaining")
            throw AudioCacheError.characterLimitExceeded
        }
        
        // Use SpeechifyService to generate audio data
        print("🎵 [AudioCacheService] Calling SpeechifyService.synthesizeText()...")
        let audioData = try await SpeechifyService.shared.synthesizeText(text, language: language)
        print("🎵 [AudioCacheService] SpeechifyService.synthesizeText() completed, got \(audioData.count) bytes")
        
        // Save audio data to cache
        print("🎵 [AudioCacheService] Writing audio data to cache...")
        try audioData.write(to: cacheURL)
        print("🎵 [AudioCacheService] Audio data written to cache successfully")
        
        print("🎵 [AudioCacheService] Cached Speechify TTS audio for '\(text.prefix(50))...' in \(language.rawValue)")
        return cacheURL
    }
    
    
    /// Clears all cached audio files
    func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
        print("🗑️ [AudioCacheService] Cleared audio cache")
    }
    
    /// Clears corrupted Speechify cache files
    func clearCorruptedSpeechifyCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        var removedCount = 0
        
        for url in contents {
            if url.lastPathComponent.hasPrefix("speechify_") {
                // Test if the file can be played
                do {
                    let _ = try AVAudioPlayer(contentsOf: url)
                    // If we get here, the file is valid
                } catch {
                    // File is corrupted, remove it
                    try fileManager.removeItem(at: url)
                    removedCount += 1
                    print("🗑️ [AudioCacheService] Removed corrupted Speechify file: \(url.lastPathComponent)")
                }
            }
        }
        
        print("🗑️ [AudioCacheService] Removed \(removedCount) corrupted Speechify cache files")
    }
    
    /// Gets the total size of the cache directory
    func getCacheSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let url as URL in enumerator {
            if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }
}

// MARK: - Audio Cache Errors

enum AudioCacheError: Error, LocalizedError {
    case emptyText
    case invalidURL
    case downloadFailed
    case unsupportedProvider
    case characterLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Text cannot be empty"
        case .invalidURL:
            return "Invalid TTS URL"
        case .downloadFailed:
            return "Failed to download audio"
        case .unsupportedProvider:
            return "Unsupported TTS provider"
        case .characterLimitExceeded:
            return "Character limit exceeded"
        }
    }
}
