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
    @EnvironmentObject private var cardsProvider: CardsProvider
    @StateObject private var colorManager = ColorManager()

    let item: CardItem
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                
                Button(action: {
                    cardsProvider.toggleFavorite(for: item.id)
                }) {
                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(item.isFavorite ? .red : .secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Text(item.backText)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if !item.tags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(item.tags, id: \.self) { tag in
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
