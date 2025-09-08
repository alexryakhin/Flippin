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
            return Loc.Paywall.unlimitedCardsTitle
        case .advancedAnalytics:
            return Loc.Paywall.advancedAnalyticsTitle
        case .customThemes:
            return Loc.Paywall.customThemesTitle
        case .languageChange:
            return Loc.Paywall.languageChangeTitle
        case .cardPresets:
            return Loc.Paywall.cardPresetsTitle
        case .studyModes:
            return Loc.Paywall.studyModesTitle
        }
    }
    
    var message: String {
        switch self {
        case .unlimitedCards:
            return Loc.Paywall.unlimitedCardsMessage
        case .advancedAnalytics:
            return Loc.Paywall.advancedAnalyticsMessage
        case .customThemes:
            return Loc.Paywall.customThemesMessage
        case .cardPresets:
            return Loc.Paywall.cardPresetsMessage
        case .languageChange:
            return Loc.Paywall.languageChangeMessage
        case .studyModes:
            return Loc.Paywall.studyModesMessage
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
            .alert(feature?.title ?? Loc.Paywall.upgradeToPremiumTitle, isPresented: Binding(
                get: { feature != nil },
                set: { if !$0 { feature = nil } }
            )) {
                Button(Loc.Paywall.cancel, role: .cancel) { }
                Button(Loc.Paywall.viewOptions) {
                    showPaywall = true
                }
            } message: {
                Text(feature?.message ?? Loc.Paywall.upgradeToPremiumMessage)
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
