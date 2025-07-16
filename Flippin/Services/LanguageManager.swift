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

    init() {
        // Initialize user language from UserDefaults or detect from system
        let savedUserLanguage = UserDefaults.standard.string(forKey: UserDefaultsKey.userLanguage)
        if let savedUserLanguage = savedUserLanguage, let language = Language(rawValue: savedUserLanguage) {
            self.userLanguage = language
        } else {
            // Detect from system locale
            let detectedLanguage = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en") ?? .english
            self.userLanguage = detectedLanguage
            // Save the detected language
            UserDefaults.standard.set(detectedLanguage.rawValue, forKey: UserDefaultsKey.userLanguage)
        }

        // Initialize target language from UserDefaults or use default
        let savedTargetLanguage = UserDefaults.standard.string(forKey: UserDefaultsKey.targetLanguage)
        if let savedTargetLanguage = savedTargetLanguage, let language = Language(rawValue: savedTargetLanguage) {
            self.targetLanguage = language
        } else {
            self.targetLanguage = .spanish
            UserDefaults.standard.set(Language.spanish.rawValue, forKey: UserDefaultsKey.targetLanguage)
        }
    }

    // MARK: - Public Methods

    func setUserLanguage(_ language: Language) {
        userLanguage = language
        AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: userLanguage.rawValue, newValue: language.rawValue)
    }

    func setTargetLanguage(_ language: Language) {
        targetLanguage = language
        AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: targetLanguage.rawValue, newValue: language.rawValue)
    }

    func resetToSystemLanguage() {
        let detectedLanguage = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en") ?? .english
        setUserLanguage(detectedLanguage)
    }
}
