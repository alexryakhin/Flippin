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
    private let tagManager = TagManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        fetchCards()
    }

    /// Fetches latest data from Core Data
    func fetchCards() {
        do {
            let request = CardItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CardItem.timestamp, ascending: true)]
            self.cards = try coreDataService.context.fetch(request)
        } catch {
            errorPublisher.send(error)
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
    }

    func saveContext() {
        do {
            try coreDataService.saveContext()
            objectWillChange.send()
        } catch {
            errorPublisher.send(error)
        }
    }
}
