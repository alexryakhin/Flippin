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
            filtered = tagManager.filterCardsByDifficulty(filtered)
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
                FiltersScrollView(isMaterialBackground: true)

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
                        ActionButton(
                            LocalizationKeys.Navigation.shuffle.localized,
                            systemImage: "shuffle",
                            style: .borderedProminent
                        ) {
                            shuffleCards()
                        }

                        // Add card button
                        ActionButton(
                            LocalizationKeys.Navigation.addCardLabel.localized,
                            systemImage: "plus",
                            style: .borderedProminent
                        ) {
                            NavigationManager.shared.navigate(to: .addCard)
                        }
                    }
                    .if(isPad) { view in
                        view
                            .frame(maxWidth: 500, alignment: .center)
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
            .onChange(of: tagManager.isDifficultFilterOn) { _, _ in
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
            .onDisappear {
                LearningAnalyticsService.shared.endStudySession()
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
                } else if tagManager.isDifficultFilterOn {
                    noDifficultCardsView
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
                        Text(LocalizationKeys.Paywall.cardsUsedOfLimit.localized(with: cardsProvider.cards.count, cardsProvider.cardLimit))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ProgressView(value: Double(cardsProvider.cards.count), total: Double(cardsProvider.cardLimit))
                            .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                            .frame(height: 4)
                    }

                    Spacer()

                    HeaderButton(
                        LocalizationKeys.Paywall.upgrade.localized,
                        style: .borderedProminent
                    ) {
                        premiumFeature = .unlimitedCards
                    }
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
                        Image(.cardStackFill)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        Text(LocalizationKeys.Card.noCardsYet.localized)
                    }
                } description: {
                    Text(LocalizationKeys.Card.tapToAddFirstCard.localized)
                        .foregroundStyle(.secondary)
                } actions: {
                    HeaderButton(
                        LocalizationKeys.Card.addCard.localized,
                        icon: "plus",
                        style: .borderedProminent
                    ) {
                        NavigationManager.shared.navigate(to: .addCard)
                    }
                }
                .foregroundColor(colorManager.foregroundColor)

                FeaturedPresetCollections()
            }
        }

        @ViewBuilder
        private var noCardsWithTagsView: some View {
            if let selectedFilterTag = tagManager.selectedFilterTag {
                ContentUnavailableView {
                    VStack {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                        Text(LocalizationKeys.Card.noCardsWithSelectedTag.localized)
                    }
                } description: {
                    Text(LocalizationKeys.Card.noCardsFoundWithTag.localized(with: selectedFilterTag.name.orEmpty))
                        .foregroundStyle(.secondary)
                } actions: {
                    HeaderButton(
                        LocalizationKeys.General.clearFilter.localized,
                        style: .borderedProminent
                    ) {
                        HapticService.shared.buttonTapped()
                        tagManager.clearFilter()
                    }
                }
                .foregroundColor(colorManager.foregroundColor)
            }
        }

        private var filteredByLanguageCardsEmptyView: some View {
            ContentUnavailableView {
                VStack {
                    Image(.cardStackFill)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                    Text(LocalizationKeys.Card.noCardsYet.localized)
                }
            } description: {
                Text(LocalizationKeys.Card.noCardsForLanguagePair.localized)
                    .foregroundStyle(.secondary)
            }
            .foregroundColor(colorManager.foregroundColor)
        }

        private var noFavoriteCardsView: some View {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "heart")
                        .font(.largeTitle)
                    Text(LocalizationKeys.Settings.noFavoriteCards.localized)
                }
            } description: {
                Text(LocalizationKeys.Settings.noFavoriteCardsDescription.localized)
                    .foregroundStyle(.secondary)
            }
            .foregroundColor(colorManager.foregroundColor)
        }
        
        private var noDifficultCardsView: some View {
            ContentUnavailableView {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text(LocalizationKeys.Card.noDifficultCards.localized)
                }
            } description: {
                Text(LocalizationKeys.Card.noDifficultCardsDescription.localized)
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
