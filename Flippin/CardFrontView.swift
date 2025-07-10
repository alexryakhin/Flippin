//
//  CardFrontView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardFrontView: View {
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = "#4A90E2" // Default blue
    @Environment(\.colorScheme) private var colorScheme

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }

    let item: CardItem
    @State private var isPlayingTTS = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.frontLanguage.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(item.frontText)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            Spacer()
            HStack {
                Button(action: {
                    isPlayingTTS = true
                    Task {
                        do {
                            try await TTSPlayer.shared.play(item.frontText, language: item.frontLanguage)
                        } catch {
                            print("TTS error: \(error)")
                        }
                        isPlayingTTS = false
                    }
                }) {
                    Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(16)
                }
                .tint(adjustedTintColor)

                Spacer()

                Text("Show answer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

extension CardFrontView {
    var adjustedTintColor: Color {
        let baseColor = userGradientColor

        switch (colorScheme, baseColor.isLight) {
        case (.dark, false): return userGradientColor.lighter(by: 50)
        case (.light, true): return userGradientColor.darker(by: 50)
        default: return userGradientColor
        }
    }
}
