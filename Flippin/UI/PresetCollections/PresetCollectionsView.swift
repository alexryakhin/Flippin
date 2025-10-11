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
    @StateObject private var purchaseService = PurchaseService.shared

    @State private var searchText = ""
    @State private var selectedCategory: PresetModel.Category?
    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    @State private var lastSearchText = ""
    @State private var showingPaywall = false

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
                VStack(spacing: 16) {
                    // AI Generator Button
                    aiGeneratorButton
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
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
                    .padding(.bottom, 12)
                }
            }
            .groupedBackground()
            .navigation(
                title: Loc.PresetCollections.presetCollections,
                mode: .inline,
                showsBackButton: true,
                bottomContent: {
                    VStack(spacing: 8) {
                        InputView.searchView(
                            Loc.PresetCollections.searchCollections,
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
                            Text(Loc.PresetCollections.noCollectionsFound)
                        }
                    } description: {
                        Text(Loc.PresetCollections.tryAdjustingSearch)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .alert(Loc.PresetCollections.importCollection, isPresented: $showingImportAlert) {
            Button(Loc.Buttons.cancel, role: .cancel) { }
            Button(Loc.PresetCollections.importButton) {
                if let collection = collectionToImport {
                    importCollection(collection)
                }
            }
        } message: {
            if let collection = collectionToImport {
                Text(Loc.PresetCollections.importCollectionMessage(collection.name, collection.cardCount))
            }
        }
        .sheet(isPresented: $showingPaywall) {
            Paywall.ContentView()
        }
    }
    
    // MARK: - AI Generator Button
    
    private var aiGeneratorButton: some View {
        NavigationLink(destination: AICollectionGeneratorView()) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("AI Collection Generator")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !purchaseService.hasPremiumAccess {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text("Premium")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(6)
                        }
                    }
                    
                    Text("Create custom collections with AI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(.thinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.yellow.opacity(0.5), lineWidth: 2)
            )
        }
        .simultaneousGesture(TapGesture().onEnded {
            if !purchaseService.hasPremiumAccess {
                showingPaywall = true
                AnalyticsService.trackEvent(.aiFeaturePaywallShown)
            }
        })
    }

    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                TagView(
                    title: Loc.PresetCollections.allCategories,
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
