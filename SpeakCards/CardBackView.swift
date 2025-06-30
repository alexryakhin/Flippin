//
//  CardBackView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardBackView: View {
    let item: Item
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(item.backText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            Spacer()
            Text("Tap to go back")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}
