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
    
    var displayName: String {
        switch self {
        case .basics: return "Basics"
        case .travel: return "Travel"
        case .leisure: return "Leisure"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .food: return "Food"
        case .business: return "Business"
        case .education: return "Education"
        }
    }
    
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
} 