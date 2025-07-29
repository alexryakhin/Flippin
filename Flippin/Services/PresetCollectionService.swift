//
//  PresetCollectionService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import Combine

struct PresetCollection: Identifiable {
    let id: Int
    let name: String
    let description: String
    let category: PresetModel.Category
    let systemImageName: String
    let cards: [PresetCard]

    var cardCount: Int {
        cards.count
    }
}

struct PresetCard {
    let frontText: String
    let backText: String
    let notes: String
    let tags: [String]
}

@MainActor
final class PresetCollectionService: ObservableObject {

    static let shared = PresetCollectionService()
    
    @Published var collections: [PresetCollection] = []

    private let languageManager = LanguageManager.shared
    private var cancellables: Set<AnyCancellable> = []

    private init() {
        loadCollections()
        setupBindings()
    }

    func getFeaturedCollections() -> [PresetCollection] {
        Array(collections.prefix(4))
    }

    private func setupBindings() {
        languageManager.$userLanguage.removeDuplicates()
            .combineLatest(languageManager.$targetLanguage.removeDuplicates())
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadCollections()
            }
            .store(in: &cancellables)
    }

    private func loadPresetCollection(for language: Language) throws -> PresetModel.Data {
        let fileName = "presets_\(language.rawValue).json"
        return try Bundle.main.decode(fileName)
    }

    private func loadCollections() {
        do {
            let userLanguageData = try loadPresetCollection(for: languageManager.userLanguage)
            let targetLanguageData = try loadPresetCollection(for: languageManager.targetLanguage)

            guard targetLanguageData.presets.count == userLanguageData.presets.count else {
                throw AppError.invalidJSON
            }

            collections = zip(userLanguageData.presets, targetLanguageData.presets).map { userData, targetData in
                PresetCollection(
                    id: userData.id,
                    name: userData.name,
                    description: userData.description,
                    category: userData.category,
                    systemImageName: userData.systemImageName,
                    cards: zip(userData.phrases, targetData.phrases).map { userPhrases, targetPhrases in
                        PresetCard(
                            frontText: targetPhrases.text,
                            backText: userPhrases.text,
                            notes: userPhrases.notes,
                            tags: userPhrases.tags
                        )
                    }
                )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
