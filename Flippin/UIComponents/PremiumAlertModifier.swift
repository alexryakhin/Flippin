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
    case aiCollectionGenerator = "ai_collection_generator"
    case aiLearningCoach = "ai_learning_coach"
    case unlimitedCards = "unlimited_cards"
    case premiumVoices = "premium_voices"
    case collections = "collections"
    case customThemes = "custom_themes"
    case languageChange = "language_change"
    case advancedAnalytics = "advanced_analytics"
    case cardPresets = "card_presets"
    case studyModes = "study_modes"
    case images = "images"

    var icon: String {
        switch self {
        case .aiCollectionGenerator:
            return "sparkles"
        case .aiLearningCoach:
            return "brain.head.profile"
        case .unlimitedCards:
            return "infinity"
        case .premiumVoices:
            return "waveform"
        case .collections:
            return "folder.fill"
        case .customThemes:
            return "sparkles"
        case .languageChange:
            return "globe"
        case .advancedAnalytics:
            return "chart.line.uptrend.xyaxis"
        case .cardPresets:
            return "square.stack.3d.up.fill"
        case .studyModes:
            return "book.fill"
        case .images:
            return "photo.on.rectangle.angled"
        }
    }

    var title: String {
        switch self {
        case .aiCollectionGenerator:
            return "AI Collection Generator"
        case .aiLearningCoach:
            return "AI Learning Coach"
        case .unlimitedCards:
            return Loc.CardLimits.unlimitedCards
        case .premiumVoices:
            return "Speechify Premium Voices"
        case .collections:
            return Loc.PremiumFeatures.collections
        case .customThemes:
            return Loc.PremiumFeatures.premiumBackgrounds
        case .languageChange:
            return Loc.PremiumFeatures.multipleLanguagesTitle
        case .advancedAnalytics:
            return Loc.Paywall.advancedAnalyticsTitle
        case .cardPresets:
            return Loc.Paywall.cardPresetsTitle
        case .studyModes:
            return Loc.Paywall.studyModesTitle
        case .images:
            return Loc.CardImages.Premium.title
        }
    }
    
    var message: String {
        switch self {
        case .aiCollectionGenerator:
            return "Create custom flashcard collections with AI"
        case .aiLearningCoach:
            return "Get personalized insights and recommendations"
        case .unlimitedCards:
            return Loc.Paywall.unlimitedCardsMessage
        case .premiumVoices:
            return "Enjoy high-quality audio for all your flashcards!"
        case .collections:
            return Loc.PremiumFeatures.collectionsDescription
        case .customThemes:
            return Loc.PremiumFeatures.premiumBackgroundsDescription
        case .languageChange:
            return Loc.Paywall.languageChangeMessage
        case .advancedAnalytics:
            return Loc.Paywall.advancedAnalyticsMessage
        case .cardPresets:
            return Loc.Paywall.cardPresetsMessage
        case .studyModes:
            return Loc.Paywall.studyModesMessage
        case .images:
            return Loc.CardImages.Premium.message
        }
    }
    
    var description: String {
        switch self {
        case .aiCollectionGenerator:
            return "Create custom flashcard collections with AI"
        case .aiLearningCoach:
            return "Get personalized insights and recommendations"
        case .unlimitedCards:
            return Loc.PremiumFeatures.unlimitedCardsDescription
        case .premiumVoices:
            return "Thousands of high-quality voices to personalize your cards"
        case .collections:
            return Loc.PremiumFeatures.collectionsDescription
        case .customThemes:
            return Loc.PremiumFeatures.premiumBackgroundsDescription
        case .languageChange:
            return Loc.PremiumFeatures.multipleLanguagesDescription
        case .advancedAnalytics:
            return Loc.Paywall.advancedAnalyticsMessage
        case .cardPresets:
            return Loc.Paywall.cardPresetsMessage
        case .studyModes:
            return Loc.Paywall.studyModesMessage
        case .images:
            return Loc.CardImages.Premium.description
        }
    }
    
    /// Features to display in the paywall
    static var paywallFeatures: [PremiumFeature] {
        [
            .unlimitedCards,        // Core value proposition - most important
            .images,               // Visual appeal - high engagement
            .aiCollectionGenerator, // AI features - modern appeal
            .aiLearningCoach,       // AI features - personalized learning
            .premiumVoices,         // Audio enhancement - practical benefit
            .collections,           // Organization - productivity
            .advancedAnalytics,     // Progress tracking - motivation
            .customThemes,          // Personalization - nice to have
            .languageChange         // Flexibility - advanced users
        ]
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
