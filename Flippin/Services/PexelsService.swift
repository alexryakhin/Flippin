//
//  PexelsService.swift
//  Flippin
//
//  Created by AI Assistant on 1/15/25.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Pexels API Models

struct PexelsSearchResponse: Codable {
    let page: Int
    let perPage: Int
    let photos: [PexelsPhoto]
    let totalResults: Int
    let nextPage: String?
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}

struct PexelsPhoto: Codable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let src: PexelsPhotoSource
    let liked: Bool
    let alt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer, liked, alt
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src
    }
}

struct PexelsPhotoSource: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
    
    enum CodingKeys: String, CodingKey {
        case original
        case large2x = "large2x"
        case large, medium, small, portrait, landscape, tiny
    }
}

// MARK: - Pexels Service

final class PexelsService: ObservableObject {
    static let shared = PexelsService()
    
    @Published var isLoading = false
    @Published var searchResults: [PexelsPhoto] = []
    @Published var currentPage = 1
    @Published var hasMorePages = false
    
    private let baseURL = "https://api.pexels.com/v1"
    private let apiKey: String
    
    private init() {
        // Get API key from PrivateConstants
        self.apiKey = PrivateConstants.pexelsAPIKey
        
        if apiKey.isEmpty || apiKey == "YOUR_PEXELS_API_KEY_HERE" {
            print("⚠️ [PexelsService] PEXELS_API_KEY not configured in PrivateConstants.swift")
        }
    }
    
    // MARK: - Public Methods
    
    /// Search for photos using Pexels API
    func searchPhotos(query: String, page: Int = 1) async throws {
        guard !apiKey.isEmpty else {
            throw PexelsError.apiKeyNotConfigured
        }
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PexelsError.emptyQuery
        }
        
        await MainActor.run {
            isLoading = true
            if page == 1 {
                searchResults = []
            }
        }
        
        // Translate search query to English if user's locale is not English
        let searchQuery = await translateQueryToEnglishIfNeeded(query)
        
        let urlString = "\(baseURL)/search?query=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&page=\(page)&per_page=20&orientation=landscape"
        
        guard let url = URL(string: urlString) else {
            throw PexelsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 30.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PexelsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw PexelsError.invalidAPIKey
                } else if httpResponse.statusCode == 429 {
                    throw PexelsError.rateLimitExceeded
                } else {
                    throw PexelsError.apiError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            let searchResponse = try JSONDecoder().decode(PexelsSearchResponse.self, from: data)
            
            await MainActor.run {
                if page == 1 {
                    searchResults = searchResponse.photos
                } else {
                    searchResults.append(contentsOf: searchResponse.photos)
                }
                currentPage = page
                hasMorePages = searchResponse.nextPage != nil
                isLoading = false
            }
            
            print("🖼️ [PexelsService] Found \(searchResponse.photos.count) photos for query: '\(query)'")
            
        } catch {
            await MainActor.run {
                isLoading = false
            }
            
            if error is PexelsError {
                throw error
            } else {
                print("❌ [PexelsService] Search failed: \(error)")
                throw PexelsError.networkError(error.localizedDescription)
            }
        }
    }
    
    /// Load more photos for current search
    func loadMorePhotos(query: String) async throws {
        guard hasMorePages && !isLoading else { return }
        
        try await searchPhotos(query: query, page: currentPage + 1)
    }
    
    /// Clear search results
    func clearSearch() {
        searchResults = []
        currentPage = 1
        hasMorePages = false
    }
    
    /// Check if API key is configured
    var isConfigured: Bool {
        return !apiKey.isEmpty
    }
    
    // MARK: - Private Helpers
    
    /// Translates the search query to English if the user's language is not English
    private func translateQueryToEnglishIfNeeded(_ query: String) async -> String {
        let userLanguage = LanguageManager.shared.userLanguage
        
        // If user's language is English, no translation needed
        if userLanguage.voiceOverCode == "en" || userLanguage.voiceOverCode.hasPrefix("en-") {
            print("🖼️ [PexelsService] User language is English, using query as-is: '\(query)'")
            return query
        }
        
        // Try to translate to English
        do {
            let translatedQuery = try await TranslationService.translate(
                text: query,
                from: userLanguage.voiceOverCode,
                to: "en"
            )
            print("🖼️ [PexelsService] Translated query '\(query)' → '\(translatedQuery)'")
            return translatedQuery
        } catch {
            print("⚠️ [PexelsService] Translation failed, using original query: \(error)")
            // Fallback: use original query if translation fails
            return query
        }
    }
    
    // MARK: - Image Download and Storage
    
    /// Downloads an image from a URL and returns the UIImage
    func downloadImageFromUrl(_ urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw PexelsError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PexelsError.downloadFailed
        }
        
        guard let image = UIImage(data: data) else {
            throw PexelsError.invalidImageData
        }
        
        return image
    }
    
    /// Downloads and saves an image from a Pexels photo to local storage
    /// - Parameters:
    ///   - photo: The Pexels photo to download
    ///   - identifier: A unique identifier for the card (e.g., card text or UUID)
    /// - Returns: The relative filename of the saved image
    func downloadAndSaveImage(from photo: PexelsPhoto, for identifier: String) async throws -> String {
        print("📥 [PexelsService] Starting image download for identifier: '\(identifier)'")
        
        // Use large size for good quality without excessive file size
        let imageURL = photo.src.large
        
        guard let url = URL(string: imageURL) else {
            throw PexelsError.invalidURL
        }
        
        // Download image data from Pexels
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PexelsError.downloadFailed
        }
        
        // Create native image object
        guard let image = UIImage(data: data) else {
            throw PexelsError.invalidImageData
        }
        
        // Compress image to optimize storage (80% quality)
        guard let compressedData = image.jpegData(compressionQuality: 0.8) else {
            throw PexelsError.compressionFailed
        }
        
        // Generate unique filename: identifier_photoID.jpg
        let safeIdentifier = identifier
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .prefix(50) // Limit length to avoid filesystem issues
        let filename = "\(safeIdentifier)_\(photo.id).jpg"
        
        // Save to documents directory
        let documentsDir = try getDocumentsDirectory()
        let fileURL = documentsDir.appendingPathComponent(filename)
        
        try compressedData.write(to: fileURL)
        
        // Verify file was written
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
            print("✅ [PexelsService] Image saved successfully! File size: \(fileSize) bytes")
        }
        
        // Return only the relative filename (not full path)
        return filename
    }
    
    // MARK: - Image Retrieval
    
    /// Retrieves an image from local storage
    /// - Parameter path: The relative filename or absolute path to the image
    /// - Returns: A SwiftUI Image if found, nil otherwise
    func getImageFromLocalPath(_ path: String) -> Image? {
        print("🔍 [PexelsService] Attempting to load image from path: '\(path)'")
        
        // Construct full path from documents directory
        let fullPath: String
        if path.hasPrefix("/") {
            // Absolute path (legacy) - use as is
            fullPath = path
            print("📍 [PexelsService] Using absolute path (legacy): \(fullPath)")
        } else {
            // Relative path - construct from documents directory
            do {
                let documentsDir = try getDocumentsDirectory()
                fullPath = documentsDir.appendingPathComponent(path).path
                print("📍 [PexelsService] Constructed full path from relative: \(fullPath)")
            } catch {
                print("❌ [PexelsService] Failed to get documents directory: \(error)")
                return nil
            }
        }
        
        let url = URL(fileURLWithPath: fullPath)
        
        // Verify file exists
        guard FileManager.default.fileExists(atPath: fullPath) else {
            print("❌ [PexelsService] Image file does not exist at path: \(fullPath)")
            return nil
        }
        
        // Read cached image data
        guard let data = try? Data(contentsOf: url) else {
            print("❌ [PexelsService] Failed to read image data from path: \(fullPath)")
            return nil
        }
        
        print("📦 [PexelsService] Read \(data.count) bytes from file")
        
        // Create image from cached data
        guard let image = UIImage(data: data) else {
            print("❌ [PexelsService] Failed to create UIImage from data at path: \(fullPath)")
            return nil
        }
        
        print("✅ [PexelsService] Successfully loaded image from cache: \(fullPath)")
        return Image(uiImage: image)
    }
    
    /// Retrieves an image with fallback to web download if local file is missing
    /// - Parameters:
    ///   - localPath: The relative filename or absolute path to the local image
    ///   - webUrl: The web URL to download from if local file is missing
    /// - Returns: A tuple containing the image (if found) and optionally a new local path (if re-downloaded)
    func getImageWithFallback(localPath: String, webUrl: String?) async -> (image: Image?, newLocalPath: String?) {
        print("🔄 [PexelsService] Starting fallback image loading...")
        print("📍 [PexelsService] Local path: '\(localPath)'")
        print("🌐 [PexelsService] Web URL: '\(webUrl ?? "nil")'")
        
        // STEP 1: Try to load from local cache first
        if let localImage = getImageFromLocalPath(localPath) {
            print("✅ [PexelsService] Successfully loaded from local cache")
            return (localImage, nil) // Cache hit - no new path needed
        }
        
        print("⚠️ [PexelsService] Local cache miss, attempting web fallback...")
        
        // STEP 2: Cache miss - try to re-download from web URL
        guard let webUrl = webUrl, !webUrl.isEmpty else {
            print("❌ [PexelsService] No web URL available for fallback")
            return (nil, nil)
        }
        
        do {
            print("📥 [PexelsService] Re-downloading from web URL...")
            let reDownloadedImage = try await downloadImageFromUrl(webUrl)
            let image = Image(uiImage: reDownloadedImage)
            
            // Extract filename from the path
            let filename: String
            if localPath.hasPrefix("/") {
                // Absolute path - extract just the filename
                filename = URL(fileURLWithPath: localPath).lastPathComponent
            } else {
                // Relative path - use as is
                filename = localPath
            }
            
            // STEP 3: Try to restore the cache by saving locally
            if let imageData = reDownloadedImage.jpegData(compressionQuality: 0.8) {
                let documentsDir = try getDocumentsDirectory()
                let fileURL = documentsDir.appendingPathComponent(filename)
                
                try imageData.write(to: fileURL)
                print("💾 [PexelsService] Re-downloaded image saved to cache: \(fileURL.path)")
                
                // Verify the file was saved
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    print("✅ [PexelsService] Cache restored successfully!")
                    return (image, filename) // Return image and new path
                }
            }
            
            // Return image even if caching failed
            return (image, nil)
        } catch {
            print("❌ [PexelsService] Fallback download failed: \(error.localizedDescription)")
            return (nil, nil)
        }
    }
    
    // MARK: - Image Deletion
    
    /// Deletes an image from local storage
    /// - Parameter path: The relative filename or absolute path to the image
    func deleteImage(at path: String) throws {
        print("🗑️ [PexelsService] Attempting to delete image at path: '\(path)'")
        
        // Construct full path
        let fullPath: String
        if path.hasPrefix("/") {
            // Absolute path - use as is
            fullPath = path
        } else {
            // Relative path - construct from documents directory
            let documentsDir = try getDocumentsDirectory()
            fullPath = documentsDir.appendingPathComponent(path).path
        }
        
        // Verify file exists before attempting deletion
        guard FileManager.default.fileExists(atPath: fullPath) else {
            print("⚠️ [PexelsService] Image file doesn't exist, nothing to delete: \(fullPath)")
            return
        }
        
        // Delete the file
        try FileManager.default.removeItem(atPath: fullPath)
        print("✅ [PexelsService] Successfully deleted image: \(fullPath)")
    }
    
    // MARK: - Helper Methods
    
    /// Gets the documents directory URL
    private func getDocumentsDirectory() throws -> URL {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw PexelsError.documentsDirectoryNotFound
        }
        return documentsDir
    }
}

// MARK: - Pexels Errors

enum PexelsError: Error, LocalizedError {
    case apiKeyNotConfigured
    case emptyQuery
    case invalidURL
    case invalidResponse
    case invalidAPIKey
    case rateLimitExceeded
    case networkError(String)
    case apiError(String)
    case downloadFailed
    case invalidImageData
    case compressionFailed
    case documentsDirectoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "Pexels API key not configured"
        case .emptyQuery:
            return "Search query cannot be empty"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidAPIKey:
            return "Invalid API key"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .downloadFailed:
            return "Failed to download image"
        case .invalidImageData:
            return "Invalid image data received"
        case .compressionFailed:
            return "Failed to compress image"
        case .documentsDirectoryNotFound:
            return "Documents directory not found"
        }
    }
}

