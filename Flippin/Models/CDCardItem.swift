//
//  CDCardItem.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import Foundation
import CoreData

@objc(CDCardItem)
public final class CDCardItem: NSManagedObject {
    @NSManaged public var timestamp: Date?
    @NSManaged public var frontText: String?
    @NSManaged public var backText: String?
    @NSManaged public var frontLanguageRaw: String?
    @NSManaged public var backLanguageRaw: String?
    @NSManaged public var notes: String?
    @NSManaged public var id: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tags: NSSet?

    var frontLanguage: Language? {
        get {
            guard let rawValue = frontLanguageRaw else { return nil }
            return Language(rawValue: rawValue)
        }
        set {
            frontLanguageRaw = newValue?.rawValue
        }
    }

    var backLanguage: Language? {
        get {
            guard let rawValue = backLanguageRaw else { return nil }
            return Language(rawValue: rawValue)
        }
        set {
            backLanguageRaw = newValue?.rawValue
        }
    }

    var tagArray: [CDTag] {
        let set = tags as? Set<CDTag> ?? []
        return Array(set)
    }

    var tagNames: [String] {
        return tagArray.compactMap { $0.name }
    }
}

extension CDCardItem {
    convenience init(
        context: NSManagedObjectContext,
        timestamp: Date = Date(),
        frontText: String = "",
        backText: String = "",
        frontLanguage: Language = .english,
        backLanguage: Language = .spanish,
        notes: String? = nil,
        tagNames: [String]? = nil,
        isFavorite: Bool = false,
        id: String = UUID().uuidString
    ) {
        self.init(context: context)
        self.timestamp = timestamp
        self.frontText = frontText
        self.backText = backText
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.notes = notes
        self.isFavorite = isFavorite
        self.id = id

        // Tags will be handled separately by the CardsProvider
        // This is to avoid creating duplicate tags
    }

    var coreModel: CardItem? {
        guard let timestamp = timestamp,
              let frontText = frontText,
              let backText = backText,
              let frontLanguage = frontLanguage,
              let backLanguage = backLanguage,
              let id = id else {
            return nil
        }

        return CardItem(
            timestamp: timestamp,
            frontText: frontText,
            backText: backText,
            frontLanguage: frontLanguage,
            backLanguage: backLanguage,
            notes: notes ?? "",
            tags: tagNames,
            isFavorite: isFavorite,
            id: id
        )
    }
}

// MARK: - Fetch Request
extension CDCardItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCardItem> {
        return NSFetchRequest<CDCardItem>(entityName: "CardItem")
    }
}

// MARK: - Generated accessors for tags
extension CDCardItem {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: CDTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: CDTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}
