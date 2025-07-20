//
//  Tag.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/16/25.
//

import Foundation
import CoreData

@objc(Tag)
public final class Tag: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var cards: NSSet?
    
    var cardArray: [CardItem] {
        let set = cards as? Set<CardItem> ?? []
        return Array(set)
    }
}

extension Tag {
    convenience init(_ name: String) {
        self.init(context: CoreDataService.shared.context)
        self.name = name
        self.id = UUID().uuidString
    }
}

// MARK: - Fetch Request
extension Tag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }
}

// MARK: - Generated accessors for cards
extension Tag {
    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CardItem)
    
    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CardItem)
    
    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)
    
    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)
} 

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name.orEmpty < rhs.name.orEmpty
    }
}
