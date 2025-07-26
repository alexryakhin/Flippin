//
//  PremiumAlertModifier.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI

/**
 Premium feature types that can trigger the upgrade alert.
 */
enum PremiumFeature: String, CaseIterable {
    case unlimitedCards = "unlimited_cards"
    case advancedAnalytics = "advanced_analytics"
    case customThemes = "custom_themes"
    case studyModes = "study_modes"
    case languageChange = "language_change"
    case cardPresets = "card_presets"

    var title: String {
        switch self {
        case .unlimitedCards:
            return "Unlimited Cards"
        case .advancedAnalytics:
            return "Advanced Analytics"
        case .customThemes:
            return "Custom Themes"
        case .languageChange:
            return "Language Change"
        case .cardPresets:
            return "Card Presets"
        case .studyModes:
            return "Study Modes"
        }
    }
    
    var message: String {
        switch self {
        case .unlimitedCards:
            return "Upgrade to premium to create unlimited cards and unlock all features!"
        case .advancedAnalytics:
            return "Get detailed learning insights, progress charts, and performance analytics with premium!"
        case .customThemes:
            return "Unlock beautiful custom themes and backgrounds with premium!"
        case .cardPresets:
            return "Explore a vast collection of pre-designed card presets with premium!"
        case .languageChange:
            return "Choose from over 15 languages to enhance your learning experience with premium!"
        case .studyModes:
            return "Access advanced study modes and learning techniques with premium!"
        }
    }
}

/**
 A view modifier that presents a premium upgrade alert with an option to view the paywall.
 
 Usage:
 ```swift
 someView
     .premiumAlert(feature: $premiumFeature)
 ```
 */
struct PremiumAlertModifier: ViewModifier {
    @Binding var feature: PremiumFeature?
    @State private var showPaywall = false
    
    func body(content: Content) -> some View {
        content
            .alert(feature?.title ?? "Upgrade to Premium", isPresented: Binding(
                get: { feature != nil },
                set: { if !$0 { feature = nil } }
            )) {
                Button("Cancel", role: .cancel) { }
                Button("View Options") {
                    showPaywall = true
                }
            } message: {
                Text(feature?.message ?? "Upgrade to premium to unlock all features!")
            }
            .sheet(isPresented: $showPaywall) {
                Paywall.ContentView()
            }
    }
}

extension View {
    /**
     Presents a premium upgrade alert with an option to view the paywall.
     
     - Parameter feature: Binding to the premium feature that should trigger the alert
     */
    func premiumAlert(feature: Binding<PremiumFeature?>) -> some View {
        modifier(PremiumAlertModifier(feature: feature))
    }
} 
