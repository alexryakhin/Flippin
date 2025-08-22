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
import TipKit

@main
struct FlippinApp: App {
    #if DEBUG
    @State private var isDebugViewPresented: Bool = false
    #endif

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var speechifyService = SpeechifyService.shared
    @StateObject private var remoteConfigService = RemoteConfigService.shared

    init() {
        FirebaseApp.configure()
        AnalyticsService.trackEvent(.appLaunched)
        
        // Configure TipKit
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        
        // Configure notification center delegate
        UNUserNotificationCenter.current().delegate = NotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .observeColorScheme()
                .tint(colorManager.tintColor)
                        .task {
            // Ensure purchase status is properly loaded at startup
            await ensurePurchaseStatusLoaded()
            
            // Fetch Remote Config for API keys
            await remoteConfigService.fetchConfig()
            
            // Load Speechify voices for premium users if Remote Config is ready
            if purchaseService.hasPremiumAccess && remoteConfigService.isRemoteConfigReady() {
                await speechifyService.loadVoices()
            }
        }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        AnalyticsService.trackEvent(.appBackgrounded)
                        notificationService.scheduleNotificationsWhenLeavingApp()
                    case .active:
                        AnalyticsService.trackEvent(.appForegrounded)
                        notificationService.rescheduleStudyReminderIfNeeded()
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
                #if DEBUG
                .onShake {
                    isDebugViewPresented = true
                }
                .sheet(isPresented: $isDebugViewPresented) {
                    DebugView()
                }
                #endif
        }
    }
    
    private func ensurePurchaseStatusLoaded() async {
        print("🚀 App startup: Ensuring purchase status is loaded...")
        
        // Ensure purchase status is properly loaded
        await purchaseService.loadProducts()
        await purchaseService.reloadPurchaseStatus()
        
        // Log current status
        let purchasedProducts = purchaseService.getPurchasedProducts()
        print("📦 Startup: Found \(purchasedProducts.count) purchased products: \(purchasedProducts)")
        
        // Check card limit status
        let cardLimit = cardsProvider.cardLimit
        let currentCards = cardsProvider.cards.count
        let hasUnlimited = cardsProvider.hasUnlimitedCards
        
        print("🎯 Startup: Card limit status - Limit: \(cardLimit), Current: \(currentCards), Unlimited: \(hasUnlimited)")
        
        AnalyticsService.trackEvent(.appLaunched, parameters: [
            "purchased_products_count": purchasedProducts.count,
            "card_limit": cardLimit,
            "current_cards": currentCards,
            "has_unlimited": hasUnlimited
        ])
    }
}

// Removed iOS 26 availability check - app targets iOS 17+
