//
//  CardBackView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import Flow

struct CardBackView: View {
    let item: CardItem
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage?.displayName ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if let timestamp = item.timestamp {
                    Text(timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(item.backText ?? "")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            
            if let tags = item.tags, !tags.isEmpty {
                HFlow(spacing: 6) {
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
            }
            
            Spacer()
            Text("Tap to go back")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
