//
//  CDCardItem.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import Foundation
import CoreData

@objc(CDCardItem)
public class CDCardItem: NSManagedObject {
    @NSManaged public var timestamp: Date?
    @NSManaged public var frontText: String?
    @NSManaged public var backText: String?
    @NSManaged public var frontLanguageRaw: String?
    @NSManaged public var backLanguageRaw: String?
    @NSManaged public var notes: String?
    @NSManaged public var tagsData: Data?
    @NSManaged public var id: String?
    
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
    
    var tags: [String]? {
        get {
            guard let data = tagsData else { return nil }
            return try? JSONDecoder().decode([String].self, from: data)
        }
        set {
            tagsData = try? JSONEncoder().encode(newValue)
        }
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
        tags: [String]? = nil,
        id: String = UUID().uuidString
    ) {
        self.init(context: context)
        self.timestamp = timestamp
        self.frontText = frontText
        self.backText = backText
        self.frontLanguage = frontLanguage
        self.backLanguage = backLanguage
        self.notes = notes
        self.tags = tags
        self.id = id
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
            tags: tags ?? [],
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
