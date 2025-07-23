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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared

    init() {
        FirebaseApp.configure()
        AnalyticsService.trackEvent(.appLaunched)
        
        // Configure TipKit
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .observeColorScheme()
                .tint(colorManager.tintColor)
                .task {
                    // Ensure purchase status is properly loaded at startup
                    await ensurePurchaseStatusLoaded()
                }
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
