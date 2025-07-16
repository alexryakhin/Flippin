//
//  CardRowView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI
import Flow

struct CardRowView: View {
    let card: CardItem
    let onDelete: () -> Void
    @EnvironmentObject private var cardsProvider: CardsProvider
    
    @State private var isFlipped = false
    @State private var isPlayingTTS = false
    
    var body: some View {
        let text = isFlipped ? card.backText : card.frontText
        let language = isFlipped ? card.backLanguage : card.frontLanguage

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(language.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
                
                Button {
                    cardsProvider.toggleFavorite(for: card.id)
                } label: {
                    Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(card.isFavorite ? .red : .secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Text(card.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(text)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Button {
                    isPlayingTTS = true
                    Task {
                        do {
                            try await TTSPlayer.shared.play(text, language: language)
                            AnalyticsService.trackEvent(.cardPlayed)
                        } catch {
                            print("TTS error: \(error)")
                            AnalyticsService.trackErrorEvent(.ttsFailed, errorMessage: error.localizedDescription)
                        }
                        isPlayingTTS = false
                    }
                } label: {
                    Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if !card.notes.isEmpty {
                Text(card.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            if !card.tags.isEmpty {
                HFlow(spacing: 4) {
                    ForEach(card.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.accent.opacity(0.1))
                            .foregroundStyle(.accent)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                onDelete()
            } label: {
                Label(LocalizationKeys.delete.localized, systemImage: "trash")
            }
            .tint(.red)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped.toggle()
                
                // Track card flip event
                AnalyticsService.trackCardEvent(
                    .cardFlipped,
                    cardLanguage: card.frontText,
                    hasTags: !card.tags.isEmpty,
                    tagCount: card.tags.count
                )
            }
        }
    }
}
