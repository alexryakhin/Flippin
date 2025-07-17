//
//  CDTag.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/16/25.
//

import Foundation
import CoreData

@objc(CDTag)
public final class CDTag: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var cards: NSSet?
    
    var cardArray: [CDCardItem] {
        let set = cards as? Set<CDCardItem> ?? []
        return Array(set)
    }
}

extension CDTag {
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        id: String = UUID().uuidString
    ) {
        self.init(context: context)
        self.name = name
        self.id = id
    }
}

// MARK: - Fetch Request
extension CDTag {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTag> {
        return NSFetchRequest<CDTag>(entityName: "Tag")
    }
}

// MARK: - Generated accessors for cards
extension CDTag {
    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CDCardItem)
    
    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CDCardItem)
    
    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)
    
    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)
} 
