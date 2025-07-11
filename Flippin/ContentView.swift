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

    @Environment(\.colorScheme) private var colorScheme

    var displayItems: [CardItem] {
        return shuffledItems.isEmpty ? items : shuffledItems
    }

    var body: some View {
        VStack(spacing: 24) {
            cardsStackView
                .if(isPad) { view in
                    view
                        .frame(width: 500, height: 850, alignment: .center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            ButtonRowView(
                onAddItem: { showAddCardSheet = true },
                onShuffle: shuffleCards,
                onShowSettings: { showSettings = true },
                onShowMyCards: { showMyCards = true }
            )
        }
        .padding(24)
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
            MyCardsListView(onAddCard: {
                showAddCardSheet = true
            })
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet()
        }
    }

    @ViewBuilder
    private var cardsStackView: some View {
        if displayItems.isEmpty {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "rectangle.stack")
                        .font(.largeTitle)
                    Text("No cards yet")
                }
            } description: {
                Text("Tap the + button to add your first card")
                    .foregroundStyle(.secondary)
            }
            .foregroundColor(adjustedForegroundColor)
        } else {
            CardStackScrollView(items: displayItems)
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

    // Reset shuffle when items change (new cards added/removed)
    private func resetShuffleIfNeeded() {
        if !shuffledItems.isEmpty {
            // If we have shuffled items but the count doesn't match, reset
            if shuffledItems.count != items.count {
                shuffledItems = []
            }
        }
    }
}

private extension ContentView {

    var userLanguage: Language {
        Language(rawValue: userLanguageRaw) ?? .english
    }
    var targetLanguage: Language {
        Language(rawValue: targetLanguageRaw) ?? .spanish
    }

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }

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
                baseColor.lighter(by: 20),
                baseColor.darker(by: 20)
            ]
        }
    }

    var adjustedForegroundColor: Color {
        switch (colorScheme, userGradientColor.isLight) {
        case (.light, false): return Color(.systemBackground)
        default: return Color(.label)
        }
    }
}
