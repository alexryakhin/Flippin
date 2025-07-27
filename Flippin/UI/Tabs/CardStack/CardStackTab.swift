import SwiftUI

/**
 CardStackTab - Main card stack interface.
 Contains the core flashcard functionality with filters and navigation.
 */
enum CardStackTab {

    struct ContentView: View {
        // MARK: - State Objects

        @StateObject private var cardsProvider = CardsProvider.shared
        @StateObject private var languageManager = LanguageManager.shared
        @StateObject private var tagManager = TagManager.shared
        @StateObject private var colorManager = ColorManager.shared

        // MARK: - State Variables

        @State private var shuffledItems: [CardItem] = []
        @State private var showAddCardSheet = false
        @State private var premiumFeature: PremiumFeature?

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
                // Filters
                FiltersScrollView()

                // Card limit indicator
                cardLimitIndicator

                // Card stack
                cardsStackView
                    .if(isPad) { view in
                        view
                            .frame(maxWidth: 500, maxHeight: 850, alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }

                if !cardsProvider.cards.isEmpty {
                    // Action buttons
                    HStack(spacing: 16) {
                        // Shuffle button
                        Button {
                            shuffleCards()
                        } label: {
                            Label("Shuffle", systemImage: "shuffle")
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())

                        // Add card button
                        Button {
                            showAddCardSheet = true
                        } label: {
                            Label("Add Card", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(vertical: 12, horizontal: 16)
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
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
            .sheet(isPresented: $showAddCardSheet) {
                AddCardSheet()
            }
            .premiumAlert(feature: $premiumFeature)
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
            // Card Limit Indicator for Free Users
            if !cardsProvider.hasUnlimitedCards && !cardsProvider.cards.isEmpty {
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
                        premiumFeature = .unlimitedCards
                    }
                    .font(.caption)
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
                .if(isPad) { view in
                    view
                        .frame(maxWidth: 500, alignment: .center)
                }
            }
        }

        private var noCardsView: some View {
            VStack {
                ContentUnavailableView {
                    VStack {
                        Image(.stackCards)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        Text(LocalizationKeys.noCardsYet.localized)
                    }
                } description: {
                    Text(LocalizationKeys.tapToAddFirstCard.localized)
                        .foregroundStyle(.secondary)
                } actions: {
                    Button {
                        showAddCardSheet = true
                    } label: {
                        Label(LocalizationKeys.addCard.localized, systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
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
                        .frame(width: 48, height: 48)
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


}
#Preview {
    CardStackTab.ContentView()
}
