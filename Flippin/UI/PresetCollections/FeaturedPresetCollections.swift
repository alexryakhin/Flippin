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

    @State private var showingImportAlert = false
    @State private var collectionToImport: PresetCollection?
    @State private var showingLimitAlert = false
    @State private var limitAlertMessage = ""

    @Binding var premiumFeature: PremiumFeature?

    var featuredCollections: [PresetCollection] {
        presetService.getFeaturedCollections()
    }

    var bgStyle = SectionBgStyle.material

    var body: some View {
        if !featuredCollections.isEmpty {
            CustomSectionView(
                header: Loc.PresetCollections.presetCollections,
                headerFontStyle: .large,
                backgroundStyle: bgStyle
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Loc.PresetCollections.getStartedWithCollections)
                        .font(.caption)
                        .foregroundStyle(.secondary)

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
                HeaderButton(Loc.PresetCollections.seeAllCollections, style: .borderedProminent) {
                    if purchaseService.hasPremiumAccess {
                        NavigationManager.shared.navigate(to: .presetCollections)
                        AnalyticsService.trackEvent(.presetCollectionsOpened)
                    } else {
                        premiumFeature = .cardPresets
                    }
                }
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
            .alert(Loc.CardLimits.unlimitedCards, isPresented: $showingLimitAlert) {
                Button(Loc.Buttons.ok, role: .cancel) { }
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
