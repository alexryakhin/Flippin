//
//  CardsProvider.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import SwiftUI
import Combine
import CoreData

@MainActor
final class CardsProvider: ObservableObject {

    static let shared = CardsProvider()

    @Published private(set) var cards: [CardItem] = []
    let errorPublisher = PassthroughSubject<Error, Never>()

    private let coreDataService = CoreDataService.shared
    private let languageManager = LanguageManager.shared
    private let tagManager = TagManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var hasCheckedInitialSync = false

    // MARK: - Card Limit Configuration
    private let freeUserCardLimit = 40

    /// Returns the maximum number of cards allowed for the current user
    var cardLimit: Int {
        if PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_monthly") ||
           PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_yearly") {
            return .max
        } else {
            return freeUserCardLimit
        }
    }
    
    /// Returns true if the user has unlimited cards
    var hasUnlimitedCards: Bool {
        return cardLimit == .max
    }
    
    /// Returns true if adding a card would exceed the limit
    var wouldExceedLimit: Bool {
        return !hasUnlimitedCards && cards.count >= cardLimit
    }
    
    /// Returns the number of cards remaining for free users
    var remainingCards: Int {
        if hasUnlimitedCards {
            return .max
        } else {
            return max(0, cardLimit - cards.count)
        }
    }

    private init() {
        fetchCards()
        
        // Only check for CloudKit sync if cards are empty after initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.cards.isEmpty == true && !(self?.hasCheckedInitialSync ?? false) {
                self?.hasCheckedInitialSync = true
                self?.checkForCloudKitData()
            }
        }
    }
    
    private func checkForCloudKitData() {
        // Only check once if cards are empty at startup
        if cards.isEmpty {
            print("🔄 No cards found at startup, checking CloudKit sync...")
            coreDataService.checkCloudKitSync()
            
            // Try fetching again after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.fetchCards()
            }
        }
    }

    /// Fetches latest data from Core Data
    func fetchCards() {
        do {
            let request = CardItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CardItem.timestamp, ascending: true)]
            let fetchedCards = try coreDataService.context.fetch(request)
            cards = fetchedCards
            print("📱 Fetched \(fetchedCards.count) cards from Core Data")
        } catch {
            errorPublisher.send(error)
        }
    }

    /// Adds a new card to Core Data with limit checking
    func addCard(frontText: String, backText: String, notes: String, tags: [String] = []) throws {
        // Check if adding this card would exceed the limit
        if wouldExceedLimit {
            throw CardLimitError.limitExceeded(
                currentCount: cards.count,
                limit: cardLimit,
                remainingCards: remainingCards
            )
        }

        let card = CardItem(
            frontText: frontText,
            backText: backText,
            frontLanguage: languageManager.targetLanguage,
            backLanguage: languageManager.userLanguage,
            notes: notes
        )

        // Add tags using TagManager
        for tagName in tags {
            if let tag = tagManager.findOrCreateTag(withName: tagName) {
                card.addToTags(tag)
            }
        }
        saveContext()
        fetchCards()

        // Haptic feedback for card addition
        HapticService.shared.cardAdded()
        
        // Analytics tracking for card creation
        AnalyticsService.trackCardEvent(
            .cardAdded,
            cardLanguage: card.frontLanguage?.rawValue,
            hasTags: !card.tagNames.isEmpty,
            tagCount: card.tagNames.count
        )
    }

    /// Adds preset cards to Core Data with limit checking
    func addPresetCards(_ cards: [PresetCard]) throws {
        // Check if adding these cards would exceed the limit
        if !hasUnlimitedCards && (self.cards.count + cards.count) > cardLimit {
            throw CardLimitError.limitExceeded(
                currentCount: self.cards.count,
                limit: cardLimit,
                remainingCards: remainingCards
            )
        }
        let _ = convertPresetCardsToCardItems(cards)
        saveContext()
        fetchCards()
    }

    /// Removes a card from Core Data
    func deleteCard(_ card: CardItem) {
        coreDataService.context.delete(card)
        if let index = cards.firstIndex(of: card) {
            cards.remove(at: index)
        }
        saveContext()
        // Haptic feedback for card deletion
        HapticService.shared.cardDeleted()
    }
    
    /// Removes all cards from Core Data
    func deleteAllCards() {
        for card in cards {
            coreDataService.context.delete(card)
        }
        saveContext()
        cards.removeAll()
        objectWillChange.send()
    }

    /// Toggles the favorite status of a card
    func toggleFavorite(_ card: CardItem) {
        card.isFavorite.toggle()
        saveContext()
        // Haptic feedback for favorite toggle
        HapticService.shared.favoriteToggled(isFavorite: card.isFavorite)
        
        // Analytics tracking for favorite toggle
        let event: AnalyticsEvent = card.isFavorite ? .cardFavorited : .cardUnfavorited
        AnalyticsService.trackFavoriteEvent(
            event,
            cardLanguage: card.frontLanguage?.rawValue,
            hasTags: !card.tagNames.isEmpty
        )
    }

    func saveContext() {
        do {
            try coreDataService.saveContext()
            objectWillChange.send()
        } catch {
            errorPublisher.send(error)
        }
    }

    private func convertPresetCardsToCardItems(_ presetCards: [PresetCard]) -> [CardItem] {
        return presetCards.map { card in
            let item = CardItem(
                frontText: card.frontText,
                backText: card.backText,
                frontLanguage: languageManager.targetLanguage,
                backLanguage: languageManager.userLanguage,
                notes: card.notes
            )
            for tagName in card.tags {
                if let tag = tagManager.findOrCreateTag(withName: tagName) {
                    item.addToTags(tag)
                }
            }

            return item
        }
    }
}

// MARK: - Card Limit Error
enum CardLimitError: LocalizedError {
    case limitExceeded(currentCount: Int, limit: Int, remainingCards: Int)
    case freeUserLimit(Int)
    case purchaseRequired
    
    var errorDescription: String? {
        switch self {
        case .limitExceeded(let currentCount, let limit, _):
            return LocalizationKeys.Card.cardLimitExceeded.localized(with: currentCount, limit)
        case .freeUserLimit(let limit):
            return LocalizationKeys.Card.freeUsersLimitedTo.localized(with: limit)
        case .purchaseRequired:
            return LocalizationKeys.Card.purchaseUnlimitedCards.localized
        }
    }
    
    var failureReason: String? {
        switch self {
        case .limitExceeded(_, let limit, _):
            return LocalizationKeys.Card.freeUsersLimitedTo.localized(with: limit)
        case .freeUserLimit(let limit):
            return LocalizationKeys.Card.freeUsersLimitedTo.localized(with: limit)
        case .purchaseRequired:
            return LocalizationKeys.Card.purchaseUnlimitedCards.localized
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .limitExceeded:
            return LocalizationKeys.Card.purchaseUnlimitedCards.localized
        case .freeUserLimit:
            return LocalizationKeys.Card.purchaseUnlimitedCards.localized
        case .purchaseRequired:
            return LocalizationKeys.Card.purchaseUnlimitedCards.localized
        }
    }
}
