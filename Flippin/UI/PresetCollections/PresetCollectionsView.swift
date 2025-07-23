//
//  PresetCollectionsView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct PresetCollectionsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var presetService = PresetCollectionService.shared
    @StateObject private var purchaseService = PurchaseService.shared

    @State private var searchText = ""
    @State private var selectedCategory: PresetModel.Category?
    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    @State private var lastSearchText = ""
    @State private var showPaywall = false

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
        Group {
            if purchaseService.hasPremiumAccess {
                collectionsView
            } else {
                paywallPromptView
            }
        }
        .sheet(isPresented: $showPaywall) {
            Paywall.ContentView()
        }
    }
    
    private var collectionsView: some View {
        NavigationView {
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
                .safeAreaInset(edge: .top) {
                    VStack(spacing: 0) {
                        categoryFilterView
                            .padding(.bottom, 12)
                        Divider()
                    }
                    .background(.ultraThinMaterial)
                }
                .overlay {
                    if filteredCollections.isEmpty {
                        ContentUnavailableView {
                            VStack {
                                Image(systemName: "rectangle.stack")
                                    .font(.largeTitle)
                                Text(LocalizationKeys.noCollectionsFound.localized)
                            }
                        } description: {
                            Text(LocalizationKeys.tryAdjustingSearch.localized)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(LocalizationKeys.presetCollections.localized)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: LocalizationKeys.searchCollections.localized
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .alert(LocalizationKeys.importCollection.localized, isPresented: $showingImportAlert) {
            Button(LocalizationKeys.cancel.localized, role: .cancel) { }
            Button(LocalizationKeys.importButton.localized) {
                if let collection = collectionToImport {
                    importCollection(collection)
                }
            }
        } message: {
            if let collection = collectionToImport {
                Text(LocalizationKeys.importCollectionMessage.localized(with: collection.name, collection.cardCount))
            }
        }
    }
    
    private var paywallPromptView: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    Text(LocalizationKeys.premiumFeature.localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(LocalizationKeys.premiumFeatureDescription.localized)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button(LocalizationKeys.upgradeToPremium.localized) {
                    showPaywall = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button(LocalizationKeys.cancel.localized) {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(16)
            .navigationTitle(LocalizationKeys.premiumRequired.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagButton(title: LocalizationKeys.allCategories.localized, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(PresetModel.Category.allCases, id: \.self) { category in
                    TagButton(
                        title: category.displayTitle,
                        imageSystemName: category.icon,
                        isSelected: selectedCategory?.rawValue == category.rawValue
                    ) {
                        selectedCategory = selectedCategory?.rawValue == category.rawValue ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
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
