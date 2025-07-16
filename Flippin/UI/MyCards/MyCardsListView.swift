//
//  MyCardsListView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct MyCardsListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var cardsProvider: CardsProvider
    @EnvironmentObject private var languageManager: LanguageManager
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var cardToDelete: CardItem?
    @EnvironmentObject private var tagManager: TagManager
    @State private var showingTagFilter = false
    @State private var showAddCardSheet = false

    let onToSettings: () -> Void

    var filteredCards: [CardItem] {
        var filtered = cardsProvider.cards
        
        // Apply language filter first
        filtered = languageManager.filterCards(filtered)
        
        if !searchText.isEmpty {
            filtered = filtered.filter { card in
                card.frontText.localizedCaseInsensitiveContains(searchText) ||
                card.backText.localizedCaseInsensitiveContains(searchText) ||
                card.notes.localizedCaseInsensitiveContains(searchText) ||
                card.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        if !tagManager.currentFilterTag.isEmpty {
            filtered = tagManager.filterCards(filtered, by: tagManager.currentFilterTag)
        }
        
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        NavigationView {
            VStack {
                if cardsProvider.cards.isEmpty {
                    noCardsView
                } else if filteredCards.isEmpty {
                    if languageManager.filterByLanguage {
                        filteredByLanguageCardsEmptyView
                    } else if tagManager.currentFilterTag.isEmpty {
                        noCardsFoundView
                    } else {
                        noCardsWithTagsView
                    }
                } else {
                    List {
                        ForEach(filteredCards) { card in
                            CardRowView(card: card) {
                                cardToDelete = card
                                showingDeleteAlert = true
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(
                text: $searchText,
                prompt: LocalizationKeys.searchCards.localized
            )
            .navigationTitle(LocalizationKeys.myCards.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationKeys.close.localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section {
                            Button {
                                showingTagFilter = true
                            } label: {
                                Label(LocalizationKeys.filterByTag.localized, systemImage: "tag")
                            }
                        }
                        if !filteredCards.isEmpty {
                            Section {
                                Button(role: .destructive) {
                                    cardToDelete = nil
                                    showingDeleteAlert = true
                                } label: {
                                    Label(LocalizationKeys.deleteAllCards.localized, systemImage: "trash")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet { newCard in
                cardsProvider.addCard(newCard)
            }
        }
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView {
                onToSettings()
            }
            .environmentObject(tagManager)
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
        .alert(cardToDelete == nil ? LocalizationKeys.deleteAllCards.localized : LocalizationKeys.deleteCard.localized, isPresented: $showingDeleteAlert) {
            Button(LocalizationKeys.delete.localized, role: .destructive) {
                if let card = cardToDelete {
                    deleteCard(card)
                } else {
                    deleteAllCards()
                }
            }
            Button(LocalizationKeys.cancel.localized, role: .cancel) {}
        } message: {
            Text(cardToDelete == nil ? LocalizationKeys.deleteAllCardsConfirmation.localized : LocalizationKeys.deleteCardConfirmation.localized)
        }
    }

    private var noCardsView: some View {
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
    }

    private var noCardsFoundView: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                Text(LocalizationKeys.noCardsFound.localized)
            }
        } description: {
            Text(LocalizationKeys.noCardsMatchSearch.localized)
                .foregroundStyle(.secondary)
        }
    }

    private var noCardsWithTagsView: some View {
        ContentUnavailableView {
            VStack {
                Image(systemName: "tag")
                    .font(.largeTitle)
                Text(LocalizationKeys.noCardsWithSelectedTag.localized)
            }
        } description: {
            Text(LocalizationKeys.noCardsFoundWithTag.localized(with: tagManager.currentFilterTag))
                .foregroundStyle(.secondary)
        } actions: {
            Button(LocalizationKeys.clearFilter.localized) {
                tagManager.clearFilter()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func deleteCard(_ card: CardItem) {
        AnalyticsService.trackCardEvent(
            .cardDeleted,
            cardLanguage: card.frontLanguage.rawValue,
            hasTags: !card.tags.isEmpty,
            tagCount: card.tags.count
        )
        cardsProvider.deleteCard(with: card.id)
    }
    
    private func deleteAllCards() {
        AnalyticsService.trackEvent(.allCardsDeleted)
        cardsProvider.deleteAllCards()
    }
}
