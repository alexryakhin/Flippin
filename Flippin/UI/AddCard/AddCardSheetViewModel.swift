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
class AddCardSheetViewModel: ObservableObject {
    @Published var nativeText: String = ""
    @Published var targetText: String = ""
    @Published var isTranslating: Bool = false
    @Published var selectedTags: Set<String> = []
    @Published var newTagText: String = ""
    @Published var notes: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let tagManager = TagManager()
    private var languageManager: LanguageManager?
    
    var userLanguage: Language {
        languageManager?.userLanguage ?? .english
    }
    
    var targetLanguage: Language {
        languageManager?.targetLanguage ?? .spanish
    }
    
    var availableTags: [String] {
        tagManager.availableTags
    }
    
    init() {
        setupTranslationPipeline()
    }
    
    func setLanguageManager(_ languageManager: LanguageManager) {
        self.languageManager = languageManager
    }
    
    private func setupTranslationPipeline() {
        $nativeText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
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
        targetText = ""
        
        do {
            let translated = try await TranslationService.translate(
                text: text,
                from: userLanguage.rawValue,
                to: targetLanguage.rawValue
            )
            targetText = translated
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
            frontLanguage: targetLanguage,
            backLanguage: userLanguage,
            notes: trimmedNotes.isEmpty ? "" : trimmedNotes,
            tags: selectedTags.isEmpty ? [] : Array(selectedTags),
            id: UUID().uuidString
        )
    }
    
    func cancel() {
        cancellables.removeAll()
    }
} 
