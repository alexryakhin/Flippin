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
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    init() {
        FirebaseApp.configure()
        AnalyticsService.trackEvent(.appLaunched)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
