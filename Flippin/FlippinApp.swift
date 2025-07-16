//
//  FlippinApp.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI
import CoreData
import Firebase
import FirebaseAnalytics

@main
struct FlippinApp: App {
    @StateObject private var cardsProvider = CardsProvider()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var tagManager = TagManager()

    init() {
        FirebaseApp.configure()
        AnalyticsService.trackEvent(.appLaunched)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cardsProvider)
                .environmentObject(languageManager)
                .environmentObject(tagManager)
        }
    }
}
