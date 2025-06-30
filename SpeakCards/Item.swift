//
//  Item.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/29/25.
//

import Foundation
import SwiftData

enum Language: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case englishAmerican = "en-us"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case chinese = "zh"
    case japanese = "ja"
    case russian = "ru"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "British English"
        case .englishAmerican: return "American English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .russian: return "Russian"
        case .custom: return "Custom"
        }
    }
}

@Model
final class Item {
    var timestamp: Date
    var frontText: String
    var backText: String
    var frontLanguage: Language
    var backLanguage: Language
    var notes: String?
    
    init(timestamp: Date = Date(), frontText: String, backText: String, frontLanguage: Language, backLanguage: Language, notes: String? = nil) {
        self.timestamp = timestamp
        self.frontText = frontText
        self.backText = backText
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.notes = notes
    }
}
