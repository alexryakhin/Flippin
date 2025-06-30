//
//  CardFrontView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardFrontView: View {
    let item: Item
    @State private var isPlayingTTS = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.frontLanguage.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(item.frontText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            Spacer()
            HStack {
                Button(action: {
                    isPlayingTTS = true
                    Task {
                        do {
                            try await TTSPlayer.shared.play(item.frontText)
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
                        .padding(8)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                Spacer()
                Text("Show answer")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}
