//
//  CardItem.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import Foundation
import CoreData

@objc(CardItem)
public final class CardItem: NSManagedObject, Identifiable {
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

    var tagArray: [Tag] {
        let set = tags as? Set<Tag> ?? []
        return Array(set).sorted()
    }

    var tagNames: [String] {
        return tagArray.compactMap { $0.name }.sorted()
    }
}

extension CardItem {
    convenience init(
        timestamp: Date = Date(),
        frontText: String = "",
        backText: String = "",
        frontLanguage: Language = .english,
        backLanguage: Language = .spanish,
        notes: String? = nil,
        isFavorite: Bool = false,
        id: String = UUID().uuidString
    ) {
        self.init(context: CoreDataService.shared.context)
        self.timestamp = timestamp
        self.frontText = frontText
        self.backText = backText
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.notes = notes
        self.isFavorite = isFavorite
        self.id = id
    }
}

// MARK: - Fetch Request
extension CardItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardItem> {
        return NSFetchRequest<CardItem>(entityName: "CardItem")
    }
}

// MARK: - Generated accessors for tags
extension CardItem {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
}
