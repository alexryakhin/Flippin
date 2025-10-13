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

    var speechifyCode: String {
        switch self {
        case .english: return "en"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-BR"
        case .dutch: return "nl-NL"
        case .swedish: return "sv-SE"
        case .chinese: return "zh-CN"
        case .japanese: return "ja-JP"
        case .korean: return "ko-KR"
        case .vietnamese: return "vi-VN"
        case .russian: return "ru-RU"
        case .arabic: return "ar-SA"
        case .hindi: return "hi-IN"
        case .croatian: return "hr-HR"
        case .ukranian: return "uk-UA"
        }
    }

    var displayName: String {
        switch self {
        case .english: return Loc.Languages.english
        case .spanish: return Loc.Languages.spanish
        case .french: return Loc.Languages.french
        case .german: return Loc.Languages.german
        case .italian: return Loc.Languages.italian
        case .portuguese: return Loc.Languages.portuguese
        case .dutch: return Loc.Languages.dutch
        case .swedish: return Loc.Languages.swedish
        case .chinese: return Loc.Languages.chinese
        case .japanese: return Loc.Languages.japanese
        case .korean: return Loc.Languages.korean
        case .vietnamese: return Loc.Languages.vietnamese
        case .russian: return Loc.Languages.russian
        case .arabic: return Loc.Languages.arabic
        case .hindi: return Loc.Languages.hindi
        case .croatian: return Loc.Languages.croatian
        case .ukranian: return Loc.Languages.ukrainian
        }
    }
    
    var chatGPTLanguageName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .dutch: return "Dutch"
        case .swedish: return "Swedish"
        case .chinese: return "Chinese (Simplified)"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .vietnamese: return "Vietnamese"
        case .russian: return "Russian"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .croatian: return "Croatian"
        case .ukranian: return "Ukrainian"
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
