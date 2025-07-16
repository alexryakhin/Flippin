//
//  CardItem.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import Foundation

struct CardItem: Identifiable {

    var timestamp: Date
    var frontText: String
    var backText: String
    var frontLanguage: Language
    var backLanguage: Language
    var notes: String
    var tags: [String]
    var isFavorite: Bool
    var id: String

    init(
        timestamp: Date,
        frontText: String,
        backText: String,
        frontLanguage: Language,
        backLanguage: Language,
        notes: String,
        tags: [String],
        isFavorite: Bool,
        id: String
    ) {
        self.timestamp = timestamp
        self.frontText = frontText
        self.backText = backText
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.notes = notes
        self.tags = tags
        self.isFavorite = isFavorite
        self.id = id
    }
}
