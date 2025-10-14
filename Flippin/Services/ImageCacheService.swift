//
//  ImageCacheService.swift
//  Flippin
//
//  Created by AI Assistant on 1/15/25.
//

import Foundation
import UIKit

final class ImageCacheService {
    static let shared = ImageCacheService()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let memoryCache = NSCache<NSString, UIImage>()
    
    private init() {
        // Create cache directory for images
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        memoryCache.countLimit = 100 // Maximum 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
    }
    
    // MARK: - Public Methods
    
    /// Download and cache image from URL
    func downloadAndCacheImage(from url: URL) async throws -> URL {
        let cacheKey = generateCacheKey(for: url)
        let cachedURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        // Check if already cached
        if fileManager.fileExists(atPath: cachedURL.path) {
            debugPrint("🖼️ [ImageCacheService] Image already cached: \(cacheKey)")
            return cachedURL
        }
        
        debugPrint("🖼️ [ImageCacheService] Downloading image from: \(url.absoluteString)")
        
        // Download image
        let (tempURL, response) = try await URLSession.shared.download(for: createImageRequest(for: url))
        
        // Verify response
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw ImageCacheError.downloadFailed("HTTP \(httpResponse.statusCode)")
            }
        }
        
        // Move to cache directory
        try fileManager.moveItem(at: tempURL, to: cachedURL)
        
        debugPrint("✅ [ImageCacheService] Image cached successfully: \(cacheKey)")
        return cachedURL
    }
    
    /// Get cached image URL if it exists
    func getCachedImageURL(for url: URL) -> URL? {
        let cacheKey = generateCacheKey(for: url)
        let cachedURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        guard fileManager.fileExists(atPath: cachedURL.path) else {
            return nil
        }
        
        return cachedURL
    }
    
    /// Load image from cache or download if needed
    func loadImage(from url: URL) async throws -> UIImage {
        // Check memory cache first
        let cacheKey = NSString(string: url.absoluteString)
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        let cachedURL: URL
        if let existingCachedURL = getCachedImageURL(for: url) {
            cachedURL = existingCachedURL
        } else {
            cachedURL = try await downloadAndCacheImage(from: url)
        }
        
        // Load image from disk
        guard let image = UIImage(contentsOfFile: cachedURL.path) else {
            throw ImageCacheError.invalidImage
        }
        
        // Store in memory cache
        memoryCache.setObject(image, forKey: cacheKey)
        
        return image
    }
    
    /// Clear all cached images
    func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for url in contents {
            try fileManager.removeItem(at: url)
        }
        
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        debugPrint("🗑️ [ImageCacheService] Cleared \(contents.count) cached images")
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
    
    /// Remove specific cached image
    func removeCachedImage(for url: URL) throws {
        let cacheKey = generateCacheKey(for: url)
        let cachedURL = cacheDirectory.appendingPathComponent(cacheKey)
        
        if fileManager.fileExists(atPath: cachedURL.path) {
            try fileManager.removeItem(at: cachedURL)
            
            // Remove from memory cache
            let memoryKey = NSString(string: url.absoluteString)
            memoryCache.removeObject(forKey: memoryKey)
            
            debugPrint("🗑️ [ImageCacheService] Removed cached image: \(cacheKey)")
        }
    }
    
    // MARK: - Private Methods
    
    private func generateCacheKey(for url: URL) -> String {
        // Use URL hash and last path component for uniqueness
        let urlHash = url.absoluteString.hash
        let filename = url.lastPathComponent
        let pathExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        return "\(abs(urlHash))_\(filename).\(pathExtension)"
    }
    
    private func createImageRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30.0
        return request
    }
}

// MARK: - Image Cache Errors

enum ImageCacheError: Error, LocalizedError {
    case downloadFailed(String)
    case invalidImage
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed(let message):
            return "Failed to download image: \(message)"
        case .invalidImage:
            return "Invalid image data"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}

