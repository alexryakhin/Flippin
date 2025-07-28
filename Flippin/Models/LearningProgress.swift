import Foundation
import CoreData

// MARK: - Learning Progress Models

/// Represents a study session with detailed analytics
@objc(StudySession)
public final class StudySession: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var duration: Double
    @NSManaged public var cardsReviewed: Int32
    @NSManaged public var cardsCorrect: Int32
    @NSManaged public var cardsIncorrect: Int32
    @NSManaged public var sessionType: String? // "review", "new", "practice"
    @NSManaged public var languagePair: String? // "en-es", "fr-en", etc.
    @NSManaged public var tags: NSSet?
    
    var sessionDuration: TimeInterval {
        return duration
    }
    
    var accuracyRate: Double {
        guard cardsReviewed > 0 else { return 0.0 }
        return Double(cardsCorrect) / Double(cardsReviewed)
    }
    
    var tagArray: [Tag] {
        let set = tags as? Set<Tag> ?? []
        return Array(set).sorted()
    }
}

/// Represents individual card performance tracking
@objc(CardPerformance)
public final class CardPerformance: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var cardId: String?
    @NSManaged public var totalReviews: Int32
    @NSManaged public var correctReviews: Int32
    @NSManaged public var incorrectReviews: Int32
    @NSManaged public var lastReviewed: Date?
    @NSManaged public var nextReviewDate: Date?
    @NSManaged public var difficultyLevel: Int16 // 1-5 scale
    @NSManaged public var timeSpent: Double // Total time spent on this card
    @NSManaged public var consecutiveCorrect: Int32
    @NSManaged public var consecutiveIncorrect: Int32
    @NSManaged public var masteryLevel: Int16 // 0-100 scale
    @NSManaged public var averageResponseTime: Double // Average time to respond in seconds
    @NSManaged public var creationDate: Date? // When this performance record was created
    
    var accuracyRate: Double {
        guard totalReviews > 0 else { return 0.0 }
        return Double(correctReviews) / Double(totalReviews)
    }
    
    var isMastered: Bool {
        // A card is mastered when:
        // 1. Has been reviewed at least 5 times
        // 2. Has 90%+ accuracy
        // 3. Has at least 3 consecutive correct answers
        // 4. Has a mastery level of 85 or higher
        return totalReviews >= 5 && 
               accuracyRate >= 0.9 && 
               consecutiveCorrect >= 3 && 
               masteryLevel >= 85
    }
    
    var needsReview: Bool {
        guard let nextReviewDate = nextReviewDate else { return true }
        return Date() >= nextReviewDate
    }
}

/// Represents daily learning statistics
@objc(DailyStats)
public final class DailyStats: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var totalStudyTime: Double
    @NSManaged public var cardsStudied: Int32
    @NSManaged public var newCardsAdded: Int32
    @NSManaged public var sessionsCompleted: Int32
    @NSManaged public var streakDays: Int32
    @NSManaged public var languagePair: String?
    
    var averageSessionTime: Double {
        guard sessionsCompleted > 0 else { return 0.0 }
        return totalStudyTime / Double(sessionsCompleted)
    }
}

// MARK: - Convenience Initializers

extension StudySession {
    convenience init(
        startTime: Date = Date(),
        sessionType: String = "review",
        languagePair: String,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = UUID().uuidString
        self.startTime = startTime
        self.sessionType = sessionType
        self.languagePair = languagePair
        self.duration = 0.0
        self.cardsReviewed = 0
        self.cardsCorrect = 0
        self.cardsIncorrect = 0
    }
}

extension CardPerformance {
    convenience init(
        cardId: String,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = UUID().uuidString
        self.cardId = cardId
        self.totalReviews = 0
        self.correctReviews = 0
        self.incorrectReviews = 0
        self.difficultyLevel = 3
        self.timeSpent = 0.0
        self.consecutiveCorrect = 0
        self.consecutiveIncorrect = 0
        self.masteryLevel = 0
        self.averageResponseTime = 0.0
        self.creationDate = Date()
    }
}

extension DailyStats {
    convenience init(
        date: Date = Date(),
        languagePair: String,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.id = UUID().uuidString
        self.date = date
        self.languagePair = languagePair
        self.totalStudyTime = 0.0
        self.cardsStudied = 0
        self.newCardsAdded = 0
        self.sessionsCompleted = 0
        self.streakDays = 0
    }
}

// MARK: - Fetch Requests

extension StudySession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StudySession> {
        return NSFetchRequest<StudySession>(entityName: "StudySession")
    }
}

extension CardPerformance {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardPerformance> {
        return NSFetchRequest<CardPerformance>(entityName: "CardPerformance")
    }
}

extension DailyStats {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyStats> {
        return NSFetchRequest<DailyStats>(entityName: "DailyStats")
    }
}

// MARK: - Generated accessors for tags

extension StudySession {
    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)
} 