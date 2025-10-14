//
//  AddCardSheetViewModel.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AddCardSheetViewModel: ObservableObject {
    @Published var nativeText: String = ""
    @Published var targetText: String = ""
    @Published var isTranslating: Bool = false
    @Published var selectedTags: Set<Tag> = []
    @Published var newTagText: String = ""
    @Published var notes: String = ""
    @Published var showingLimitAlert = false
    @Published var limitAlertMessage = ""
    @Published var selectedImageUrl: String?
    @Published var selectedImageCacheURL: String?

    private var cancellables = Set<AnyCancellable>()
    private let tagManager = TagManager.shared
    private let languageManager = LanguageManager.shared
    private let cardsProvider = CardsProvider.shared

    var availableTags: [Tag] {
        tagManager.availableTags
    }
    
    var remainingCards: Int {
        cardsProvider.remainingCards
    }
    
    var hasUnlimitedCards: Bool {
        cardsProvider.hasUnlimitedCards
    }

    init() {
        setupTranslationPipeline()
    }

    private func setupTranslationPipeline() {
        $nativeText
            .dropFirst(2)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .removeDuplicates()
            .sink { [weak self] text in
                Task { @MainActor in
                    await self?.translateText(text)
                }
            }
            .store(in: &cancellables)
    }

    private func translateText(_ text: String) async {
        guard !isTranslating else { return }

        isTranslating = true

        do {
            let translated = try await TranslationService.translate(
                text: text,
                from: languageManager.userLanguage.rawValue,
                to: languageManager.targetLanguage.rawValue
            )
            targetText = translated
            
            // Haptic feedback for translation completion
            HapticService.shared.translationCompleted()
            
            // Track successful translation
            AnalyticsService.trackEvent(.translationCompleted)
        } catch {
            debugPrint("Translation failed: \(error)")
            AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: error.localizedDescription)
        }

        isTranslating = false
    }

    func addTag(_ tag: Tag) {
        if selectedTags.count < 5 {
            selectedTags.insert(tag)
        }
    }

    func removeTag(_ tag: Tag) {
        selectedTags.remove(tag)
    }

    func createCard() {
        let trimmedNative = nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNative.isEmpty && !trimmedTarget.isEmpty else {
            return
        }

        do {
            try cardsProvider.addCard(
                frontText: trimmedTarget,
                backText: trimmedNative,
                notes: trimmedNotes.isEmpty ? "" : trimmedNotes,
                tags: selectedTags.map(\.name.orEmpty),
                imageUrl: selectedImageUrl,
                imageCacheURL: selectedImageCacheURL
            )
        } catch let error as CardLimitError {
            limitAlertMessage = error.localizedDescription
            showingLimitAlert = true
        } catch {
            limitAlertMessage = Loc.Errors.failedToCreateCard(error.localizedDescription)
            showingLimitAlert = true
        }
    }

    func setSelectedImage(imageUrl: String, localPath: String) {
        selectedImageUrl = imageUrl
        selectedImageCacheURL = localPath
    }
    
    func clearSelectedImage() {
        // Delete the cached image file if it exists
        if let imageCacheURL = selectedImageCacheURL {
            try? PexelsService.shared.deleteImage(at: imageCacheURL)
        }
        selectedImageUrl = nil
        selectedImageCacheURL = nil
    }
    
    func cancel() {
        cancellables.removeAll()
    }
}
