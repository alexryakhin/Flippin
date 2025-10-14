//
//  CardFrontView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI
import Flow

/**
 Front view of a card displaying the main text content.
 Shows language name, main text, notes, tags, and TTS controls.
 Supports travel mode for reversed language display.
 */
struct CardFrontView: View {
    // MARK: - State Objects
    
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var learningAnalytics = LearningAnalyticsService.shared
    @StateObject private var ttsPlayer = TTSPlayer.shared

    // MARK: - App Storage
    
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    // MARK: - Properties
    
    let card: CardItem

    // MARK: - Computed Properties
    
    private var displayText: String {
        isTravelMode ? card.backText.orEmpty : card.frontText.orEmpty
    }
    
    private var displayLanguage: Language? {
        isTravelMode ? card.backLanguage : card.frontLanguage
    }
    
    private var difficultyLevel: Int16 {
        learningAnalytics.getCardPerformance(for: card.id)?.difficultyLevel ?? 3
    }
    
    private var difficultyColor: Color {
        let color: Color = switch difficultyLevel {
        case 1: .green
        case 2: .blue
        case 3: .orange
        case 4: .red
        case 5: .purple
        default: .gray
        }

        return color.opacity(0.5)
    }
    
    private var cardImageView: some View {
        CachedCardImageView(
            localPath: card.imageCacheURL,
            webUrl: card.imageURL,
            maxHeight: 200,
            cornerRadius: 12
        )
    }

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with language, difficulty, and favorite button
            HStack {
                if let language = displayLanguage {
                    Text(language.displayName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                // Difficulty indicator
                Image(systemName: "\(difficultyLevel).circle.fill")
                    .font(.headline)
                    .foregroundStyle(difficultyColor)

                Button {
                    cardsProvider.toggleFavorite(card)
                } label: {
                    Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                }
            }

            Spacer()

            // Main text content
            Text(displayText)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            // Image section
            if card.hasImage {
                cardImageView
            }

            // Notes section
            if !card.notes.orEmpty.isEmpty {
                Text(card.notes.orEmpty)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Tags section
            if !card.tagNames.isEmpty {
                HFlow(spacing: 6) {
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
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()

            // Footer with TTS and hint
            HStack {
                Button {
                    playTTS()
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .disabled(ttsPlayer.isPlaying)
                
                Spacer()

                Text(Loc.CardViews.flip)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions
    
    private func playTTS() {
        // Haptic feedback for TTS start
        HapticService.shared.ttsStarted()

        Task {
            do {
                guard let text = displayText.isEmpty ? nil : displayText,
                      let language = displayLanguage else { return }
                try await TTSPlayer.shared.play(text, language: language)
            } catch {
                debugPrint("TTS error: \(error)")
            }
        }
    }
}
