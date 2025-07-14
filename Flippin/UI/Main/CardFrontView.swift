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

    let item: CardItem
    @State private var isPlayingTTS = false
    @StateObject private var colorManager = ColorManager()

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

            Spacer()

            Text(item.frontText ?? "")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let tags = item.tags, !tags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(colorManager.adjustedTintColor.opacity(0.1))
                            .foregroundStyle(colorManager.adjustedTintColor)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
                }
                .tint(colorManager.adjustedTintColor)

                Spacer()

                Text("Show answer")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
