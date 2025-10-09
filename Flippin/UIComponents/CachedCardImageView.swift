//
//  CachedCardImageView.swift
//  Flippin
//
//  Created by AI Assistant on 1/15/25.
//

import SwiftUI

/// A view that displays a card's image with intelligent caching and fallback mechanism.
/// Tries to load from local cache first, then falls back to web download if needed.
struct CachedCardImageView: View {
    let localPath: String?
    let webUrl: String?
    let maxHeight: CGFloat?
    let cornerRadius: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var loadingFailed = false
    
    init(
        localPath: String?,
        webUrl: String?,
        maxHeight: CGFloat? = 200,
        cornerRadius: CGFloat = 12
    ) {
        self.localPath = localPath
        self.webUrl = webUrl
        self.maxHeight = maxHeight
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let image = image {
                // Successfully loaded image
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: maxHeight)
                    .cornerRadius(cornerRadius)
                    .clipped()
            } else if isLoading {
                // Loading placeholder
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(maxHeight: maxHeight)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
                    .cornerRadius(cornerRadius)
            } else if loadingFailed {
                // Failed to load
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(maxHeight: maxHeight)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("Image unavailable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
                    .cornerRadius(cornerRadius)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let localPath = localPath else {
            await MainActor.run {
                isLoading = false
                loadingFailed = true
            }
            return
        }
        
        // Try to load with fallback
        let result = await PexelsService.shared.getImageWithFallback(
            localPath: localPath,
            webUrl: webUrl
        )
        
        await MainActor.run {
            if let loadedImage = result.image {
                self.image = loadedImage
                
                // If cache was restored, the path should be updated in the calling context
                // but we don't handle that here - the caller should handle it
            } else {
                loadingFailed = true
            }
            isLoading = false
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview with a non-existent image
        CachedCardImageView(
            localPath: "example_12345.jpg",
            webUrl: "https://images.pexels.com/photos/example.jpg"
        )
        .frame(height: 200)
        .padding()
        
        // Preview with nil paths
        CachedCardImageView(
            localPath: nil,
            webUrl: nil
        )
        .frame(height: 200)
        .padding()
    }
}

