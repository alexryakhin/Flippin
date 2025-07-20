//
//  EditCardSheetViewModel.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EditCardSheetViewModel: ObservableObject {
    @Published var nativeText: String = ""
    @Published var targetText: String = ""
    @Published var isTranslating: Bool = false
    @Published var newTagText: String = ""
    @Published var notes: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let tagManager = TagManager.shared
    private let languageManager = LanguageManager.shared

    @Published private(set) var card: CardItem

    var availableTags: [Tag] {
        tagManager.availableTags
    }
    
    init(card: CardItem) {
        self.card = card

        // Initialize with existing card data
        self.nativeText = card.backText.orEmpty
        self.targetText = card.frontText.orEmpty
        self.notes = card.notes.orEmpty

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
        } catch {
            print("Translation failed: \(error)")
            AnalyticsService.trackErrorEvent(.translationFailed, errorMessage: error.localizedDescription)
        }
        
        isTranslating = false
    }
    
    func addTag(_ tag: Tag) {
        if card.tagArray.count < 5 {
            card.addToTags(tag)
        }
        objectWillChange.send()
    }
    
    func removeTag(_ tag: Tag) {
        card.removeFromTags(tag)
        objectWillChange.send()
    }

    func updateCard() {
        let trimmedNative = nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNative.isEmpty && !trimmedTarget.isEmpty else {
            return
        }

        card.frontText = trimmedTarget
        card.backText = trimmedNative
        card.notes = trimmedNotes

        AnalyticsService.trackCardEvent(
            .cardEdited,
            cardLanguage: card.frontLanguage?.rawValue,
            hasTags: !card.tagNames.isEmpty,
            tagCount: card.tagNames.count
        )

        try? CoreDataService.shared.saveContext()
        objectWillChange.send()
    }
    
    func cancel() {
        cancellables.removeAll()
    }
} 
