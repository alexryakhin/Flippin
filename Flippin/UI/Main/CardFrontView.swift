//
//  CardFrontView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import Flow

struct CardFrontView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var cardsProvider: CardsProvider
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    let item: CardItem
    @State private var isPlayingTTS = false
    @EnvironmentObject private var colorManager: ColorManager

    var body: some View {
        VStack(spacing: 20) {
            let text = isTravelMode ? item.backText : item.frontText
            let language = isTravelMode ? item.backLanguage : item.frontLanguage

            HStack {
                Text(language.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                
                Button {
                    cardsProvider.toggleFavorite(for: item.id)
                } label: {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                }
                .tint(colorManager.adjustedTintColor(colorScheme))

                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(text)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if !item.notes.isEmpty {
                Text(item.notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if !item.tags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(colorManager.adjustedTintColor(colorScheme).opacity(0.1))
                            .foregroundStyle(colorManager.adjustedTintColor(colorScheme))
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Spacer()

            HStack {
                if !isTravelMode {
                    Button {
                        // Haptic feedback for TTS start
                        HapticService.shared.ttsStarted()

                        isPlayingTTS = true
                        Task {
                            do {
                                try await TTSPlayer.shared.play(text, language: language)
                            } catch {
                                print("TTS error: \(error)")
                            }
                            isPlayingTTS = false
                        }
                    } label: {
                        Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .tint(colorManager.adjustedTintColor(colorScheme))
                }

                Spacer()

                Text(LocalizationKeys.showAnswer.localized)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
