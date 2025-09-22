//
//  AudioCacheService.swift
//  Flippin
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation
import AVFoundation

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
    private func cacheKey(for text: String, language: Language) -> String {
        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = normalizedText.hash
        return "\(language.rawValue)_\(abs(hash)).mp3"
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
    private func cachedAudioURL(for text: String, language: Language) -> URL {
        let fileName = cacheKey(for: text, language: language)
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    /// Checks if audio is already cached for the given text and language
    func isAudioCached(for text: String, language: Language) -> Bool {
        let url = cachedAudioURL(for: text, language: language)
        return fileManager.fileExists(atPath: url.path)
    }
    
    /// Gets the cached audio URL if it exists
    func getCachedAudioURL(for text: String, language: Language) -> URL? {
        let url = cachedAudioURL(for: text, language: language)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
    
    /// Downloads and caches audio for the given text and language
    func cacheAudio(for text: String, language: Language) async throws -> URL {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AudioCacheError.emptyText
        }
        
        // Check if already cached
        if let cachedURL = getCachedAudioURL(for: text, language: language) {
            return cachedURL
        }
        
        // Generate audio using Google TTS (same as TTSPlayer)
        let audioURL = try await generateAndCacheAudio(for: text, language: language)
        return audioURL
    }
    
    /// Generates audio using Google TTS and saves it to cache
    private func generateAndCacheAudio(for text: String, language: Language) async throws -> URL {
        let cacheURL = cachedAudioURL(for: text, language: language)
        
        // Use Google TTS API (same as TTSPlayer)
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
        
        print("🎵 [AudioCacheService] Cached audio for '\(text.prefix(50))...' in \(language.rawValue)")
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
    
    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Text cannot be empty"
        case .invalidURL:
            return "Invalid TTS URL"
        case .downloadFailed:
            return "Failed to download audio"
        }
    }
}
