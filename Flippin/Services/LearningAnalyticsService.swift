import Foundation
import CoreData
import Combine
import SwiftUI

// MARK: - Learning Analytics Service

@MainActor
final class LearningAnalyticsService: ObservableObject {
    static let shared = LearningAnalyticsService()
    
    @Published var currentSession: StudySession?
    @Published var dailyStats: DailyStats?
    @Published var cardPerformances: [String: CardPerformance] = [:]
    @Published var studyStreak: Int = 0
    @Published var totalStudyTime: TimeInterval = 0
    @Published var totalCardsMastered: Int = 0
    
    private let coreDataService = CoreDataService.shared
    private let languageManager = LanguageManager.shared
    private let cardsProvider = CardsProvider.shared

    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadAnalytics()
        setupObservers()
    }
    
    // MARK: - Study Session Management
    
    /// Start a new study session
    func startStudySession(sessionType: String = "review") {
        let languagePair = "\(languageManager.userLanguage.rawValue)-\(languageManager.targetLanguage.rawValue)"
        
        currentSession = StudySession(
            startTime: Date(),
            sessionType: sessionType,
            languagePair: languagePair,
            context: coreDataService.context
        )
        
        sessionStartTime = Date()
        
        // Track session start
        AnalyticsService.trackStudySessionEvent(
            .studySessionStarted,
            sessionDuration: nil,
            cardsReviewed: 0
        )
        
        print("📚 Started study session: \(sessionType)")
    }
    
    /// End the current study session
    func endStudySession() {
        guard let session = currentSession,
              let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        session.endTime = Date()
        session.duration = duration
        
        // Update daily stats
        updateDailyStats(session: session)
        
        // Save session
        saveContext()
        
        // Track session end
        AnalyticsService.trackStudySessionEvent(
            .studySessionEnded,
            sessionDuration: duration,
            cardsReviewed: Int(session.cardsReviewed)
        )
        
        // Reset current session
        currentSession = nil
        sessionStartTime = nil
        
        print("📚 Ended study session: \(duration)s, \(session.cardsReviewed) cards reviewed")
    }
    
    /// Record a card review during study session
    func recordCardReview(cardId: String, wasCorrect: Bool, timeSpent: TimeInterval) {
        // Update current session
        if let session = currentSession {
            session.cardsReviewed += 1
            if wasCorrect {
                session.cardsCorrect += 1
            } else {
                session.cardsIncorrect += 1
            }
        }
        
        // Update card performance
        let performance = getOrCreateCardPerformance(for: cardId)
        performance.totalReviews += 1
        performance.timeSpent += timeSpent
        performance.lastReviewed = Date()
        
        if wasCorrect {
            performance.correctReviews += 1
            performance.consecutiveCorrect += 1
            performance.consecutiveIncorrect = 0
        } else {
            performance.incorrectReviews += 1
            performance.consecutiveIncorrect += 1
            performance.consecutiveCorrect = 0
        }
        
        // Update mastery level and difficulty
        updateCardMastery(performance: performance)
        updateAverageResponseTime(performance: performance, timeSpent: timeSpent)
        updateCardDifficulty(performance: performance, timeSpent: timeSpent)
        updateNextReviewDate(performance: performance)
        
        // Update daily stats
        if let dailyStats = dailyStats {
            dailyStats.cardsStudied += 1
            dailyStats.totalStudyTime += timeSpent
        }
        
        // Track card review
        AnalyticsService.trackCardEvent(
            wasCorrect ? .cardReviewedCorrect : .cardReviewedIncorrect,
            cardLanguage: getCardLanguage(for: cardId),
            hasTags: getCardHasTags(for: cardId),
            tagCount: getCardTagCount(for: cardId)
        )
    }
    
    // MARK: - Analytics Data Management
    
    /// Load all analytics data
    private func loadAnalytics() {
        loadCardPerformances()
        loadDailyStats()
        calculateStudyStreak()
        calculateTotalStudyTime()
        calculateTotalCardsMastered()
    }
    
    /// Load card performance data
    private func loadCardPerformances() {
        let request = CardPerformance.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardPerformance.lastReviewed, ascending: false)]
        
        do {
            let performances = try coreDataService.context.fetch(request)
            cardPerformances = Dictionary(uniqueKeysWithValues: performances.compactMap { performance in
                guard let cardId = performance.cardId else { return nil }
                return (cardId, performance)
            })
        } catch {
            print("❌ Failed to load card performances: \(error)")
        }
    }
    
    /// Load daily statistics
    private func loadDailyStats() {
        let today = Calendar.current.startOfDay(for: Date())
        let request = DailyStats.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let stats = try coreDataService.context.fetch(request)
            dailyStats = stats.first
        } catch {
            print("❌ Failed to load daily stats: \(error)")
        }
    }
    
    /// Get or create card performance for a card
    private func getOrCreateCardPerformance(for cardId: String) -> CardPerformance {
        if let existing = cardPerformances[cardId] {
            return existing
        }
        
        let performance = CardPerformance(cardId: cardId, context: coreDataService.context)
        cardPerformances[cardId] = performance
        return performance
    }
    
    // MARK: - Statistics Calculation
    
    /// Calculate study streak
    private func calculateStudyStreak() {
        let request = DailyStats.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: false)]
        
        do {
            let stats = try coreDataService.context.fetch(request)
            var streak = 0
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            for stat in stats {
                guard let date = stat.date else { continue }
                let statDate = calendar.startOfDay(for: date)
                
                if calendar.isDate(statDate, inSameDayAs: today) || 
                   calendar.isDate(statDate, equalTo: calendar.date(byAdding: .day, value: -streak - 1, to: today)!, toGranularity: .day) {
                    streak += 1
                } else {
                    break
                }
            }
            
            studyStreak = streak
        } catch {
            print("❌ Failed to calculate study streak: \(error)")
        }
    }
    
    /// Calculate total study time
    private func calculateTotalStudyTime() {
        let request = StudySession.fetchRequest()
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            totalStudyTime = sessions.reduce(0) { $0 + $1.duration }
        } catch {
            print("❌ Failed to calculate total study time: \(error)")
        }
    }
    
    /// Calculate total cards mastered
    private func calculateTotalCardsMastered() {
        totalCardsMastered = cardPerformances.values.filter { $0.isMastered }.count
    }
    
    // MARK: - Card Mastery System
    
    /// Update card mastery level based on performance
    private func updateCardMastery(performance: CardPerformance) {
        let accuracy = performance.accuracyRate
        let consecutiveCorrect = performance.consecutiveCorrect
        
        // Mastery calculation based on accuracy and consistency
        var mastery = Int16(accuracy * 100)
        
        // Bonus for consecutive correct answers
        if consecutiveCorrect >= 5 {
            mastery += 10
        } else if consecutiveCorrect >= 3 {
            mastery += 5
        }
        
        // Penalty for recent mistakes
        if performance.consecutiveIncorrect >= 2 {
            mastery -= 15
        }
        
        performance.masteryLevel = max(0, min(100, mastery))
    }
    
    /// Update average response time for a card
    private func updateAverageResponseTime(performance: CardPerformance, timeSpent: TimeInterval) {
        let currentTotal = performance.averageResponseTime * Double(performance.totalReviews)
        let newTotal = currentTotal + timeSpent
        let newCount = performance.totalReviews + 1
        
        performance.averageResponseTime = newTotal / Double(newCount)
    }
    
    /// Update card difficulty level based on performance and content
    private func updateCardDifficulty(performance: CardPerformance, timeSpent: TimeInterval) {
        var difficultyScore: Double = 0
        
        // 1. Performance-based factors (60% weight)
        let performanceWeight = 0.6
        
        // Accuracy factor (inverse relationship)
        let accuracyFactor = 1.0 - performance.accuracyRate
        difficultyScore += accuracyFactor * performanceWeight * 0.4
        
        // Response time factor (normalized to 0-1, where 1 = very slow)
        let avgResponseTime = performance.averageResponseTime
        let timeFactor = min(1.0, avgResponseTime / 10.0) // 10 seconds = max difficulty
        difficultyScore += timeFactor * performanceWeight * 0.3
        
        // Consecutive incorrect factor
        let consecutiveIncorrectFactor = min(1.0, Double(performance.consecutiveIncorrect) / 5.0)
        difficultyScore += consecutiveIncorrectFactor * performanceWeight * 0.3
        
        // 2. Content-based factors (30% weight)
        let contentWeight = 0.3
        
        // Card age factor (newer cards are harder)
        if let creationDate = performance.creationDate {
            let daysSinceCreation = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
            let ageFactor = max(0, min(1.0, 1.0 - (Double(daysSinceCreation) / 30.0))) // 30 days to normalize
            difficultyScore += ageFactor * contentWeight * 0.5
        }
        
        // Review frequency factor (more reviews = harder)
        if let creationDate = performance.creationDate {
            let daysSinceCreation = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 1
            let reviewFrequency = Double(performance.totalReviews) / max(1, Double(daysSinceCreation))
            let frequencyFactor = min(1.0, reviewFrequency / 2.0) // 2 reviews per day = max difficulty
            difficultyScore += frequencyFactor * contentWeight * 0.5
        }
        
        // 3. User-specific factors (10% weight)
        let userWeight = 0.1
        
        // Individual learning pattern (compared to user average)
        let userAvgAccuracy = calculateUserAverageAccuracy()
        let userAccuracyFactor = max(0, userAvgAccuracy - performance.accuracyRate)
        difficultyScore += userAccuracyFactor * userWeight
        
        // Convert to 1-5 scale
        let difficultyLevel = Int16(max(1, min(5, round(difficultyScore * 5))))
        performance.difficultyLevel = difficultyLevel
    }
    
    /// Calculate user's average accuracy across all cards
    private func calculateUserAverageAccuracy() -> Double {
        let performances = Array(cardPerformances.values)
        guard !performances.isEmpty else { return 0.5 }
        
        let totalAccuracy = performances.reduce(0.0) { $0 + $1.accuracyRate }
        return totalAccuracy / Double(performances.count)
    }
    
    /// Update next review date using spaced repetition
    private func updateNextReviewDate(performance: CardPerformance) {
        let accuracy = performance.accuracyRate
        let consecutiveCorrect = performance.consecutiveCorrect
        
        var daysToAdd: Int
        
        if accuracy >= 0.9 && consecutiveCorrect >= 3 {
            // Well known: review in 7-30 days
            daysToAdd = Int(min(30, 7 + consecutiveCorrect * 2))
        } else if accuracy >= 0.7 {
            // Known: review in 3-7 days
            daysToAdd = Int(min(7, 3 + consecutiveCorrect))
        } else {
            // Needs work: review soon
            daysToAdd = Int(max(1, 3 - consecutiveCorrect))
        }
        
        performance.nextReviewDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())
    }
    
    // MARK: - Daily Statistics
    
    /// Update daily statistics
    private func updateDailyStats(session: StudySession) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if dailyStats == nil {
            let languagePair = "\(languageManager.userLanguage.rawValue)-\(languageManager.targetLanguage.rawValue)"
            dailyStats = DailyStats(date: today, languagePair: languagePair, context: coreDataService.context)
        }
        
        guard let stats = dailyStats else { return }
        
        stats.totalStudyTime += session.duration
        stats.cardsStudied += session.cardsReviewed
        stats.sessionsCompleted += 1
        
        // Update streak
        calculateStudyStreak()
        stats.streakDays = Int32(studyStreak)
    }
    
    // MARK: - Analytics Queries
    
    /// Get cards by difficulty level
    func getCardsByDifficulty(_ difficulty: Int16) -> [CardItem] {
        let request = CardPerformance.fetchRequest()
        request.predicate = NSPredicate(format: "difficultyLevel == %d", difficulty)
        
        do {
            let performances = try coreDataService.context.fetch(request)
            return performances.compactMap { performance in
                guard let cardId = performance.cardId else { return nil }
                return cardsProvider.cards.first { card in
                    card.id == cardId
                }
            }
        } catch {
            print("❌ Failed to get cards by difficulty: \(error)")
            return []
        }
    }
    
    /// Get difficulty distribution
    func getDifficultyDistribution() -> [Int16: Int] {
        var distribution: [Int16: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        
        for performance in cardPerformances.values {
            let difficulty = performance.difficultyLevel
            distribution[difficulty, default: 0] += 1
        }
        
        return distribution
    }
    
    /// Get card performance for a specific card
    func getCardPerformance(for cardId: String?) -> CardPerformance? {
        guard let cardId else { return nil }
        return cardPerformances[cardId]
    }
    
    /// Get difficulty level description
    func getDifficultyDescription(_ level: Int16) -> String {
        switch level {
        case 1: return "Very Easy"
        case 2: return "Easy"
        case 3: return "Medium"
        case 4: return "Hard"
        case 5: return "Very Hard"
        default: return "Unknown"
        }
    }
    
    /// Get cards that need review
    func getCardsNeedingReview() -> [CardItem] {
        let cardsProvider = CardsProvider.shared
        return cardsProvider.cards.filter { card in
            guard let cardId = card.id else { return false }
            let performance = cardPerformances[cardId]
            return performance?.needsReview ?? true
        }
    }
    
    /// Get mastery statistics
    func getMasteryStats() -> (total: Int, mastered: Int, learning: Int, needsReview: Int) {
        let total = cardPerformances.count
        let mastered = cardPerformances.values.filter { $0.isMastered }.count
        let learning = cardPerformances.values.filter { $0.masteryLevel > 0 && !$0.isMastered }.count
        let needsReview = getCardsNeedingReview().count
        
        return (total, mastered, learning, needsReview)
    }
    
    /// Get study time statistics
    func getStudyTimeStats() -> (total: TimeInterval, today: TimeInterval, average: TimeInterval) {
        let total = totalStudyTime
        let today = dailyStats?.totalStudyTime ?? 0
        let average = dailyStats?.averageSessionTime ?? 0
        
        return (total, today, average)
    }
    
    /// Get weekly study data
    func getWeeklyStudyData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let request = DailyStats.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", weekAgo as NSDate, today as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: true)]
        
        do {
            let stats = try coreDataService.context.fetch(request)
            return stats.compactMap { stat in
                guard let date = stat.date else { return nil }
                return (date: date, studyTime: stat.totalStudyTime, cardsStudied: Int(stat.cardsStudied))
            }
        } catch {
            print("❌ Failed to get weekly study data: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func getCardLanguage(for cardId: String) -> String? {
        let cardsProvider = CardsProvider.shared
        return cardsProvider.cards.first { $0.id == cardId }?.frontLanguage?.rawValue
    }
    
    private func getCardHasTags(for cardId: String) -> Bool? {
        let cardsProvider = CardsProvider.shared
        let card = cardsProvider.cards.first { $0.id == cardId }
        return card?.tagNames.isEmpty == false
    }
    
    private func getCardTagCount(for cardId: String) -> Int? {
        let cardsProvider = CardsProvider.shared
        let card = cardsProvider.cards.first { $0.id == cardId }
        return card?.tagNames.count
    }
    
    // MARK: - Setup and Cleanup
    
    private func setupObservers() {
        // Observe app lifecycle for session management
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.endStudySession()
            }
            .store(in: &cancellables)
    }
    
    private func saveContext() {
        do {
            try coreDataService.saveContext()
            objectWillChange.send()
        } catch {
            print("❌ Failed to save analytics context: \(error)")
        }
    }
}
