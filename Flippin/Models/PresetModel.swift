//
//  PresetCollection.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

// MARK: - JSON Models for Parsing

enum PresetModel {
    struct Data: Codable {
        let languageName: String
        let languageCode: String
        let presets: [Preset]
    }

    struct Preset: Codable, Identifiable {
        let id: Int
        let name: String
        let description: String
        let category: Category
        let systemImageName: String
        let phrases: [Phrase]
    }

    struct Phrase: Codable, Identifiable {
        let id: Int
        let text: String
        let notes: String
        let tags: [String]
    }

    enum Category: String, Codable, CaseIterable {
        case basics
        case travel
        case social
        case lifestyle
        case professional
        case emergency
        case food
        case shopping
        case technology
        case weather
        case entertainment
    }
}

extension PresetModel.Category {
    var icon: String {
        switch self {
        case .basics: return "abc"
        case .travel: return "airplane"
        case .entertainment: return "tv"
        case .food: return "fork.knife"
        case .shopping: return "bag"
        case .social: return "person.2"
        case .weather: return "cloud.sun"
        case .technology: return "laptopcomputer"
        case .lifestyle: return "camera.macro"
        case .professional: return "briefcase.fill"
        case .emergency: return "exclamationmark.triangle"
        }
    }

    var displayTitle: String {
        switch self {
        case .basics: return LocalizationKeys.categoryBasics.localized
        case .travel: return LocalizationKeys.categoryTravel.localized
        case .entertainment: return LocalizationKeys.categoryEntertainment.localized
        case .food: return LocalizationKeys.categoryFood.localized
        case .shopping: return LocalizationKeys.categoryShopping.localized
        case .social: return LocalizationKeys.categorySocial.localized
        case .weather: return LocalizationKeys.categoryWeather.localized
        case .technology: return LocalizationKeys.categoryTechnology.localized
        case .lifestyle: return LocalizationKeys.categoryLifestyle.localized
        case .professional: return LocalizationKeys.categoryProfessional.localized
        case .emergency: return LocalizationKeys.categoryEmergency.localized
        }
    }
}
