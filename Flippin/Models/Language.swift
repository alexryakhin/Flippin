//
//  Language.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/6/25.
//

import Foundation
import SwiftUICore

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
        case .english: return NSLocalizedString("English", comment: "English language name")
        case .spanish: return NSLocalizedString("Spanish", comment: "Spanish language name")
        case .french: return NSLocalizedString("French", comment: "French language name")
        case .german: return NSLocalizedString("German", comment: "German language name")
        case .italian: return NSLocalizedString("Italian", comment: "Italian language name")
        case .portuguese: return NSLocalizedString("Portuguese", comment: "Portuguese language name")
        case .dutch: return NSLocalizedString("Dutch", comment: "Dutch language name")
        case .swedish: return NSLocalizedString("Swedish", comment: "Swedish language name")
        case .chinese: return NSLocalizedString("Chinese", comment: "Chinese language name")
        case .japanese: return NSLocalizedString("Japanese", comment: "Japanese language name")
        case .korean: return NSLocalizedString("Korean", comment: "Korean language name")
        case .vietnamese: return NSLocalizedString("Vietnamese", comment: "Vietnamese language name")
        case .russian: return NSLocalizedString("Russian", comment: "Russian language name")
        case .arabic: return NSLocalizedString("Arabic", comment: "Arabic language name")
        case .hindi: return NSLocalizedString("Hindi", comment: "Hindi language name")
        case .croatian: return NSLocalizedString("Croatian", comment: "Croatian language name")
        case .ukranian: return NSLocalizedString("Ukrainian", comment: "Ukrainian language name")
        }
    }
}
