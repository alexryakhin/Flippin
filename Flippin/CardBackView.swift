//
//  CardBackView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardBackView: View {
    let item: CardItem
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(item.backText)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            Spacer()
            Text("Tap to go back")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
