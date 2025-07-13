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
    @Query(sort: \CardItem.timestamp, order: .forward) private var items: [CardItem]

    @AppStorage(UserDefaultsKey.userLanguage) private var userLanguageRaw: String = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en")?.rawValue ?? Language.english.rawValue
    @AppStorage(UserDefaultsKey.targetLanguage) private var targetLanguageRaw: String = Language.spanish.rawValue
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = Constant.defaultColorHex // Default blue
    @AppStorage(UserDefaultsKey.backgroundStyle) private var backgroundStyleRaw: String = BackgroundStyle.gradient.rawValue
    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    @State private var shuffledItems: [CardItem] = []
    @StateObject private var tagManager = TagManager()
    @State private var showingTagFilter = false

    @Environment(\.colorScheme) private var colorScheme

    var filteredItems: [CardItem] {
        if !tagManager.currentFilterTag.isEmpty {
            return tagManager.filterCards(items, by: tagManager.currentFilterTag)
        }
        return items
    }

    var displayItems: [CardItem] {
        let itemsToUse = shuffledItems.isEmpty ? filteredItems : shuffledItems
        return itemsToUse
    }

    var body: some View {
        VStack(spacing: 24) {
            cardsStackView
                .if(isPad) { view in
                    view
                        .frame(maxWidth: 500, maxHeight: 850, alignment: .center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            ButtonRowView(
                onAddItem: { showAddCardSheet = true },
                onShuffle: shuffleCards,
                onShowSettings: { showSettings = true },
                onShowMyCards: { showMyCards = true },
                onFilterTags: { showingTagFilter = true },
                isFilterActive: !tagManager.currentFilterTag.isEmpty
            )
        }
        .padding(24)
        .background {
            AnimatedBackground(
                style: backgroundStyle,
                baseColor: userGradientColor
            )
        }
        .onAppear {
            if !didShowWelcomeSheet {
                showWelcomeSheet = true
            }
        }
        .onChange(of: items.count) { _, _ in
            resetShuffle()
        }
        .onChange(of: tagManager.currentFilterTag) { _, _ in
            resetShuffle()
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
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView(tagManager: tagManager)
                .presentationDetents(.init(Set([.medium])))
        }
    }

    @ViewBuilder
    private var cardsStackView: some View {
        if items.isEmpty {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.largeTitle)
                        .rotationEffect(.init(degrees: 90))
                    Text("No cards yet")
                }
            } description: {
                Text("Tap the + button to add your first card")
                    .foregroundStyle(.secondary)
            }
            .foregroundColor(adjustedForegroundColor)
        } else if displayItems.isEmpty {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "tag")
                        .font(.largeTitle)
                    Text("No cards with selected tag")
                }
            } description: {
                if !tagManager.currentFilterTag.isEmpty {
                    Text("No cards found with tag \"\(tagManager.currentFilterTag)\"")
                } else {
                    Text("No cards available")
                }
            } actions: {
                if !tagManager.currentFilterTag.isEmpty {
                    Button("Clear Filter") {
                        tagManager.clearFilter()
                    }
                    .buttonStyle(.borderedProminent)
                }
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
                shuffledItems = filteredItems.shuffled()
            } else {
                // Subsequent shuffles: reshuffle the current shuffled array
                shuffledItems = shuffledItems.shuffled()
            }
        }
    }

    private func resetShuffle() {
        shuffledItems = []
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
    
    var backgroundStyle: BackgroundStyle {
        BackgroundStyle(rawValue: backgroundStyleRaw) ?? .gradient
    }

    var adjustedForegroundColor: Color {
        guard !backgroundStyle.isAlwaysDark else { return Color(.white) }
        switch (colorScheme, userGradientColor.isLight) {
        case (.light, false): return Color(.systemBackground)
        default: return Color(.label)
        }
    }
}
