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
    
    var filteredCards: [CardItem] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter { card in
                card.frontText.localizedCaseInsensitiveContains(searchText) ||
                card.backText.localizedCaseInsensitiveContains(searchText) ||
                card.frontLanguage.displayName.localizedCaseInsensitiveContains(searchText) ||
                card.backLanguage.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "rectangle.stack")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No cards yet")
                        }
                    } description: {
                        Text("Add your first card to start learning")
                    } actions: {
                        Button("Add Card") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(filteredCards) { card in
                            CardRowView(card: card) {
                                deleteCard(card)
                            }
                        }
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
                        Button("Clear All") {
                            cardToDelete = nil
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
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
    }
    
    private func deleteCard(_ card: CardItem) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            modelContext.delete(card)
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

struct CardRowView: View {
    let card: CardItem
    let onDelete: () -> Void
    
    @State private var isFlipped = false
    @State private var isPlayingTTS = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(card.frontLanguage.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(card.backLanguage.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    
                    Text(card.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text(card.frontText)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {
                        isPlayingTTS = true
                        Task {
                            do {
                                try await TTSPlayer.shared.play(card.frontText, language: card.frontLanguage)
                            } catch {
                                print("TTS error: \(error)")
                            }
                            isPlayingTTS = false
                        }
                    }) {
                        Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if isFlipped {
                    Divider()
                    
                    HStack {
                        Text(card.backText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: {
                            isPlayingTTS = true
                            Task {
                                do {
                                    try await TTSPlayer.shared.play(card.backText, language: card.backLanguage)
                                } catch {
                                    print("TTS error: \(error)")
                                }
                                isPlayingTTS = false
                            }
                        }) {
                            Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                if let notes = card.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped.toggle()
            }
        }
    }
}
