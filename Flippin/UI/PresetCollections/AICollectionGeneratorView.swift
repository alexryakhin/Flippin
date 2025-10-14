//
//  AICollectionGeneratorView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

struct AICollectionGeneratorView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var chatGPTService = ChatGPTService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared

    @State private var userRequest = ""
    @State private var cardCount = 15
    @State private var generatedCollection: GeneratedCollection?
    @State private var editingCard: GeneratedCard?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPaywall = false

    private let cardCountOptions = [10, 15, 20]

    var body: some View {
        VStack(spacing: 0) {
            if generatedCollection == nil {
                requestInputView
            } else {
                generatedCardsView
            }
        }
        .groupedBackground()
        .navigation(
            title: Loc.AIFeatures.aiGeneratorTitle,
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .alert(Loc.AIFeatures.error, isPresented: $showingError) {
            Button(Loc.AIFeatures.ok, role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingPaywall) {
            Paywall.ContentView()
        }
        .onAppear {
            if !purchaseService.hasPremiumAccess {
                showingPaywall = true
                AnalyticsService.trackEvent(.aiFeaturePaywallShown)
            } else {
                AnalyticsService.trackEvent(.aiCollectionGeneratorOpened)
            }
        }
    }

    // MARK: - Request Input View

    private var requestInputView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)

                    Text(Loc.AIFeatures.aiGeneratorTitle)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(Loc.AIFeatures.aiGeneratorDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                // Input section
                CustomSectionView(header: Loc.AIFeatures.yourRequest, backgroundStyle: .standard) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextEditor(text: $userRequest)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(8)

                        Text(Loc.Plurals.characterLimit(userRequest.count))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Card count selector
                CustomSectionView(header: Loc.AIFeatures.numberOfCards, backgroundStyle: .standard) {
                    Picker("Card Count", selection: $cardCount) {
                        ForEach(cardCountOptions, id: \.self) { count in
                            Text(Loc.Plurals.cardsCount(count)).tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Examples
                CustomSectionView(header: Loc.AIFeatures.exampleRequests, backgroundStyle: .standard) {
                    VStack(alignment: .leading, spacing: 8) {
                        ExampleRequestRow(
                            icon: "fork.knife",
                            text: Loc.AIFeatures.exampleRestaurant
                        ) {
                            userRequest = Loc.AIFeatures.exampleRestaurant
                        }

                        ExampleRequestRow(
                            icon: "airplane",
                            text: Loc.AIFeatures.exampleAirport
                        ) {
                            userRequest = Loc.AIFeatures.exampleAirport
                        }

                        ExampleRequestRow(
                            icon: "briefcase",
                            text: Loc.AIFeatures.exampleBusiness
                        ) {
                            userRequest = Loc.AIFeatures.exampleBusiness
                        }
                    }
                }

                Spacer()
            }
            .padding(vertical: 12, horizontal: 16)
        }
        .safeAreaBarIfAvailable {
            ActionButton(
                Loc.AIFeatures.generateCollection,
                style: .borderedProminent,
                isLoading: chatGPTService.isGenerating
            ) {
                generateCollection()
            }
            .disabled(userRequest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatGPTService.isGenerating)
            .padding(vertical: 12, horizontal: 16)
        }
    }

    // MARK: - Generated Cards View

    private var generatedCardsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Collection header
                if let collection = generatedCollection {
                    CustomSectionView(header: collection.collectionName, backgroundStyle: .standard) {
                        Text(collection.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }

                    CustomSectionView(
                        header: Loc.Plurals.generatedCardsCount(collection.cards.count),
                        backgroundStyle: .standard
                    ) {
                        VStack(spacing: 12) {
                            ForEach(Array(collection.cards.enumerated()), id: \.offset) { index, card in
                                GeneratedCardRow(card: card)
                            }
                        }
                    }
                }
            }
            .padding(vertical: 12, horizontal: 16)
        }
        .safeAreaBarIfAvailable {
            // Action buttons
            VStack(spacing: 12) {
                ActionButton(
                    Loc.AIFeatures.importAll,
                    style: .borderedProminent
                ) {
                    importAllCards()
                }

                ActionButton(
                    Loc.AIFeatures.tryAgain,
                    style: .bordered
                ) {
                    generatedCollection = nil
                    HapticService.shared.buttonTapped()
                }
            }
            .padding(vertical: 12, horizontal: 16)
        }
    }

    // MARK: - Actions

    private func generateCollection() {
        let trimmedRequest = userRequest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRequest.isEmpty else { return }

        guard trimmedRequest.count <= 500 else {
            errorMessage = Loc.AIFeatures.requestTooLong
            showingError = true
            return
        }

        Task {
            do {
                let collection = try await chatGPTService.generateCollection(
                    userRequest: trimmedRequest,
                    targetLanguage: languageManager.targetLanguage,
                    cardCount: cardCount
                )

                await MainActor.run {
                    generatedCollection = collection
                    HapticService.shared.success()
                    AnalyticsService.trackEvent(.aiCollectionGenerated, parameters: [
                        "card_count": cardCount,
                        "target_language": languageManager.targetLanguage.rawValue
                    ])
                }
            } catch let error as ChatGPTError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    HapticService.shared.error()
                    AnalyticsService.trackEvent(.aiFeatureError, parameters: [
                        "error": error.localizedDescription
                    ])
                }
            } catch {
                await MainActor.run {
                    errorMessage = Loc.AIFeatures.aiUnexpectedError
                    showingError = true
                    HapticService.shared.error()
                }
            }
        }
    }

    private func importAllCards() {
        guard let collection = generatedCollection else { return }

        var importedCount = 0
        var failedCount = 0

        for card in collection.cards {
            do {
                try cardsProvider.addCard(
                    frontText: card.frontText,
                    backText: card.backText,
                    notes: card.notes,
                    tags: card.tags
                )
                importedCount += 1
            } catch {
                failedCount += 1
                debugPrint("❌ Failed to import card: \(card.frontText)")
            }
        }

        if importedCount > 0 {
            HapticService.shared.success()
            AnalyticsService.trackEvent(.aiCollectionImported, parameters: [
                "cards_imported": importedCount,
                "cards_failed": failedCount,
                "collection_name": collection.collectionName
            ])
            dismiss()
        } else {
            errorMessage = Loc.AIFeatures.aiImportFailed
            showingError = true
            HapticService.shared.error()
        }
    }
}

// MARK: - Example Request Row

struct ExampleRequestRow: View {
    @StateObject private var colorManager = ColorManager.shared

    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(colorManager.tintColor)
                    .frame(width: 24)

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "arrow.up.forward.circle.fill")
                    .foregroundStyle(colorManager.tintColor)
            }
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Generated Card Row

struct GeneratedCardRow: View {
    let card: GeneratedCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.frontText)
                        .font(.headline)
                    Text(card.backText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(0..<card.difficulty, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
            }

            if !card.notes.isEmpty {
                Text(card.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            if !card.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(card.tags, id: \.self) { tag in
                            TagView(title: tag, isSelected: true, size: .small)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

