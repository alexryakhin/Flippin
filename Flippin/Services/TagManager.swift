//
//  TagManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import Foundation
import SwiftUI
import CoreData
import Combine

final class TagManager: ObservableObject {
    @AppStorage(UserDefaultsKey.selectedFilterTag) private var selectedFilterTag: String = ""
    
    private let coreDataService = CoreDataService.shared
    private var cancellables: Set<AnyCancellable> = []

    static let shared = TagManager()
    let errorPublisher = PassthroughSubject<Error, Never>()

    private init() {
        updateAvailableTags()
    }
    
    @Published private(set) var availableTags: [String] = []
    @Published var isFavoriteFilterOn: Bool = false {
        didSet {
            // Haptic feedback for favorite filter toggle
            if oldValue != isFavoriteFilterOn {
                DispatchQueue.main.async {
                    HapticService.shared.filterApplied()
                }
            }
        }
    }
    
    private func updateAvailableTags() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
        
        do {
            let tags = try coreDataService.context.fetch(request)
            availableTags = tags.compactMap { $0.name }.sorted()
        } catch {
            print("Error fetching tags: \(error)")
            availableTags = []
        }
    }
    
    var currentFilterTag: String {
        get { selectedFilterTag }
        set { 
            let oldValue = selectedFilterTag
            selectedFilterTag = newValue
            
            // Haptic feedback for filter applied (only if it's a new filter)
            if oldValue != newValue && !newValue.isEmpty {
                DispatchQueue.main.async {
                    HapticService.shared.filterApplied()
                }
            }
        }
    }
    
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        do {
            // Check if tag already exists
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", trimmedTag)

            let existingTags = try coreDataService.context.fetch(request)
            if existingTags.isEmpty {
                // Create new tag
                _ = Tag(trimmedTag)
                saveContext()
                updateAvailableTags()

                // Haptic feedback for tag addition
                DispatchQueue.main.async {
                    HapticService.shared.tagAdded()
                }
            }
        } catch {
            print("Error adding tag: \(error)")
        }
    }
    
        func removeTag(_ tag: String) {
        do {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", tag)

            let tags = try coreDataService.context.fetch(request)
            for tag in tags {
                coreDataService.context.delete(tag)
            }
            saveContext()
            updateAvailableTags()

            // Haptic feedback for tag deletion
            DispatchQueue.main.async {
                HapticService.shared.tagDeleted()
            }

            AnalyticsService.trackTagEvent(.tagDeleted, tagName: tag, tagCount: availableTags.count)
        } catch {
            print("Error removing tag: \(error)")
        }
    }
    
    func filterCards(_ cards: [CardItem], by tag: String?) -> [CardItem] {
        guard let tag, !tag.isEmpty else { return cards }
        return cards.filter { card in
            card.tagNames.contains(tag)
        }
    }
    
    func filterCardsByFavorite(_ cards: [CardItem]) -> [CardItem] {
        guard isFavoriteFilterOn else { return cards }
        return cards.filter { $0.isFavorite }
    }
    
    func clearFilter() {
        currentFilterTag = ""
        
        // Haptic feedback for filter cleared
        DispatchQueue.main.async {
            HapticService.shared.filterCleared()
        }
    }
    
    func getUnusedTags() -> [String] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        do {
            let tags = try coreDataService.context.fetch(request)
            return tags.compactMap { tag in
                // Check if tag has any associated cards
                if tag.cardArray.isEmpty {
                    return tag.name
                }
                return nil
            }
        } catch {
            print("Error fetching unused tags: \(error)")
            return []
        }
    }
    
    func findOrCreateTag(withName name: String) -> Tag? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", trimmedName)
        
        do {
            let existingTags = try coreDataService.context.fetch(request)
            if let existingTag = existingTags.first {
                return existingTag
            } else {
                // Create new tag
                let newTag = Tag(trimmedName)
                saveContext()
                updateAvailableTags()
                return newTag
            }
        } catch {
            print("Error finding or creating tag: \(error)")
            return nil
        }
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
