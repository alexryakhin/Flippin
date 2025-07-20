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
    @Published private(set) var isLoading = false
    let errorPublisher = PassthroughSubject<Error, Never>()

    private let coreDataService = CoreDataService.shared
    private let tagManager = TagManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var hasCheckedInitialSync = false

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
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.isLoading = false
                }
            }
            do {
                let request = CardItem.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(keyPath: \CardItem.timestamp, ascending: true)]
                let fetchedCards = try self?.coreDataService.context.fetch(request) ?? []
                
                DispatchQueue.main.async {
                    self?.cards = fetchedCards
                    print("📱 Fetched \(fetchedCards.count) cards from Core Data")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorPublisher.send(error)
                }
            }
        }
    }

    /// Adds a new card to Core Data
    func addCard(_ card: CardItem, tags: [String] = []) {
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
        fetchCards()
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try self?.coreDataService.saveContext()
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorPublisher.send(error)
                }
            }
        }
    }
}
