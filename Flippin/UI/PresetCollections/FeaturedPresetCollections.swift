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
    @StateObject private var purchaseService = PurchaseService.shared

    @State private var showingAllCollections = false
    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    @State private var showingLimitAlert = false
    @State private var limitAlertMessage = ""
    @State private var showPaywall = false
    
    var featuredCollections: [PresetCollection] {
        presetService.getFeaturedCollections()
    }
    
    var body: some View {
        if !featuredCollections.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(LocalizationKeys.presetCollections.localized)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Button(LocalizationKeys.seeAllCollections.localized) {
                        if purchaseService.hasPremiumAccess {
                            showingAllCollections = true
                            AnalyticsService.trackNavigationEvent(.presetCollectionsOpened, screenName: "PresetCollections")
                        } else {
                            // Donate tip event and show paywall for free users
                            showPaywall = true
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(colorManager.tintColor)
                }

                Text(LocalizationKeys.getStartedWithCollections.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

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
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
            }
            .sheet(isPresented: $showingAllCollections) {
                PresetCollectionsView()
            }
            .sheet(isPresented: $showPaywall) {
                Paywall.ContentView()
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
            .alert(LocalizationKeys.cardLimitExceeded.localized, isPresented: $showingLimitAlert) {
                Button(LocalizationKeys.ok.localized, role: .cancel) { }
            } message: {
                Text(limitAlertMessage)
            }
        }
    }
    
    private func importCollection(_ collection: PresetCollection) {
        do {
            try cardsProvider.addPresetCards(collection.cards)

            // Show success feedback
            HapticService.shared.success()
            
            // Analytics tracking for preset collection import
            AnalyticsService.trackPresetCollectionEvent(
                .presetCollectionImported,
                collectionName: collection.name,
                cardCount: collection.cardCount,
                category: collection.category.rawValue
            )
        } catch let error as CardLimitError {
            limitAlertMessage = error.localizedDescription
            showingLimitAlert = true
        } catch {
            limitAlertMessage = "Failed to import collection: \(error.localizedDescription)"
            showingLimitAlert = true
        }
    }
} 
