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
    let onEdit: () -> Void

    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var ttsPlayer = TTSPlayer.shared
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false
    
    @State private var isFlipped = false

    var body: some View {
        let isTargetLanguage = isTravelMode != isFlipped
        let text = isTargetLanguage ? card.backText : card.frontText
        let language = isTargetLanguage ? card.backLanguage : card.frontLanguage

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let language {
                    Text(language.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button {
                    cardsProvider.toggleFavorite(card)
                } label: {
                    Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(colorManager.tintColor)
                        .font(.caption)
                }
                .buttonStyle(.plain)

                Text(card.timestamp.orNow, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(text.orEmpty)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Button {
                    // Haptic feedback for TTS start
                    HapticService.shared.ttsStarted()
                    
                    Task {
                        do {
                            guard let text, let language else { return }
                            try await TTSPlayer.shared.play(text, language: language)
                            AnalyticsService.trackEvent(.cardPlayed)
                        } catch {
                            debugPrint("TTS error: \(error)")
                            AnalyticsService.trackErrorEvent(.ttsFailed, errorMessage: error.localizedDescription)
                        }
                    }
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(ttsPlayer.isPlaying)
            }

            if !card.notes.orEmpty.isEmpty {
                Text(card.notes.orEmpty)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            if !card.tagNames.isEmpty {
                HFlow(spacing: 4) {
                    ForEach(card.tagNames, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(colorManager.tintColor.opacity(0.1))
                            .foregroundStyle(colorManager.tintColor)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(.rect)
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                // Haptic feedback for swipe action
                HapticService.shared.swipeAction()
                onDelete()
            } label: {
                Label(Loc.Buttons.delete, systemImage: "trash")
            }
            .tint(.red)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                // Haptic feedback for swipe action
                HapticService.shared.swipeAction()
                onEdit()
            } label: {
                Label(Loc.Buttons.edit, systemImage: "pencil")
            }
        }
        .onTapGesture {
            // Haptic feedback for card flip
            HapticService.shared.cardFlipped()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped.toggle()
                
                // Track card flip event
                AnalyticsService.trackCardEvent(
                    .cardFlipped,
                    cardLanguage: card.frontText,
                    hasTags: !card.tagArray.isEmpty,
                    tagCount: card.tagArray.count
                )
            }
        }
        .contextMenu {
            Button {
                HapticService.shared.buttonTapped()
                onEdit()
            } label: {
                Label(Loc.Buttons.edit, systemImage: "pencil")
            }
            Button {
                HapticService.shared.buttonTapped()
                onDelete()
            } label: {
                Label(Loc.Buttons.delete, systemImage: "trash")
            }
            .tint(.red)
        }
    }
}
