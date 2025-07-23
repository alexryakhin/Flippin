//
//  PresetCollectionCard.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct PresetCollectionCard: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager.shared

    let collection: PresetCollection
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: collection.systemImageName)
                    .font(.title2)
                    .foregroundColor(colorManager.tintColor)

                Spacer()

                Text("\(collection.cardCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(collection.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text(collection.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }

            // Preview of first few cards
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(collection.cards.prefix(3).enumerated()), id: \.offset) { index, card in
                    HStack {
                        Text("•")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(card.backText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        Spacer()
                    }
                }

                if collection.cards.count > 3 {
                    Text("+ \(collection.cards.count - 3) more")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .contentShape(.rect)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .onTapGesture {
            HapticService.shared.buttonTapped()
            
            // Analytics tracking for preset collection viewed
            AnalyticsService.trackPresetCollectionEvent(
                .presetCollectionViewed,
                collectionName: collection.name,
                cardCount: collection.cardCount,
                category: collection.category.rawValue
            )
            
            onTap()
        }
    }
}
