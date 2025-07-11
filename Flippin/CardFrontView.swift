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
                Text(item.frontLanguage?.displayName ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let timestamp = item.timestamp {
                    Text(timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(item.frontText ?? "")
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
            
            if let tags = item.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            Spacer()
            HStack {
                Button(action: {
                    isPlayingTTS = true
                    Task {
                        do {
                            let text = item.frontText ?? ""
                            let language = item.frontLanguage ?? .english
                            try await TTSPlayer.shared.play(text, language: language)
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
