//
//  ContentView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI

/**
 Main content view for the Flippin app.
 Displays the card stack, filters, and navigation controls.
 Supports both finite and infinite card stacks based on card count.
 */
struct ContentView: View {
    // MARK: - State Objects
    
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared

    // MARK: - App Storage
    
    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    // MARK: - State Variables
    
    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    @State private var shuffledItems: [CardItem] = []
    @State private var showUpgradeAlert = false
    @State private var showPaywall = false

    // MARK: - Computed Properties
    
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

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            FiltersScrollView()
            
            // Card Limit Indicator for Free Users
            if !cardsProvider.hasUnlimitedCards {
                cardLimitIndicator
                    .if(isPad) { view in
                        view
                            .frame(maxWidth: 500, alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
            }

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
                onShowMyCards: { showMyCards = true }
            )
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
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
            WelcomeSheet.ContentView(
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
        .sheet(isPresented: $showPaywall) {
            Paywall.ContentView()
        }
        .onChange(of: showPaywall) { _, isPresented in
            if isPresented {
                AnalyticsService.trackEvent(.paywallOpened)
            }
        }
        .alert("Upgrade to Premium", isPresented: $showUpgradeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("View Options") {
                showSettings = true
            }
        } message: {
            Text("Upgrade to premium to create unlimited cards and unlock all features!")
        }
    }

    // MARK: - Card Stack Views
    
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
            if displayItems.count > 4 {
                InfiniteCardStack(displayItems) {
                    CardView(card: $0)
                }
            } else {
                CardStack(displayItems) {
                    CardView(card: $0)
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private var cardLimitIndicator: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationKeys.cardsUsedOfLimit.localized(with: cardsProvider.cards.count, cardsProvider.cardLimit))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ProgressView(value: Double(cardsProvider.cards.count), total: Double(cardsProvider.cardLimit))
                    .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                    .frame(height: 4)
            }
            
            Spacer()
            
            Button(LocalizationKeys.upgrade.localized) {
                showPaywall = true
            }
            .font(.caption)
            .buttonStyle(.borderedProminent)
            .clipShape(Capsule())
        }
        .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
    }

    private var noCardsView: some View {
        VStack(spacing: 16) {
            ContentUnavailableView {
                VStack {
                    Image(.stackCards)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
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
                Image(.stackCards)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
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

    // MARK: - Actions
    
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


