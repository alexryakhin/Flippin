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
    private let audioCacheService = AudioCacheService.shared
    private let purchaseService = PurchaseService.shared
    private var cancellables = Set<AnyCancellable>()
    private var hasCheckedInitialSync = false

    // MARK: - Card Limit Configuration
    private let freeUserCardLimit = 40

    /// Returns the maximum number of cards allowed for the current user
    var cardLimit: Int {
        if purchaseService.hasPremiumAccess {
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
        
        // Listen for purchase status changes to update card limits immediately
        purchaseService.$hasPremiumAccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Force UI update when premium status changes
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
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
            debugPrint("🔄 No cards found at startup, checking CloudKit sync...")
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
            debugPrint("📱 Fetched \(fetchedCards.count) cards from Core Data")
        } catch {
            errorPublisher.send(error)
        }
    }

    /// Adds a new card to Core Data with limit checking
    /// - Parameters:
    ///   - imageUrl: The web URL for the image (for fallback)
    ///   - imageCacheURL: The local relative path for the cached image
    func addCard(
        frontText: String,
        backText: String,
        notes: String,
        tags: [String] = [],
        imageUrl: String? = nil,
        imageCacheURL: String? = nil
    ) throws {
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
        
        // Handle image if provided (both URLs should be set for proper fallback)
        if let imageUrl = imageUrl, let imageCacheURL = imageCacheURL {
            card.imageURL = imageUrl // Web URL for fallback
            card.imageCacheURL = imageCacheURL // Local path for cache
            debugPrint("🖼️ [CardsProvider] Image attached to card - URL: \(imageUrl), Cache: \(imageCacheURL)")
        }
        
        saveContext()
        fetchCards()

        // Cache audio for both front and back text
        Task {
            await cacheAudioForCard(card)
        }

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
        let cardItems = convertPresetCardsToCardItems(cards)
        saveContext()
        fetchCards()
        
        // Cache audio for all preset cards
        Task {
            for card in cardItems {
                await cacheAudioForCard(card)
            }
        }
    }

    /// Removes a card from Core Data
    func deleteCard(_ card: CardItem) {
        // Clean up cached image if it exists
        if let imageCacheURL = card.imageCacheURL, !imageCacheURL.isEmpty {
            do {
                try PexelsService.shared.deleteImage(at: imageCacheURL)
                debugPrint("🗑️ [CardsProvider] Deleted cached image: \(imageCacheURL)")
            } catch {
                debugPrint("⚠️ [CardsProvider] Failed to delete cached image: \(error)")
                // Continue with card deletion even if image cleanup fails
            }
        }
        
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
            // Clean up cached image if it exists
            if let imageCacheURL = card.imageCacheURL, !imageCacheURL.isEmpty {
                do {
                    try PexelsService.shared.deleteImage(at: imageCacheURL)
                    debugPrint("🗑️ [CardsProvider] Deleted cached image: \(imageCacheURL)")
                } catch {
                    debugPrint("⚠️ [CardsProvider] Failed to delete cached image: \(error)")
                    // Continue with deletion even if image cleanup fails
                }
            }
            
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
    
    /// Caches audio for all cards that don't have cached audio yet
    func cacheAudioForAllCards() async {
        let cardsNeedingAudio = cards.filter { card in
            guard let frontText = card.frontText,
                  let backText = card.backText else { return false }
            return !frontText.isEmpty && !backText.isEmpty && 
                   (card.frontAudioURL == nil || card.backAudioURL == nil)
        }
        
        debugPrint("🎵 [CardsProvider] Caching audio for \(cardsNeedingAudio.count) cards...")
        
        for card in cardsNeedingAudio {
            await cacheAudioForCard(card)
        }
        
        debugPrint("✅ [CardsProvider] Finished caching audio for all cards")
    }
    
    /// Caches audio for both front and back text of a card
    private func cacheAudioForCard(_ card: CardItem) async {
        guard let frontText = card.frontText,
              let backText = card.backText,
              let frontLanguage = card.frontLanguage,
              let backLanguage = card.backLanguage else {
            return
        }
        
        // Determine which provider to use for caching
        let provider: TTSProvider = purchaseService.hasPremiumAccess ? .speechify : .google
        
        // Cache front audio
        if !frontText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                let frontAudioURL = try await audioCacheService.cacheAudio(for: frontText, language: frontLanguage, provider: provider)
                card.frontAudioURL = frontAudioURL.path
                debugPrint("🎵 [CardsProvider] Cached front audio (\(provider.rawValue)) for card: \(frontText.prefix(30))...")
            } catch {
                debugPrint("❌ [CardsProvider] Failed to cache front audio: \(error)")
            }
        }
        
        // Cache back audio
        if !backText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do {
                let backAudioURL = try await audioCacheService.cacheAudio(for: backText, language: backLanguage, provider: provider)
                card.backAudioURL = backAudioURL.path
                debugPrint("🎵 [CardsProvider] Cached back audio (\(provider.rawValue)) for card: \(backText.prefix(30))...")
            } catch {
                debugPrint("❌ [CardsProvider] Failed to cache back audio: \(error)")
            }
        }
        
        // Save the updated URLs to Core Data
        saveContext()
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
            return Loc.CardLimits.cardLimitExceeded(currentCount, limit)
        case .freeUserLimit(let limit):
            return Loc.CardLimits.freeUsersLimitedTo(limit)
        case .purchaseRequired:
            return Loc.CardLimits.purchaseUnlimitedCards
        }
    }
    
    var failureReason: String? {
        switch self {
        case .limitExceeded(_, let limit, _):
            return Loc.CardLimits.freeUsersLimitedTo(limit)
        case .freeUserLimit(let limit):
            return Loc.CardLimits.freeUsersLimitedTo(limit)
        case .purchaseRequired:
            return Loc.CardLimits.purchaseUnlimitedCards
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .limitExceeded:
            return Loc.CardLimits.purchaseUnlimitedCards
        case .freeUserLimit:
            return Loc.CardLimits.purchaseUnlimitedCards
        case .purchaseRequired:
            return Loc.CardLimits.purchaseUnlimitedCards
        }
    }
}
