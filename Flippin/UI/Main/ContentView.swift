//
//  ContentView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var cardsProvider: CardsProvider
    @EnvironmentObject private var languageManager: LanguageManager

    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    @State private var shuffledItems: [CardItem] = []
    @StateObject private var tagManager = TagManager()
    @StateObject private var colorManager = ColorManager()
    @State private var showingTagFilter = false

    var filteredItems: [CardItem] {
        if !tagManager.currentFilterTag.isEmpty {
            return tagManager.filterCards(cardsProvider.cards, by: tagManager.currentFilterTag)
        }
        return cardsProvider.cards
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
                style: colorManager.backgroundStyle,
                baseColor: colorManager.userGradientColor
            )
        }
        .onAppear {
            if !didShowWelcomeSheet {
                showWelcomeSheet = true
                AnalyticsService.trackEvent(.welcomeScreenOpened)
            }
        }
        .onChange(of: cardsProvider.cards.count) { _, _ in
            resetShuffle()
        }
        .onChange(of: tagManager.currentFilterTag) { _, _ in
            resetShuffle()
        }
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet(
                onContinue: {
                    didShowWelcomeSheet = true
                    showWelcomeSheet = false
                }
            )
            .environmentObject(languageManager)
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(languageManager)
        }
        .onChange(of: showSettings) { _, isPresented in
            if isPresented {
                AnalyticsService.trackNavigationEvent(.settingsScreenOpened, screenName: "Settings")
            }
        }
        .sheet(isPresented: $showMyCards) {
            MyCardsListView(
                onToSettings: {
                    showSettings = true
                }
            )
            .environmentObject(cardsProvider)
            .environmentObject(languageManager)
        }
        .onChange(of: showMyCards) { _, isPresented in
            if isPresented {
                AnalyticsService.trackNavigationEvent(.myCardsScreenOpened, screenName: "MyCards")
            }
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet { newCard in
                cardsProvider.addCard(newCard)
            }
            .environmentObject(languageManager)
        }
        .onChange(of: showAddCardSheet) { _, isPresented in
            if isPresented {
                AnalyticsService.trackNavigationEvent(.addCardScreenOpened, screenName: "AddCard")
            }
        }
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView(tagManager: tagManager) {
                showSettings = true
            }
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var cardsStackView: some View {
        if cardsProvider.cards.isEmpty {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.largeTitle)
                        .rotationEffect(.init(degrees: 90))
                    Text(LocalizationKeys.noCardsYet.localized)
                }
            } description: {
                Text(LocalizationKeys.tapToAddFirstCard.localized)
                    .foregroundStyle(.secondary)
            }
            .foregroundColor(colorManager.adjustedForegroundColor(colorScheme))
        } else if displayItems.isEmpty {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "tag")
                        .font(.largeTitle)
                    Text(LocalizationKeys.noCardsWithSelectedTag.localized)
                }
            } description: {
                if !tagManager.currentFilterTag.isEmpty {
                    Text(LocalizationKeys.noCardsFoundWithTag.localized(with: tagManager.currentFilterTag))
                } else {
                    Text(LocalizationKeys.noCardsAvailable.localized)
                }
            } actions: {
                if !tagManager.currentFilterTag.isEmpty {
                    Button(LocalizationKeys.clearFilter.localized) {
                        tagManager.clearFilter()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(colorManager.adjustedTintColor(colorScheme))
                }
            }
            .foregroundColor(colorManager.adjustedForegroundColor(colorScheme))
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
        AnalyticsService.trackEvent(.cardsShuffled)
    }

    private func resetShuffle() {
        shuffledItems = []
    }
}


