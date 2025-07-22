//
//  ContentView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    @State private var shuffledItems: [CardItem] = []
    @State private var triggerGoBack = false

    var filteredItems: [CardItem] {
        var filtered = cardsProvider.cards
        
        // Apply language filter first
        filtered = languageManager.filterCards(filtered)
        
        // Then apply tag filter
        if let selectedFilterTag = tagManager.selectedFilterTag {
            filtered = tagManager.filterCards(filtered, by: selectedFilterTag)
        }
        filtered = tagManager.filterCardsByFavorite(filtered)
        return filtered
    }

    var displayItems: [CardItem] {
        let itemsToUse = shuffledItems.isEmpty ? filteredItems : shuffledItems
        return itemsToUse
    }

    var body: some View {
        VStack(spacing: 16) {

            FiltersScrollView()

            cardsStackView
                .if(isPad) { view in
                    view
                        .frame(maxWidth: 500, maxHeight: 850, alignment: .center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            ButtonRowView(
                onAddItem: { showAddCardSheet = true },
                onSeePreviousCard: { triggerGoBack = true },
                onShuffle: shuffleCards,
                onShowSettings: { showSettings = true },
                onShowMyCards: { showMyCards = true }
            )
        }
        .padding(16)
        .background {
            AnimatedBackground(style: colorManager.backgroundStyle)
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
        .onChange(of: tagManager.selectedFilterTag) { _, _ in
            resetShuffle()
        }
        .onChange(of: tagManager.isFavoriteFilterOn) { _, _ in
            resetShuffle()
        }
        .onChange(of: languageManager.filterByLanguage) { _, _ in
            resetShuffle()
        }
        .onChange(of: languageManager.userLanguage) { _, _ in
            resetShuffle()
        }
        .onChange(of: languageManager.targetLanguage) { _, _ in
            resetShuffle()
        }
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet(
                onContinue: {
                    didShowWelcomeSheet = true
                    showWelcomeSheet = false
                }
            )
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
        }
        .onChange(of: showMyCards) { _, isPresented in
            if isPresented {
                AnalyticsService.trackNavigationEvent(.myCardsScreenOpened, screenName: "MyCards")
            }
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet()
        }
        .onChange(of: showAddCardSheet) { _, isPresented in
            if isPresented {
                AnalyticsService.trackNavigationEvent(.addCardScreenOpened, screenName: "AddCard")
            }
        }
    }

    @ViewBuilder
    private var cardsStackView: some View {
        if cardsProvider.cards.isEmpty {
            noCardsView
        } else if displayItems.isEmpty {
            if tagManager.isFavoriteFilterOn {
                noFavoriteCardsView
            } else if languageManager.filterByLanguage {
                filteredByLanguageCardsEmptyView
            } else {
                noCardsWithTagsView
            }
        } else {
            CardStackContent(
                cards: displayItems,
                triggerGoBack: triggerGoBack
            )
            .onChange(of: triggerGoBack) { _, newValue in
                // Reset the trigger after it's been used
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        triggerGoBack = false
                    }
                }
            }
        }
    }

    private var noCardsView: some View {
        VStack(spacing: 16) {
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
            .foregroundColor(colorManager.foregroundColor)

            FeaturedPresetCollections()
                .clippedWithPaddingAndBackgroundMaterial()
        }
    }

    @ViewBuilder
    private var noCardsWithTagsView: some View {
        if let selectedFilterTag = tagManager.selectedFilterTag {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "tag")
                        .font(.largeTitle)
                    Text(LocalizationKeys.noCardsWithSelectedTag.localized)
                }
            } description: {
                Text(LocalizationKeys.noCardsFoundWithTag.localized(with: selectedFilterTag.name.orEmpty))
                    .foregroundStyle(.secondary)
            } actions: {
                Button(LocalizationKeys.clearFilter.localized) {
                    HapticService.shared.buttonTapped()
                    tagManager.clearFilter()
                }
                .buttonStyle(.borderedProminent)
            }
            .foregroundColor(colorManager.foregroundColor)
        }
    }

    private var filteredByLanguageCardsEmptyView: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "rectangle.stack.fill")
                    .font(.largeTitle)
                    .rotationEffect(.init(degrees: 90))
                Text(LocalizationKeys.noCardsYet.localized)
            }
        } description: {
            Text(LocalizationKeys.noCardsForLanguagePair.localized)
                .foregroundStyle(.secondary)
        }
        .foregroundColor(colorManager.foregroundColor)
    }

    private var noFavoriteCardsView: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "heart")
                    .font(.largeTitle)
                Text(LocalizationKeys.noFavoriteCards.localized)
            }
        } description: {
            Text(LocalizationKeys.noFavoriteCardsDescription.localized)
                .foregroundStyle(.secondary)
        }
        .foregroundColor(colorManager.foregroundColor)
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
        
        // Haptic feedback for card shuffle
        HapticService.shared.cardsShuffled()
        
        AnalyticsService.trackEvent(.cardsShuffled)
    }

    private func resetShuffle() {
        shuffledItems = []
    }
}


