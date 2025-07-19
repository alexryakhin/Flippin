//
//  PresetCollection.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

struct PresetCollection: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let category: PresetCategory
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

enum PresetCategory: String, CaseIterable {
    case basics = "basics"
    case travel = "travel"
    case leisure = "leisure"
    case entertainment = "entertainment"
    case health = "health"
    case food = "food"
    case business = "business"
    case education = "education"
        
    var icon: String {
        switch self {
        case .basics: return "abc"
        case .travel: return "airplane"
        case .leisure: return "gamecontroller"
        case .entertainment: return "tv"
        case .health: return "cross.case"
        case .food: return "fork.knife"
        case .business: return "briefcase"
        case .education: return "book"
        }
    }
    
    // MARK: - Localized Properties
    
    func localizedName(for language: Language) -> String {
        let key = "tag.\(rawValue)"
        return getLocalizedString(key, language: language)
    }
    
    func localizedTag(for language: Language) -> String {
        let key = "tag.\(rawValue)"
        return getLocalizedString(key, language: language)
    }
    
    // For backward compatibility and UI display
    var displayName: String {
        // Default to English if no specific language context
        return localizedName(for: .english)
    }
    
    // MARK: - Private Helper
    
    private func getLocalizedString(_ key: String, language: Language) -> String {
        let bundle = Bundle.main
        let languageCode = language.localizationCode
        
        // Try to load the string from the specific language bundle
        if let languageBundle = bundle.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: languageBundle) {
            let localizedString = NSLocalizedString(key, tableName: "PresetPhrases", bundle: bundle, value: key, comment: "")
            if localizedString != key {
                return localizedString
            }
        }
        
        // Fallback to main bundle
        return NSLocalizedString(key, tableName: "PresetPhrases", bundle: bundle, value: key, comment: "")
    }
} 
