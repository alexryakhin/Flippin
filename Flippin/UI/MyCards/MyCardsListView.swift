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
    @StateObject private var tagManager = TagManager()
    @State private var showingTagFilter = false
    @State private var showAddCardSheet = false

    let onToSettings: () -> Void

    var filteredCards: [CardItem] {
        var filtered = cardsProvider.cards
        
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
            List {
                ForEach(filteredCards) { card in
                    CardRowView(card: card) {
                        cardToDelete = card
                        showingDeleteAlert = true
                    }
                }
            }
            .listStyle(.insetGrouped)
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
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            showingTagFilter = true
                        } label: {
                            HStack {
                                Image(systemName: "tag")
                                Text(tagManager.currentFilterTag.isEmpty
                                     ? LocalizationKeys.filterByTag.localized
                                     : tagManager.currentFilterTag
                                )
                            }
                        }
                        .foregroundColor(tagManager.currentFilterTag.isEmpty ? .primary : .blue)
                        
                        Spacer()
                        
                        if !filteredCards.isEmpty {
                            Button(LocalizationKeys.deleteAll.localized) {
                                cardToDelete = nil
                                showingDeleteAlert = true
                            }
                            .foregroundColor(.red)
                        }
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
            TagFilterView(tagManager: tagManager) {
                onToSettings()
            }
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
