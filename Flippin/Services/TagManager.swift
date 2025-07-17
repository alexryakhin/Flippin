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

    private init() {
        setupBindings()
        updateAvailableTags()
    }
    
    @Published private(set) var availableTags: [String] = []
    
    private func updateAvailableTags() {
        let request: NSFetchRequest<CDTag> = CDTag.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDTag.name, ascending: true)]
        
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
        set { selectedFilterTag = newValue }
    }
    
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        // Check if tag already exists
        let request: NSFetchRequest<CDTag> = CDTag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", trimmedTag)
        
        do {
            let existingTags = try coreDataService.context.fetch(request)
            if existingTags.isEmpty {
                // Create new tag
                _ = CDTag(context: coreDataService.context, name: trimmedTag)
                try coreDataService.saveContext()
                updateAvailableTags()
            }
        } catch {
            print("Error adding tag: \(error)")
        }
    }
    
    func removeTag(_ tag: String) {
        let request: NSFetchRequest<CDTag> = CDTag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", tag)
        
        do {
            let tags = try coreDataService.context.fetch(request)
            for tag in tags {
                coreDataService.context.delete(tag)
            }
            try coreDataService.saveContext()
            updateAvailableTags()
            AnalyticsService.trackTagEvent(.tagDeleted, tagName: tag, tagCount: availableTags.count)
        } catch {
            print("Error removing tag: \(error)")
        }
    }
    
    func filterCards(_ cards: [CardItem], by tag: String?) -> [CardItem] {
        guard let tag = tag, !tag.isEmpty else { return cards }
        return cards.filter { card in
            card.tags.contains(tag)
        }
    }
    
    func clearFilter() {
        currentFilterTag = ""
    }
    
    func getUnusedTags() -> [String] {
        let request: NSFetchRequest<CDTag> = CDTag.fetchRequest()
        
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
    
    func findOrCreateTag(withName name: String) -> CDTag? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        
        let request: NSFetchRequest<CDTag> = CDTag.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", trimmedName)
        
        do {
            let existingTags = try coreDataService.context.fetch(request)
            if let existingTag = existingTags.first {
                return existingTag
            } else {
                // Create new tag
                let newTag = CDTag(context: coreDataService.context, name: trimmedName)
                try coreDataService.saveContext()
                updateAvailableTags()
                return newTag
            }
        } catch {
            print("Error finding or creating tag: \(error)")
            return nil
        }
    }

    private func setupBindings() {
        coreDataService.dataUpdatedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.updateAvailableTags()
            }
            .store(in: &cancellables)
    }
}
