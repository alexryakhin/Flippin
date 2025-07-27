//
//  FeaturedPresetCollections.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct FeaturedPresetCollections: View {
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
    @State private var premiumFeature: PremiumFeature?

    var featuredCollections: [PresetCollection] {
        presetService.getFeaturedCollections()
    }

    var bgStyle = SectionBgStyle.material

    var body: some View {
        if !featuredCollections.isEmpty {
            CustomSectionView(
                header: LocalizationKeys.presetCollections.localized,
                headerFontStyle: .bold,
                backgroundStyle: bgStyle
            ) {
                VStack(alignment: .leading, spacing: 16) {
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
            } trailingContent: {
                Button(LocalizationKeys.seeAllCollections.localized) {
                    if purchaseService.hasPremiumAccess {
                        showingAllCollections = true
                        AnalyticsService.trackEvent(.presetCollectionsOpened)
                    } else {
                        premiumFeature = .cardPresets
                    }
                }
                .foregroundStyle(colorManager.borderedProminentForegroundColor)
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
            .sheet(isPresented: $showingAllCollections) {
                PresetCollectionsView()
            }
            .premiumAlert(feature: $premiumFeature)
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
