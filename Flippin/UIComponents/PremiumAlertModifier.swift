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
            return LocalizationKeys.Paywall.unlimitedCardsTitle.localized
        case .advancedAnalytics:
            return LocalizationKeys.Paywall.advancedAnalyticsTitle.localized
        case .customThemes:
            return LocalizationKeys.Paywall.customThemesTitle.localized
        case .languageChange:
            return LocalizationKeys.Paywall.languageChangeTitle.localized
        case .cardPresets:
            return LocalizationKeys.Paywall.cardPresetsTitle.localized
        case .studyModes:
            return LocalizationKeys.Paywall.studyModesTitle.localized
        }
    }
    
    var message: String {
        switch self {
        case .unlimitedCards:
            return LocalizationKeys.Paywall.unlimitedCardsMessage.localized
        case .advancedAnalytics:
            return LocalizationKeys.Paywall.advancedAnalyticsMessage.localized
        case .customThemes:
            return LocalizationKeys.Paywall.customThemesMessage.localized
        case .cardPresets:
            return LocalizationKeys.Paywall.cardPresetsMessage.localized
        case .languageChange:
            return LocalizationKeys.Paywall.languageChangeMessage.localized
        case .studyModes:
            return LocalizationKeys.Paywall.studyModesMessage.localized
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
            .alert(feature?.title ?? LocalizationKeys.Paywall.upgradeToPremiumTitle.localized, isPresented: Binding(
                get: { feature != nil },
                set: { if !$0 { feature = nil } }
            )) {
                Button(LocalizationKeys.Paywall.cancel.localized, role: .cancel) { }
                Button(LocalizationKeys.Paywall.viewOptions.localized) {
                    showPaywall = true
                }
            } message: {
                Text(feature?.message ?? LocalizationKeys.Paywall.upgradeToPremiumMessage.localized)
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
