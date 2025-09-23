//
//  SpeechifyTTSPreviewPlayer.swift
//  Flippin
//
//  Created by AI Assistant on 1/15/25.
//

import AVFoundation
import Combine

/// Dedicated player for Speechify voice previews using the same approach as the working implementation
final class SpeechifyTTSPreviewPlayer: NSObject, ObservableObject {
    static let shared = SpeechifyTTSPreviewPlayer()
    
    @Published var isPlaying = false
    
    private var player: AVAudioPlayer?
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private override init() {
        // Create cache directory for preview audio files
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("PreviewAudioCache")
        
        super.init()
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Download and play preview audio from URL (matches the working implementation)
    func downloadAndPlayPreview(from url: URL) async throws {
        print("🎵 [SpeechifyTTSPreviewPlayer] Getting preview from: \(url.absoluteString)")
        
        // Check if we already have this preview cached
        if let cachedURL = getCachedPreviewURL(for: url) {
            print("🎵 [SpeechifyTTSPreviewPlayer] Found cached preview, playing from cache")
            try await play(from: cachedURL)
            return
        }
        
        // Download and cache the audio file
        print("🎵 [SpeechifyTTSPreviewPlayer] Downloading new preview...")
        let cachedURL = try await downloadAndCachePreview(from: url)
        try await play(from: cachedURL)
    }
    
    /// Stop current preview playback
    func stop() async {
        print("🎵 [SpeechifyTTSPreviewPlayer] Stopping preview playback")
        
        await MainActor.run {
            player?.stop()
            player = nil
            isPlaying = false
        }
    }
    
    // MARK: - Private Methods
    
    /// Get cached preview URL if it exists
    private func getCachedPreviewURL(for url: URL) -> URL? {
        let cacheKey = generateCacheKey(for: url)
        let cachedURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        guard fileManager.fileExists(atPath: cachedURL.path) else {
            return nil
        }
        
        return cachedURL
    }
    
    /// Generate a cache key based on the URL
    private func generateCacheKey(for url: URL) -> String {
        // Use the last path component and hash of the full URL for uniqueness
        let urlHash = url.absoluteString.hash
        let filename = url.lastPathComponent
        return "\(abs(urlHash))_\(filename)"
    }
    
    /// Download and cache preview audio
    private func downloadAndCachePreview(from url: URL) async throws -> URL {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        
        do {
            let (tempURL, _) = try await URLSession.shared.download(for: request)
            
            // Generate cache file path
            let cacheKey = generateCacheKey(for: url)
            let cachedURL = cacheDirectory.appendingPathComponent(cacheKey)
            
            // Copy to cache directory
            try fileManager.copyItem(at: tempURL, to: cachedURL)
            print("✅ [SpeechifyTTSPreviewPlayer] Successfully cached preview audio to \(cachedURL.path)")
            
            return cachedURL
        } catch {
            print("❌ [SpeechifyTTSPreviewPlayer] Failed to download and cache preview: \(error)")
            throw PreviewPlayerError.downloadFailed
        }
    }
    
    /// Clear all cached preview files
    func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for url in contents {
            try fileManager.removeItem(at: url)
        }
        
        print("🗑️ [SpeechifyTTSPreviewPlayer] Cleared \(contents.count) cached preview files")
    }
    
    /// Get cache size in bytes
    func getCacheSize() -> Int64 {
        let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
        
        var totalSize: Int64 = 0
        for url in contents ?? [] {
            if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
               let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }
        
        return totalSize
    }
    
    @MainActor
    private func play(from url: URL) throws {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            
            // Enable rate modification
            player?.enableRate = true
            
            // Apply audio settings (use default rate and volume)
            player?.rate = 1.0
            player?.volume = 1.0
            
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            
            print("🎵 [SpeechifyTTSPreviewPlayer] Preview playback started successfully")
        } catch {
            isPlaying = false
            print("❌ [SpeechifyTTSPreviewPlayer] Cannot play audio file: \(error), url: \(url)")
            throw PreviewPlayerError.playbackFailed(error.localizedDescription)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension SpeechifyTTSPreviewPlayer: AVAudioPlayerDelegate {
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

// MARK: - Preview Player Errors

enum PreviewPlayerError: Error, LocalizedError {
    case downloadFailed
    case playbackFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Failed to download preview audio"
        case .playbackFailed(let message):
            return "Preview playback failed: \(message)"
        }
    }
}