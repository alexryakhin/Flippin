//
//  FiltersScrollView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/20/25.
//

import SwiftUI

/**
 Horizontal scrollable filter buttons for card filtering.
 Displays "Show All", "Favorites", and tag-specific filter options.
 Supports smooth scrolling with view-aligned behavior.
 */
struct FiltersScrollView: View {
    // MARK: - State Objects
    
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Show all cards filter
                TagButton(
                    title: LocalizationKeys.showAllCards,
                    isSelected: tagManager.selectedFilterTag == nil && !tagManager.isFavoriteFilterOn
                ) {
                    tagManager.selectedFilterTag = nil
                    tagManager.isFavoriteFilterOn = false
                }

                // Favorite filter button
                TagButton(
                    title: LocalizationKeys.showFavoritesOnly,
                    imageSystemName: "heart.fill",
                    isSelected: tagManager.isFavoriteFilterOn
                ) {
                    tagManager.isFavoriteFilterOn.toggle()
                }

                // Tag filter buttons
                ForEach(tagManager.availableTags, id: \.self) { tag in
                    let isSelected = tagManager.selectedFilterTag == tag
                    TagButton(
                        title: tag.name.orEmpty,
                        imageSystemName: "tag.fill",
                        isSelected: isSelected
                    ) {
                        tagManager.selectedFilterTag = isSelected ? nil : tag
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollClipDisabled()
    }
}
