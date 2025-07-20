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
    @Published var selectedFilterTag: Tag? {
        didSet {
            // Haptic feedback for filter applied (only if it's a new filter)
            if oldValue != selectedFilterTag, let selectedFilterTag {
                DispatchQueue.main.async {
                    HapticService.shared.filterApplied()
                }

                // Analytics tracking for tag filter applied
                AnalyticsService.trackFilterEvent(
                    .tagFilterApplied,
                    filterType: "tag",
                    filterValue: selectedFilterTag.name
                )
            }
        }
    }

    private let coreDataService = CoreDataService.shared
    private var cancellables: Set<AnyCancellable> = []
    private var hasCheckedInitialSync = false

    static let shared = TagManager()
    let errorPublisher = PassthroughSubject<Error, Never>()

    private init() {
        updateAvailableTags()
        
        // Check for CloudKit sync if tags are empty after initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.availableTags.isEmpty == true && !(self?.hasCheckedInitialSync ?? false) {
                self?.hasCheckedInitialSync = true
                self?.checkForCloudKitData()
            }
        }
    }
    
    private func checkForCloudKitData() {
        // Only check once if tags are empty at startup
        if availableTags.isEmpty {
            print("🏷️ No tags found at startup, checking CloudKit sync...")
            coreDataService.checkCloudKitSync()
            
            // Try fetching again after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.updateAvailableTags()
            }
        }
    }

    @Published private(set) var availableTags: [Tag] = []
    @Published var isFavoriteFilterOn: Bool = false {
        didSet {
            // Haptic feedback for favorite filter toggle
            if oldValue != isFavoriteFilterOn {
                DispatchQueue.main.async {
                    HapticService.shared.filterApplied()
                }
                
                // Analytics tracking for favorite filter changes
                let event: AnalyticsEvent = isFavoriteFilterOn ? .favoriteFilterApplied : .favoriteFilterCleared
                AnalyticsService.trackFilterEvent(event, filterType: "favorite", filterValue: isFavoriteFilterOn ? "true" : "false")
            }
        }
    }

    private func updateAvailableTags() {
        let request = Tag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]

        do {
            let tags = try coreDataService.context.fetch(request)
            availableTags = tags.sorted()
            print("🏷️ Fetched \(tags.count) tags from Core Data")
        } catch {
            print("Error fetching tags: \(error)")
            availableTags = []
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
                
                // Analytics tracking for tag addition
                AnalyticsService.trackTagEvent(.tagAdded, tagName: trimmedTag, tagCount: availableTags.count)
            }
        } catch {
            print("Error adding tag: \(error)")
        }
    }

    func removeTag(_ tag: Tag) {
        coreDataService.context.delete(tag)
        saveContext()
        updateAvailableTags()

        // Haptic feedback for tag deletion
        DispatchQueue.main.async {
            HapticService.shared.tagDeleted()
        }

        AnalyticsService.trackTagEvent(.tagDeleted, tagName: tag.name, tagCount: availableTags.count)
    }

    func filterCards(_ cards: [CardItem], by tag: Tag?) -> [CardItem] {
        guard let tag else { return cards }
        return cards.filter { card in
            card.tagArray.contains(tag)
        }
    }

    func filterCardsByFavorite(_ cards: [CardItem]) -> [CardItem] {
        guard isFavoriteFilterOn else { return cards }
        return cards.filter { $0.isFavorite }
    }

    func clearFilter() {
        selectedFilterTag = nil

        // Haptic feedback for filter cleared
        DispatchQueue.main.async {
            HapticService.shared.filterCleared()
        }
        
        // Analytics tracking for tag filter cleared
        AnalyticsService.trackFilterEvent(.tagFilterCleared, filterType: "tag", filterValue: "")
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
