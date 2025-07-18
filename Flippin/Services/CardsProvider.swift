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
    @Published private(set) var cards: [CardItem] = []
    let cardsErrorPublisher = PassthroughSubject<Error, Never>()

    private let coreDataService = CoreDataService.shared
    private let tagManager = TagManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupBindings()
        fetchCards()
    }

    /// Fetches latest data from Core Data
    func fetchCards() {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        let request = CDCardItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCardItem.timestamp, ascending: true)]
        
        do {
            let cards = try coreDataService.context.fetch(request)
            self.cards = cards.compactMap(\.coreModel)

            // Sync completed
            Task { @MainActor in
                SyncManager.shared.syncCompleted()
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }

    /// Adds a new card to Core Data
    func addCard(_ card: CardItem) {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        
        let cdCard = CDCardItem(
            context: coreDataService.context,
            timestamp: card.timestamp,
            frontText: card.frontText,
            backText: card.backText,
            frontLanguage: card.frontLanguage,
            backLanguage: card.backLanguage,
            notes: card.notes.isEmpty ? nil : card.notes,
            tagNames: nil, // We'll handle tags separately
            isFavorite: card.isFavorite,
            id: card.id
        )
        
        // Add tags using TagManager
        for tagName in card.tags {
            if let tag = tagManager.findOrCreateTag(withName: tagName) {
                cdCard.addToTags(tag)
            }
        }
        
        do {
            try coreDataService.saveContext()
            
            // Haptic feedback for card addition
            HapticService.shared.cardAdded()
            
            // Sync completed
            Task { @MainActor in
                SyncManager.shared.syncCompleted()
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }

    /// Removes a card from Core Data
    func deleteCard(with id: String) {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        
        let fetchRequest = CDCardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let object = try coreDataService.context.fetch(fetchRequest).first {
                coreDataService.context.delete(object)
                try coreDataService.saveContext()
                
                // Haptic feedback for card deletion
                HapticService.shared.cardDeleted()
                
                // Sync completed
                Task { @MainActor in
                    SyncManager.shared.syncCompleted()
                }
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }
    
    /// Removes all cards from Core Data
    func deleteAllCards() {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        
        let fetchRequest: NSFetchRequest<CDCardItem> = CDCardItem.fetchRequest()
        
        do {
            let allCards = try coreDataService.context.fetch(fetchRequest)
            for card in allCards {
                coreDataService.context.delete(card)
            }
            try coreDataService.saveContext()
            
            // Sync completed
            Task { @MainActor in
                SyncManager.shared.syncCompleted()
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }

    /// Toggles the favorite status of a card
    func toggleFavorite(for cardId: String) {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        
        let fetchRequest: NSFetchRequest<CDCardItem> = CDCardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", cardId)

        do {
            if let cdCard = try coreDataService.context.fetch(fetchRequest).first {
                let wasFavorite = cdCard.isFavorite
                cdCard.isFavorite.toggle()
                try coreDataService.saveContext()
                
                // Haptic feedback for favorite toggle
                HapticService.shared.favoriteToggled(isFavorite: cdCard.isFavorite)
                
                // Sync completed
                Task { @MainActor in
                    SyncManager.shared.syncCompleted()
                }
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }
    
    /// Updates an existing card in Core Data
    func updateCard(_ card: CardItem) {
        Task { @MainActor in
            SyncManager.shared.startSync()
        }
        
        let fetchRequest: NSFetchRequest<CDCardItem> = CDCardItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", card.id)

        do {
            if let cdCard = try coreDataService.context.fetch(fetchRequest).first {
                cdCard.timestamp = card.timestamp
                cdCard.frontText = card.frontText
                cdCard.backText = card.backText
                cdCard.frontLanguage = card.frontLanguage
                cdCard.backLanguage = card.backLanguage
                cdCard.notes = card.notes.isEmpty ? nil : card.notes
                cdCard.isFavorite = card.isFavorite
                
                // Update tags
                let existingTags = cdCard.tagArray
                for tag in existingTags {
                    cdCard.removeFromTags(tag)
                }
                
                for tagName in card.tags {
                    if let tag = tagManager.findOrCreateTag(withName: tagName) {
                        cdCard.addToTags(tag)
                    }
                }
                
                try coreDataService.saveContext()
                
                // Haptic feedback for card editing
                HapticService.shared.cardEdited()
                
                // Sync completed
                Task { @MainActor in
                    SyncManager.shared.syncCompleted()
                }
            }
        } catch {
            // Sync failed
            Task { @MainActor in
                SyncManager.shared.syncFailed()
            }
            cardsErrorPublisher.send(error)
        }
    }

    private func setupBindings() {
        coreDataService.dataUpdatedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchCards()
            }
            .store(in: &cancellables)
    }
} 
