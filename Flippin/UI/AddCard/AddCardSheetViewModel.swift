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
    @Published var selectedTags: Set<String> = []
    @Published var newTagText: String = ""
    @Published var notes: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let tagManager = TagManager.shared
    private let languageManager = LanguageManager.shared

    var availableTags: [String] {
        tagManager.availableTags
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
        } catch {
            print("Translation failed: \(error)")
            AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: error.localizedDescription)
        }

        isTranslating = false
    }

    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }

        if selectedTags.count < 5 {
            selectedTags.insert(trimmedTag)
            tagManager.addTag(trimmedTag)
        }
    }

    func removeTag(_ tag: String) {
        selectedTags.remove(tag)
    }

    func addNewTag() {
        addTag(newTagText)
        newTagText = ""
    }

    func createCard() -> CardItem? {
        let trimmedNative = nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNative.isEmpty && !trimmedTarget.isEmpty else {
            return nil
        }

        return CardItem(
            timestamp: Date(),
            frontText: trimmedTarget,
            backText: trimmedNative,
            frontLanguage: languageManager.targetLanguage,
            backLanguage: languageManager.userLanguage,
            notes: trimmedNotes.isEmpty ? "" : trimmedNotes,
            tags: selectedTags.isEmpty ? [] : Array(selectedTags),
            isFavorite: false,
            id: UUID().uuidString
        )
    }

    func cancel() {
        cancellables.removeAll()
    }
}
