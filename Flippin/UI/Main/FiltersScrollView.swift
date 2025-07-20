//
//  FiltersScrollView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/20/25.
//

import SwiftUI

struct FiltersScrollView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                let isBlackForeground: Bool = colorScheme == .dark && colorManager.userGradientColor.isLight
                // Show All Cards button
                Button {
                    tagManager.selectedFilterTag = nil
                    tagManager.isFavoriteFilterOn = false
                } label: {
                    Text(LocalizationKeys.showAllCards.localized)
                        .font(.caption)
                        .foregroundStyle(
                            tagManager.selectedFilterTag == nil && !tagManager.isFavoriteFilterOn
                            ? isBlackForeground ? .black : .white
                            : .primary
                        )
                }
                .buttonStyle(.borderedProminent)
                .tint(
                    tagManager.selectedFilterTag == nil && !tagManager.isFavoriteFilterOn
                    ? colorManager.adjustedTintColor(colorScheme)
                    : Color(.systemGray4).opacity(0.8)
                )
                .clipShape(Capsule())

                // Favorite filter button
                Button {
                    tagManager.isFavoriteFilterOn.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                        Text(LocalizationKeys.showFavoritesOnly.localized)
                            .font(.caption)
                    }
                    .foregroundStyle(
                        tagManager.isFavoriteFilterOn
                        ? isBlackForeground ? .black : .white
                        : .primary
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(
                    tagManager.isFavoriteFilterOn
                    ? colorManager.adjustedTintColor(colorScheme)
                    : Color(.systemGray4).opacity(0.8)
                )
                .clipShape(Capsule())

                // Tag filter buttons
                ForEach(tagManager.availableTags, id: \.self) { tag in
                    let isSelected = tagManager.selectedFilterTag == tag
                    Button {
                        tagManager.selectedFilterTag = isSelected ? nil : tag
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption)
                            Text(tag.name.orEmpty)
                                .font(.caption)
                        }
                        .foregroundStyle(
                            isSelected
                            ? isBlackForeground ? .black : .white
                            : .primary
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        isSelected
                        ? colorManager.adjustedTintColor(colorScheme)
                        : Color(.systemGray4).opacity(0.8)
                    )
                    .clipShape(Capsule())
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
}
