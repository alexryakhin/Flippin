//
//  Item.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/29/25.
//

import Foundation
import SwiftData

@Model
final class CardItem {
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
