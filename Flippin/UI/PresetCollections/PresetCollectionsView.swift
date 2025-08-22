//
//  PresetCollectionsView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct PresetCollectionsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var presetService = PresetCollectionService.shared

    @State private var searchText = ""
    @State private var selectedCategory: PresetModel.Category?
    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    @State private var lastSearchText = ""

    var filteredCollections: [PresetCollection] {
        var collections: [PresetCollection] = presetService.collections

        if !searchText.isEmpty {
            collections = collections.filter { collection in
                collection.name.localizedCaseInsensitiveContains(searchText) ||
                collection.description.localizedCaseInsensitiveContains(searchText) ||
                collection.cards.contains { card in
                    card.backText.localizedCaseInsensitiveContains(searchText)
                }
            }
            // Track search if it's a new search
            if lastSearchText != searchText {
                AnalyticsService.trackSearchEvent(.searchPerformed, searchTerm: searchText, resultCount: collections.count)
                lastSearchText = searchText
            }
        } else if !lastSearchText.isEmpty {
            AnalyticsService.trackSearchEvent(
                .searchCleared,
                searchTerm: lastSearchText,
                resultCount: collections.count
            )
            lastSearchText = ""
        }

        if let selectedCategory {
            collections = collections.filter { $0.category.rawValue == selectedCategory.rawValue }
        }

        return collections
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(filteredCollections) { collection in
                        PresetCollectionCard(collection: collection) {
                            collectionToImport = collection
                            showingImportAlert = true
                        }
                        .clippedWithPaddingAndBackground()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigation(
                title: LocalizationKeys.Presets.presetCollections.localized,
                mode: .inline(withBackButton: true),
                bottomContent: {
                    VStack(spacing: 8) {
                        InputView.searchView(
                            LocalizationKeys.Presets.searchCollections.localized,
                            searchText: $searchText
                        )
                        categoryFilterView
                    }
                }
            )
            .overlay {
                if filteredCollections.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(.cardStackFill)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                            Text(LocalizationKeys.Presets.noCollectionsFound.localized)
                        }
                    } description: {
                        Text(LocalizationKeys.Presets.tryAdjustingSearch.localized)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .alert(LocalizationKeys.Presets.importCollection.localized, isPresented: $showingImportAlert) {
            Button(LocalizationKeys.General.cancel.localized, role: .cancel) { }
            Button(LocalizationKeys.Presets.importButton.localized) {
                if let collection = collectionToImport {
                    importCollection(collection)
                }
            }
        } message: {
            if let collection = collectionToImport {
                Text(LocalizationKeys.Presets.importCollectionMessage.localized(with: collection.name, collection.cardCount))
            }
        }
    }

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagView(
                    title: LocalizationKeys.Presets.allCategories.localized,
                    isSelected: selectedCategory == nil
                )
                .onTap {
                    selectedCategory = nil
                }

                ForEach(PresetModel.Category.allCases, id: \.self) { category in
                    TagView(
                        title: category.displayTitle,
                        imageSystemName: category.icon,
                        isSelected: selectedCategory?.rawValue == category.rawValue
                    )
                    .onTap {
                        selectedCategory = selectedCategory?.rawValue == category.rawValue ? nil : category
                    }
                }
            }
        }
        .scrollClipDisabled()
    }

    private func importCollection(_ collection: PresetCollection) {
        try? cardsProvider.addPresetCards(collection.cards)

        // Show success feedback
        HapticService.shared.success()

        // Analytics tracking for preset collection import
        AnalyticsService.trackPresetCollectionEvent(
            .presetCollectionImported,
            collectionName: collection.name,
            cardCount: collection.cardCount,
            category: collection.category.rawValue
        )
    }
}
