//
//  AddCardSheetViewModel.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class AddCardSheetViewModel: ObservableObject {
    @Published var nativeText: String = ""
    @Published var targetText: String = ""
    @Published var isTranslating: Bool = false
    
    @AppStorage(UserDefaultsKey.userLanguage) private var userLanguageRaw: String = Language.english.rawValue
    @AppStorage(UserDefaultsKey.targetLanguage) private var targetLanguageRaw: String = Language.spanish.rawValue

    private var cancellables = Set<AnyCancellable>()
    
    var userLanguage: Language {
        Language(rawValue: userLanguageRaw) ?? .english
    }
    
    var targetLanguage: Language {
        Language(rawValue: targetLanguageRaw) ?? .spanish
    }
    
    init() {
        setupTranslationPipeline()
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
        }
        
        isTranslating = false
    }
    
    func saveCard(modelContext: ModelContext) -> Bool {
        let trimmedNative = nativeText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = targetText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNative.isEmpty && !trimmedTarget.isEmpty else {
            return false
        }
        
        let newItem = CardItem(
            frontText: trimmedTarget,
            backText: trimmedNative,
            frontLanguage: targetLanguage,
            backLanguage: userLanguage,
            notes: nil
        )
        
        modelContext.insert(newItem)
        return true
    }
    
    func cancel() {
        cancellables.removeAll()
    }
} 
