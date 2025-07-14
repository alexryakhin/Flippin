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
    @StateObject private var colorManager = ColorManager()

    let item: CardItem
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage?.displayName ?? LocalizationKeys.english.localized)
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

            Text(item.backText ?? "")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if let tags = item.tags, !tags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
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

            Text(LocalizationKeys.tapToGoBack.localized)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
