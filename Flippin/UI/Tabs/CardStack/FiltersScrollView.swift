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

    var isMaterialBackground: Bool = false

    // MARK: - State Objects
    
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Show all cards filter
                TagView(
                    title: Loc.TagManagement.showAllCards,
                    isSelected: tagManager.selectedFilterTag == nil && !tagManager.isFavoriteFilterOn && !tagManager.isDifficultFilterOn,
                    isMaterialBackground: isMaterialBackground
                )
                .onTap {
                    tagManager.selectedFilterTag = nil
                    tagManager.isFavoriteFilterOn = false
                    tagManager.isDifficultFilterOn = false
                }

                // Favorite filter button
                TagView(
                    title: Loc.TagManagement.showFavoritesOnly,
                    imageSystemName: "heart.fill",
                    isSelected: tagManager.isFavoriteFilterOn,
                    isMaterialBackground: isMaterialBackground
                )
                .onTap {
                    tagManager.isFavoriteFilterOn.toggle()
                }

                // Difficult cards filter button
                TagView(
                    title: Loc.CardManagement.difficultCards,
                    imageSystemName: "exclamationmark.triangle.fill",
                    isSelected: tagManager.isDifficultFilterOn,
                    isMaterialBackground: isMaterialBackground
                )
                .onTap {
                    tagManager.isDifficultFilterOn.toggle()
                }

                // Tag filter buttons
                ForEach(tagManager.availableTags, id: \.self) { tag in
                    let isSelected = tagManager.selectedFilterTag == tag
                    TagView(
                        title: tag.name.orEmpty,
                        imageSystemName: "tag.fill",
                        isSelected: isSelected,
                        isMaterialBackground: isMaterialBackground
                    )
                    .onTap {
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
