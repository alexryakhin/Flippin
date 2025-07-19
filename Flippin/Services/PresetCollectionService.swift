//
//  PresetCollectionService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

class PresetCollectionService: ObservableObject {
    static let shared = PresetCollectionService()
    
    @Published var collections: [PresetCollection] = []
    
    private let localizedService = LocalizedPresetService.shared
    
    private init() {
        loadCollections()
    }
    
    func loadCollections() {
        // This will be called with specific languages when needed
        collections = []
    }
    
    func getCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        return localizedService.getLocalizedCollections(for: userLanguage, targetLanguage: targetLanguage)
    }
    
    func getFeaturedCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        return localizedService.getFeaturedCollections(for: userLanguage, targetLanguage: targetLanguage)
    }
    
    func convertPresetCardsToCardItems(_ presetCards: [PresetCard], userLanguage: Language, targetLanguage: Language) -> [CardItem] {
        return localizedService.convertPresetCardsToCardItems(presetCards, userLanguage: userLanguage, targetLanguage: targetLanguage)
    }
} 
