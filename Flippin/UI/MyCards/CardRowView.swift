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
    
    @State private var isFlipped = false
    @State private var isPlayingTTS = false
    
    var body: some View {
        let text = isFlipped ? (card.backText ?? "") : (card.frontText ?? "")
        let language = isFlipped ? (card.backLanguage ?? .english) : (card.frontLanguage ?? .english)

        VStack(spacing: 8) {
            HStack {
                Text(language.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let timestamp = card.timestamp {
                    Text(timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
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
                        } catch {
                            print("TTS error: \(error)")
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

            if let notes = card.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            if let tags = card.tags, !tags.isEmpty {
                HFlow(spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
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
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFlipped.toggle()
            }
        }
    }
}
