//
//  FeaturedPresetCollections.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct FeaturedPresetCollections: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared

    @StateObject private var presetService = PresetCollectionService.shared
    @State private var showingAllCollections = false
    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    
    var featuredCollections: [PresetCollection] {
        presetService.getFeaturedCollections(
            for: languageManager.userLanguage,
            targetLanguage: languageManager.targetLanguage
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(LocalizationKeys.presetCollections.localized)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
                
                Button(LocalizationKeys.seeAllCollections.localized) {
                    showingAllCollections = true
                }
                .font(.subheadline)
                .foregroundColor(colorManager.adjustedTintColor(colorScheme))
            }
            
            Text(LocalizationKeys.getStartedWithCollections.localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if featuredCollections.isEmpty {
                Text(LocalizationKeys.noCollectionsFound.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(featuredCollections) { collection in
                            PresetCollectionCard(collection: collection) {
                                collectionToImport = collection
                                showingImportAlert = true
                            }
                            .frame(width: 240)
                            .clippedWithPaddingAndBackground(
                                Color(.tertiarySystemGroupedBackground).opacity(0.6)
                            )
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .scrollClipDisabled()
            }
        }
        .clippedWithPaddingAndBackground()
        .sheet(isPresented: $showingAllCollections) {
            PresetCollectionsView()
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
    
    private func importCollection(_ collection: PresetCollection) {
        let cardItems = presetService.convertPresetCardsToCardItems(
            collection.cards,
            userLanguage: languageManager.userLanguage,
            targetLanguage: languageManager.targetLanguage
        )
        
        for card in cardItems {
            cardsProvider.addCard(card)
        }
        
        // Show success feedback
        HapticService.shared.success()
    }
} 
