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
    @State private var cardCount = 25
    @State private var generatedCollection: GeneratedCollection?
    @State private var editingCard: GeneratedCard?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPaywall = false
    
    private let cardCountOptions = [10, 25, 50]
    
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
            title: "AI Collection Generator",
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
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
                        .foregroundColor(.yellow)
                    
                    Text("AI Collection Generator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Describe what you want to learn and AI will create a custom flashcard collection for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Input section
                CustomSectionView(header: "Your Request", backgroundStyle: .standard) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextEditor(text: $userRequest)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(8)
                        
                        Text("\(userRequest.count)/500 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Card count selector
                CustomSectionView(header: "Number of Cards", backgroundStyle: .standard) {
                    Picker("Card Count", selection: $cardCount) {
                        ForEach(cardCountOptions, id: \.self) { count in
                            Text("\(count) cards").tag(count)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Examples
                CustomSectionView(header: "Example Requests", backgroundStyle: .standard) {
                    VStack(alignment: .leading, spacing: 8) {
                        ExampleRequestRow(
                            icon: "fork.knife",
                            text: "Spanish phrases for ordering at restaurants"
                        ) {
                            userRequest = "Spanish phrases for ordering at restaurants"
                        }
                        
                        ExampleRequestRow(
                            icon: "airplane",
                            text: "French vocabulary for navigating airports"
                        ) {
                            userRequest = "French vocabulary for navigating airports"
                        }
                        
                        ExampleRequestRow(
                            icon: "briefcase",
                            text: "German business meeting expressions"
                        ) {
                            userRequest = "German business meeting expressions"
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .safeAreaInset(edge: .bottom) {
            ActionButton(
                "Generate Collection",
                style: .borderedProminent,
                isLoading: chatGPTService.isGenerating
            ) {
                generateCollection()
            }
            .disabled(userRequest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatGPTService.isGenerating)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Generated Cards View
    
    private var generatedCardsView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // Collection header
                    if let collection = generatedCollection {
                        CustomSectionView(header: collection.collectionName, backgroundStyle: .standard) {
                            Text(collection.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        CustomSectionView(header: "Generated Cards (\(collection.cards.count))", backgroundStyle: .standard) {
                            VStack(spacing: 12) {
                                ForEach(Array(collection.cards.enumerated()), id: \.offset) { index, card in
                                    GeneratedCardRow(card: card)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
            
            // Action buttons
            HStack(spacing: 12) {
                ActionButton(
                    "Try Again",
                    style: .bordered
                ) {
                    generatedCollection = nil
                    HapticService.shared.buttonTapped()
                }
                
                ActionButton(
                    "Import All",
                    style: .borderedProminent
                ) {
                    importAllCards()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Actions
    
    private func generateCollection() {
        let trimmedRequest = userRequest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedRequest.isEmpty else { return }
        
        guard trimmedRequest.count <= 500 else {
            errorMessage = "Request too long. Please keep it under 500 characters."
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
                    errorMessage = "An unexpected error occurred. Please try again."
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
                print("❌ Failed to import card: \(card.frontText)")
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
            errorMessage = "Failed to import cards. You may have reached your card limit."
            showingError = true
            HapticService.shared.error()
        }
    }
}

// MARK: - Example Request Row

struct ExampleRequestRow: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.circle.fill")
                    .foregroundColor(.accentColor)
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
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<card.difficulty, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if !card.notes.isEmpty {
                Text(card.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            if !card.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(card.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(6)
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

