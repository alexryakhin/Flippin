//
//  Language.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/6/25.
//

import Foundation
import SwiftUI

enum Language: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case swedish = "sv"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case vietnamese = "vi"
    case russian = "ru"
    case arabic = "ar"
    case hindi = "hi"
    case croatian = "hr"
    case ukranian = "uk"

    var id: String { rawValue }
    
    var localizationCode: String {
        switch self {
        case .portuguese: return "pt-BR" // Default to Brazilian Portuguese
        case .chinese: return "zh-Hans" // Default to Simplified Chinese
        default: return rawValue
        }
    }

    var voiceOverCode: String {
        switch self {
        case .english: return "en-us"
        case .spanish: return "es-us"
        case .french: return "fr"
        case .german: return "de"
        case .italian: return "it"
        case .portuguese: return "pt"
        case .dutch: return "nl"
        case .swedish: return "sv"
        case .chinese: return "zh"
        case .japanese: return "ja"
        case .korean: return "ko"
        case .vietnamese: return "vi"
        case .russian: return "ru"
        case .arabic: return "ar"
        case .hindi: return "hi"
        case .croatian: return "hr"
        case .ukranian: return "uk"
        }
    }

    var displayName: String {
        switch self {
        case .english: return LocalizationKeys.Languages.english.localized
        case .spanish: return LocalizationKeys.Languages.spanish.localized
        case .french: return LocalizationKeys.Languages.french.localized
        case .german: return LocalizationKeys.Languages.german.localized
        case .italian: return LocalizationKeys.Languages.italian.localized
        case .portuguese: return LocalizationKeys.Languages.portuguese.localized
        case .dutch: return LocalizationKeys.Languages.dutch.localized
        case .swedish: return LocalizationKeys.Languages.swedish.localized
        case .chinese: return LocalizationKeys.Languages.chinese.localized
        case .japanese: return LocalizationKeys.Languages.japanese.localized
        case .korean: return LocalizationKeys.Languages.korean.localized
        case .vietnamese: return LocalizationKeys.Languages.vietnamese.localized
        case .russian: return LocalizationKeys.Languages.russian.localized
        case .arabic: return LocalizationKeys.Languages.arabic.localized
        case .hindi: return LocalizationKeys.Languages.hindi.localized
        case .croatian: return LocalizationKeys.Languages.croatian.localized
        case .ukranian: return LocalizationKeys.Languages.ukrainian.localized
        }
    }
    
    // MARK: - Static Methods
    
    static func fromSystemLocale() -> Language {
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        
        // Handle special cases for languages with regional variants
        switch languageCode {
        case "pt":
            // Portuguese - default to Brazilian Portuguese
            return .portuguese
        case "zh":
            // Chinese - default to Simplified Chinese
            return .chinese
        case "uk":
            // Ukrainian
            return .ukranian
        default:
            // Try to find exact match first
            if let language = Language(rawValue: languageCode) {
                return language
            }
            
            // Fallback to English if no match found
            return .english
        }
    }
}

// MARK: - Sorted Languages Extension

extension Language {
    /// Returns all languages sorted alphabetically by their display name
    static var sortedByDisplayName: [Language] {
        return Language.allCases.sorted { $0.displayName < $1.displayName }
    }
    
    /// Returns all languages sorted alphabetically by their display name, with a specific language at the top
    /// - Parameter priorityLanguage: The language to place at the top of the list
    /// - Returns: Array of languages with the priority language first, followed by others sorted alphabetically
    static func sortedByDisplayName(withPriority priorityLanguage: Language) -> [Language] {
        let allLanguages = Language.allCases
        let priorityLanguages = [priorityLanguage]
        let otherLanguages = allLanguages.filter { $0 != priorityLanguage }.sorted { $0.displayName < $1.displayName }
        
        return priorityLanguages + otherLanguages
    }
    
    /// Returns all languages sorted alphabetically by their display name, with system language at the top
    /// - Returns: Array of languages with the system language first, followed by others sorted alphabetically
    static var sortedByDisplayNameWithSystemFirst: [Language] {
        let systemLanguage = Language.fromSystemLocale()
        return sortedByDisplayName(withPriority: systemLanguage)
    }
}
