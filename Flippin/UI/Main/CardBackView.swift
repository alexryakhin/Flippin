//
//  CardBackView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import Flow

struct CardBackView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false
    @State private var isPlayingTTS = false

    let card: CardItem

    var body: some View {
        VStack(spacing: 20) {
            let text = isTravelMode ? card.frontText : card.backText
            let language = isTravelMode ? card.frontLanguage : card.backLanguage

            HStack {
                if let language {
                    Text(language.displayName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button {
                    cardsProvider.toggleFavorite(card)
                } label: {
                    Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                }
            }
            Spacer()

            Text(text.orEmpty)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

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

            HStack {
                Button {
                    // Haptic feedback for TTS start
                    HapticService.shared.ttsStarted()

                    isPlayingTTS = true
                    Task {
                        do {
                            guard let text, let language else { return }
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

                Spacer()

                Text(LocalizationKeys.tapToGoBack.localized)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
