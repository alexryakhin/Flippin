//
//  Language.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/6/25.
//

import Foundation

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
        }
    }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .dutch: return "Dutch"
        case .swedish: return "Swedish"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .vietnamese: return "Vietnamese"
        case .russian: return "Russian"
        case .arabic: return "Arabic"
        case .hindi: return "Hindi"
        case .croatian: return "Croatian"
        }
    }
}
