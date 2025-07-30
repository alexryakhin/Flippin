//
//  LanguageManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//

import Foundation
import SwiftUI

@MainActor
final class LanguageManager: ObservableObject {

    static let shared = LanguageManager()

    @Published private(set) var userLanguage: Language {
        didSet {
            UserDefaults.standard.set(userLanguage.rawValue, forKey: UserDefaultsKey.userLanguage)
        }
    }

    @Published private(set) var targetLanguage: Language {
        didSet {
            UserDefaults.standard.set(targetLanguage.rawValue, forKey: UserDefaultsKey.targetLanguage)
        }
    }

    @Published var filterByLanguage: Bool {
        didSet {
            UserDefaults.standard.set(filterByLanguage, forKey: UserDefaultsKey.filterByLanguage)
        }
    }

    var userLanguageRaw: String {
        get { userLanguage.rawValue }
        set {
            if let language = Language(rawValue: newValue) {
                setUserLanguage(language)
            }
        }
    }

    var targetLanguageRaw: String {
        get { targetLanguage.rawValue }
        set {
            if let language = Language(rawValue: newValue) {
                setTargetLanguage(language)
            }
        }
    }

    private init() {
        var userLanguageTemp: Language = .english
        // Initialize user language from UserDefaults or detect from system
        let savedUserLanguage = UserDefaults.standard.string(forKey: UserDefaultsKey.userLanguage)
        if let savedUserLanguage = savedUserLanguage, let language = Language(rawValue: savedUserLanguage) {
            self.userLanguage = language
            userLanguageTemp = language
        } else {
            // Detect from system locale
            let detectedLanguage = Language.fromSystemLocale()
            self.userLanguage = detectedLanguage
            userLanguageTemp = detectedLanguage
            // Save the detected language
            UserDefaults.standard.set(detectedLanguage.rawValue, forKey: UserDefaultsKey.userLanguage)
        }

        // Initialize target language from UserDefaults or use default
        let savedTargetLanguage = UserDefaults.standard.string(forKey: UserDefaultsKey.targetLanguage)
        if let savedTargetLanguage = savedTargetLanguage, let language = Language(rawValue: savedTargetLanguage) {
            self.targetLanguage = language
        } else {
            self.targetLanguage = userLanguageTemp == .spanish ? .english : .spanish
            UserDefaults.standard.set(Language.spanish.rawValue, forKey: UserDefaultsKey.targetLanguage)
        }

        // Initialize language filter from UserDefaults
        self.filterByLanguage = UserDefaults.standard.bool(forKey: UserDefaultsKey.filterByLanguage)
    }

    // MARK: - Public Methods

    func setUserLanguage(_ language: Language) {
        userLanguage = language
        
        // Haptic feedback for language change
        HapticService.shared.languageChanged()
        
        AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: userLanguage.rawValue, newValue: language.rawValue)
    }

    func setTargetLanguage(_ language: Language) {
        targetLanguage = language
        
        // Haptic feedback for language change
        HapticService.shared.languageChanged()
        
        AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: targetLanguage.rawValue, newValue: language.rawValue)
    }

    func resetToSystemLanguage() {
        let detectedLanguage = Language.fromSystemLocale()
        setUserLanguage(detectedLanguage)
    }

    func filterCards(_ cards: [CardItem]) -> [CardItem] {
        // Disable language filtering for free users
        guard PurchaseService.shared.hasPremiumAccess && filterByLanguage else { return cards }
        
        return cards.filter { card in
            card.frontLanguage == targetLanguage && card.backLanguage == userLanguage
        }
    }
}
