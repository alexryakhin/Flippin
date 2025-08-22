//
//  SpeechifyUsage.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import CoreData

@objc(SpeechifyUsage)
public class SpeechifyUsage: NSManagedObject {
    
    // MARK: - Computed Properties
    
    var monthYear: String {
        return "\(month ?? "")-\(year)"
    }
    
    var remainingCharacters: Int {
        return Int(max(0, charactersLimit - charactersUsed))
    }
    
    var usagePercentage: Double {
        return Double(charactersUsed) / Double(charactersLimit) * 100
    }
    
    var isLimitExceeded: Bool {
        return charactersUsed >= charactersLimit
    }
    
    // MARK: - Helper Methods
    
    func addCharacters(_ count: Int) {
        charactersUsed += Int32(count)
    }
    
    func resetUsage() {
        charactersUsed = 0
        listeningTimeMinutes = 0.0
        resetDate = Date()
    }
    
    func canUseCharacters(_ count: Int) -> Bool {
        return (charactersUsed + Int32(count)) <= charactersLimit
    }
}

// MARK: - Core Data Extensions

extension SpeechifyUsage {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpeechifyUsage> {
        return NSFetchRequest<SpeechifyUsage>(entityName: "SpeechifyUsage")
    }
    
    @NSManaged public var charactersUsed: Int32
    @NSManaged public var charactersLimit: Int32
    @NSManaged public var id: String?
    @NSManaged public var listeningTimeMinutes: Double
    @NSManaged public var month: String?
    @NSManaged public var resetDate: Date?
    @NSManaged public var year: Int32
}
