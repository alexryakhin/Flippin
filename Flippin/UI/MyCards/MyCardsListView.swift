//
//  MyCardsListView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import SwiftData

struct MyCardsListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CardItem.timestamp, order: .reverse) private var cards: [CardItem]
    
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var cardToDelete: CardItem?
    @StateObject private var tagManager = TagManager()
    @State private var showingTagFilter = false

    let onAddCard: () -> Void
    let onToSettings: () -> Void

    var filteredCards: [CardItem] {
        var filtered = cards
        
        // Apply tag filter first
        if !tagManager.currentFilterTag.isEmpty {
            filtered = tagManager.filterCards(filtered, by: tagManager.currentFilterTag)
        }
        
        // Then apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { card in
                (card.frontText ?? "").localizedCaseInsensitiveContains(searchText) ||
                (card.backText ?? "").localizedCaseInsensitiveContains(searchText) ||
                (card.frontLanguage?.displayName ?? "").localizedCaseInsensitiveContains(searchText) ||
                (card.backLanguage?.displayName ?? "").localizedCaseInsensitiveContains(searchText) ||
                (card.tags?.joined(separator: " ") ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "rectangle.stack.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .rotationEffect(.init(degrees: 90))
                            Text("No cards yet")
                        }
                    } description: {
                        Text("Add your first card to start learning")
                    } actions: {
                        Button("Add Card") {
                            onAddCard()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if filteredCards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "tag")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No cards with selected tag")
                        }
                    } description: {
                        if !tagManager.currentFilterTag.isEmpty {
                            Text("No cards found with tag \"\(tagManager.currentFilterTag)\"")
                        } else {
                            Text("No cards match your search")
                        }
                    } actions: {
                        if !tagManager.currentFilterTag.isEmpty {
                            Button("Clear Filter") {
                                tagManager.clearFilter()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        if !searchText.isEmpty {
                            Button("Clear Search") {
                                searchText = ""
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else {
                    List {
                        ForEach(filteredCards) { card in
                            CardRowView(card: card)
                        }
                        .onDelete(perform: deleteCards)
                    }
                    .searchable(text: $searchText, prompt: "Search cards...")
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !cards.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        HStack {
                            Button {
                                showingTagFilter = true
                            } label: {
                                Image(systemName: "tag")
                                    .foregroundStyle(tagManager.currentFilterTag.isEmpty ? .secondary : .primary)
                            }
                            
                            Button("Clear All", role: .destructive) {
                                cardToDelete = nil
                                showingDeleteAlert = true
                            }
                            .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .alert("Delete All Cards", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllCards()
            }
        } message: {
            Text("Are you sure you want to delete all cards? This action cannot be undone.")
        }
        .sheet(isPresented: $showingTagFilter) {
            TagFilterView(tagManager: tagManager, onToSettings: onToSettings)
        }
    }
    
    private func deleteCards(offsets: IndexSet) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            for index in offsets {
                modelContext.delete(filteredCards[index])
            }
        }
    }
    
    private func deleteAllCards() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            for card in cards {
                modelContext.delete(card)
            }
        }
    }
}
