//
//  TagManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import Foundation
import SwiftUI

final class TagManager: ObservableObject {
    @AppStorage(UserDefaultsKey.availableTags) private var availableTagsData: Data = Data()
    @AppStorage(UserDefaultsKey.selectedFilterTag) private var selectedFilterTag: String = ""
    
    var availableTags: [String] {
        get {
            if let tags = try? JSONDecoder().decode([String].self, from: availableTagsData) {
                return tags.sorted()
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                availableTagsData = data
            }
        }
    }
    
    var currentFilterTag: String {
        get { selectedFilterTag }
        set { selectedFilterTag = newValue }
    }
    
    func addTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        if !availableTags.contains(trimmedTag) {
            availableTags.append(trimmedTag)
        }
    }
    
    func removeTag(_ tag: String) {
        availableTags.removeAll { $0 == tag }
        AnalyticsService.trackTagEvent(.tagDeleted, tagName: tag, tagCount: availableTags.count)
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
        return availableTags.filter { tag in
            // This would need to be implemented with a query to check if any cards use this tag
            // For now, we'll return all available tags
            return true
        }
    }
} 
