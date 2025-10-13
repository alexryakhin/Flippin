//
//  ImageSearchView.swift
//  Flippin
//
//  Created by AI Assistant on 1/15/25.
//

import SwiftUI

struct ImageSearchView: View {
    @StateObject private var pexelsService = PexelsService.shared
    private let imageCacheService = ImageCacheService.shared

    @State private var searchText = ""
    @State private var selectedPhoto: PexelsPhoto?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var isDownloading = false
    
    @Environment(\.dismiss) private var dismiss
    
    let cardIdentifier: String
    let onImageSelected: (_ imageUrl: String, _ localPath: String) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                // Content
                if pexelsService.searchResults.isEmpty && !pexelsService.isLoading {
                    emptyState
                } else {
                    imageGrid
                }
            }
            .navigationTitle(Loc.CardImages.ImageSearch.title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: Loc.CardImages.ImageSearch.searchPrompt
            )
            .onSubmit(of: .search) {
                performSearch()
            }
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    pexelsService.clearSearch()
                    selectedPhoto = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(Loc.CardImages.ImageSearch.cancel) {
                        dismiss()
                    }
                    .disabled(isDownloading)
                }
                
                if selectedPhoto != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            Task {
                                await selectImage()
                            }
                        } label: {
                            if isDownloading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Text(Loc.CardImages.ImageSearch.select)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(isDownloading)
                    }
                }
            }
        }
        .alert(Loc.CardImages.ImageSearch.Error.title, isPresented: $showingError) {
            Button(Loc.CardImages.ImageSearch.Error.ok) { }
        } message: {
            Text(errorMessage ?? Loc.CardImages.ImageSearch.Error.unknown)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(Loc.CardImages.ImageSearch.EmptyState.title)
                .font(.title2)
                .fontWeight(.medium)
            
            Text(Loc.CardImages.ImageSearch.EmptyState.subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Image Grid
    
    private var imageGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(pexelsService.searchResults) { photo in
                    ImageThumbnailView(
                        photo: photo,
                        isSelected: selectedPhoto?.id == photo.id
                    ) {
                        selectedPhoto = photo
                    }
                    .disabled(isDownloading)
                }
                
                // Load more button
                if pexelsService.hasMorePages && !pexelsService.isLoading {
                    Button(Loc.CardImages.ImageSearch.loadMore) {
                        loadMoreImages()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .gridCellColumns(3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .refreshable {
            if !searchText.isEmpty {
                await performSearchAsync()
            }
        }
    }
    
    // MARK: - Methods
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        Task {
            await performSearchAsync()
        }
    }
    
    private func performSearchAsync() async {
        do {
            try await pexelsService.searchPhotos(query: searchText)
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func loadMoreImages() {
        Task {
            do {
                try await pexelsService.loadMorePhotos(query: searchText)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func selectImage() async {
        guard let photo = selectedPhoto else { return }
        
        await MainActor.run {
            isDownloading = true
        }
        
        do {
            // Download and save the image using PexelsService
            let localPath = try await PexelsService.shared.downloadAndSaveImage(
                from: photo,
                for: cardIdentifier
            )
            
            await MainActor.run {
                isDownloading = false
                // Call the callback with both web URL (medium for fallback) and local path
                onImageSelected(photo.src.medium, localPath)
                dismiss()
            }
        } catch {
            await MainActor.run {
                isDownloading = false
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Image Thumbnail View

struct ImageThumbnailView: View {
    let photo: PexelsPhoto
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                // Selection overlay
                if isSelected {
                    // Checkmark overlay
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 28, height: 28)
                                )
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 3 : 0)
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            onTap()
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = URL(string: photo.src.medium) else { return }
        
        do {
            let loadedImage = try await ImageCacheService.shared.loadImage(from: url)
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ImageSearchView(cardIdentifier: "preview_card") { imageUrl, localPath in
        print("Selected image - URL: \(imageUrl), Local: \(localPath)")
    }
}

