//
//  MyCardsListView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

// MARK: - Language Group Structure
struct LanguageGroup: Identifiable {
    let id = UUID()
    let language: Language
    let cards: [CardItem]
}

struct MyCardsListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var tagManager = TagManager.shared

    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var cardToDelete: CardItem?
    @State private var cardToEdit: CardItem?
    @State private var showingTagFilter = false
    @State private var showAddCardSheet = false
    @State private var lastSearchText = ""

    var filteredCards: [CardItem] {
        var filtered = cardsProvider.cards

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { card in
                card.frontText.orEmpty.localizedCaseInsensitiveContains(searchText) ||
                card.backText.orEmpty.localizedCaseInsensitiveContains(searchText) ||
                card.notes.orEmpty.localizedCaseInsensitiveContains(searchText) ||
                card.tagNames.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }

            // Track search if it's a new search
            if lastSearchText != searchText {
                AnalyticsService.trackSearchEvent(.searchPerformed, searchTerm: searchText, resultCount: filtered.count)
                lastSearchText = searchText
            }
        } else if !lastSearchText.isEmpty {
            // Track search cleared
            AnalyticsService.trackSearchEvent(.searchCleared, searchTerm: lastSearchText, resultCount: cardsProvider.cards.count)
            lastSearchText = ""
        }

        // Apply language filter first
        filtered = languageManager.filterCards(filtered)

        if let selectedFilterTag = tagManager.selectedFilterTag {
            filtered = tagManager.filterCards(filtered, by: selectedFilterTag)
        }
        filtered = tagManager.filterCardsByFavorite(filtered)
        filtered = tagManager.filterCardsByDifficulty(filtered)

        return filtered.sorted { $0.timestamp.orNow > $1.timestamp.orNow }
    }

    // Group cards by target language when language filter is off
    var groupedCards: [LanguageGroup] {
        guard !languageManager.filterByLanguage else {
            // If language filter is on, return single group
            return [LanguageGroup(language: languageManager.targetLanguage, cards: filteredCards)]
        }

        // Group cards by target language
        let grouped = Dictionary(grouping: filteredCards) { card in
            card.frontLanguage
        }

        // Convert to sorted array of LanguageGroup
        return grouped.compactMap { language, cards in
            guard let language else { return nil }
            return LanguageGroup(
                language: language,
                cards: cards.sorted {
                    $0.timestamp.orNow < $1.timestamp.orNow
                }
            )
        }.sorted { group1, group2 in
            // Sort groups by language display name
            group1.language.displayName < group2.language.displayName
        }
    }

    var body: some View {
        VStack {
            if cardsProvider.cards.isEmpty {
                noCardsView
            } else if groupedCards.isEmpty {
                if tagManager.isFavoriteFilterOn {
                    noFavoriteCardsView
                } else if tagManager.isDifficultFilterOn {
                    noDifficultCardsView
                } else if languageManager.filterByLanguage {
                    filteredByLanguageCardsEmptyView
                } else if tagManager.selectedFilterTag == nil {
                    noCardsFoundView
                } else {
                    noCardsWithTagsView
                }
            } else {
                List {
                    ForEach(groupedCards) { group in
                        Section {
                            ForEach(group.cards) { card in
                                CardRowView(
                                    card: card,
                                    onDelete: {
                                        cardToDelete = card
                                        showingDeleteAlert = true
                                    },
                                    onEdit: {
                                        cardToEdit = card
                                    }
                                )
                            }
                        } header: {
                            Text(group.language.displayName)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .if(isPad) { view in
            view.frame(maxWidth: 500, alignment: .center)
        }
        .navigation(
            title: LocalizationKeys.Navigation.myCards.localized,
            mode: .inline,
            clipMode: .rectangle,
            trailingContent: {
                HStack(spacing: 4) {
                    Button {
                        showAddCardSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(colorManager.borderedProminentForegroundColor)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())
                }
            },
            bottomContent: {
                VStack(spacing: 8) {
                    InputView.searchView(
                        LocalizationKeys.General.searchCards.localized,
                        searchText: $searchText
                    )
                    FiltersScrollView()
                }
            }
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .onAppear {
            AnalyticsService.trackEvent(.myCardsScreenOpened)
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet()
        }
        .sheet(item: $cardToEdit) {
            cardsProvider.objectWillChange.send()
        } content: { card in
            EditCardSheet(card: card)
        }
        .alert(cardToDelete == nil ? LocalizationKeys.Card.deleteAllCards.localized : LocalizationKeys.Card.deleteCard.localized, isPresented: $showingDeleteAlert) {
            Button(LocalizationKeys.General.delete.localized, role: .destructive) {
                if let card = cardToDelete {
                    deleteCard(card)
                } else {
                    deleteAllCards()
                }
            }
            Button(LocalizationKeys.General.cancel.localized, role: .cancel) {}
        } message: {
            Text(cardToDelete == nil ? LocalizationKeys.Card.deleteAllCardsConfirmation.localized : LocalizationKeys.Card.deleteCardConfirmation.localized)
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
            }

            FeaturedPresetCollections()
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
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
    }

    private var noCardsFoundView: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                Text(LocalizationKeys.Card.noCardsFound.localized)
            }
        } description: {
            Text(LocalizationKeys.Card.noCardsMatchSearch.localized)
                .foregroundStyle(.secondary)
        }
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
                Button(LocalizationKeys.General.clearFilter.localized) {
                    HapticService.shared.buttonTapped()
                    tagManager.clearFilter()
                    AnalyticsService.trackFilterEvent(.tagFilterCleared, filterType: "tag", filterValue: "")
                }
                .foregroundStyle(colorManager.borderedProminentForegroundColor)
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
        }
    }

    private func deleteCard(_ card: CardItem) {
        AnalyticsService.trackCardEvent(
            .cardDeleted,
            cardLanguage: card.frontLanguage?.rawValue,
            hasTags: !card.tagNames.isEmpty,
            tagCount: card.tagNames.count
        )
        cardsProvider.deleteCard(card)
    }

    private func deleteAllCards() {
        AnalyticsService.trackEvent(.allCardsDeleted)
        cardsProvider.deleteAllCards()
    }
}

