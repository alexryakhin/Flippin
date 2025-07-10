//
//  ContentView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CardItem.timestamp) private var items: [CardItem]

    @AppStorage(UserDefaultsKey.userLanguage) private var userLanguageRaw: String = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en")?.rawValue ?? Language.english.rawValue
    @AppStorage(UserDefaultsKey.targetLanguage) private var targetLanguageRaw: String = Language.spanish.rawValue
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = "#4A90E2" // Default blue
    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    @State private var shuffledItems: [CardItem] = []
    
    var userLanguage: Language {
        Language(rawValue: userLanguageRaw) ?? .english
    }
    var targetLanguage: Language {
        Language(rawValue: targetLanguageRaw) ?? .spanish
    }
    
    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    var adjustedGradientColors: [Color] {
        let baseColor = userGradientColor
        
        // If we're in dark mode and the color is bright, darken it significantly
        if colorScheme == .dark && baseColor.isLight {
            return [
                baseColor.darker(by: 40), // Much darker for dark mode
                baseColor.darker(by: 60)  // Even darker for the bottom
            ]
        } else {
            // Use the original gradient for light mode or already dark colors
            return [
                baseColor.lighter(by: 15),
                baseColor.darker(by: 10)
            ]
        }
    }
    
    var displayItems: [CardItem] {
        return shuffledItems.isEmpty ? items : shuffledItems
    }
    
    // Reset shuffle when items change (new cards added/removed)
    private func resetShuffleIfNeeded() {
        if !shuffledItems.isEmpty {
            // If we have shuffled items but the count doesn't match, reset
            if shuffledItems.count != items.count {
                shuffledItems = []
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CardStackView(items: displayItems)
            ButtonRowView(
                onAddItem: { showAddCardSheet = true },
                onShuffle: shuffleCards,
                onShowSettings: { showSettings = true },
                onShowMyCards: { showMyCards = true }
            )
        }
        .background {
            LinearGradient(
                colors: adjustedGradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .onAppear {
            if !didShowWelcomeSheet {
                showWelcomeSheet = true
            }
        }
        .onChange(of: items.count) { _, _ in
            resetShuffleIfNeeded()
        }
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet(
                userLanguageRaw: $userLanguageRaw,
                targetLanguageRaw: $targetLanguageRaw,
                onContinue: {
                    didShowWelcomeSheet = true
                    showWelcomeSheet = false
                }
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showMyCards) {
            MyCardsListView()
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet()
        }
    }
    
    private func addItem(nativeText: String, targetText: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newItem = CardItem(
                frontText: targetText,
                backText: nativeText,
                frontLanguage: targetLanguage,
                backLanguage: userLanguage,
                notes: nil
            )
            modelContext.insert(newItem)
        }
    }
    
    private func shuffleCards() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if shuffledItems.isEmpty {
                // First shuffle: create shuffled copy
                shuffledItems = items.shuffled()
            } else {
                // Subsequent shuffles: reshuffle the current shuffled array
                shuffledItems = shuffledItems.shuffled()
            }
        }
    }
}
