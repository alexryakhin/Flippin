import Foundation
import CoreData
import Combine
import SwiftUI

// MARK: - Analytics Data Models

struct AccuracyDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let accuracy: Double
}

struct TimelineEvent: Identifiable {
    let id = UUID()
    let date: String
    let title: String
    let description: String
    let isCompleted: Bool
}

struct VocabularyGrowthPoint: Identifiable {
    let id = UUID()
    let date: Date
    let masteredCards: Int
    let totalCards: Int
}

struct LearningMilestone: Identifiable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
    let date: String
}

struct PersonalizedInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct PersonalizedRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let action: String
    let color: Color
}

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
              let startTime = sessionStartTime else { 
            print("📚 No active session to end")
            return 
        }
        
        let duration = Date().timeIntervalSince(startTime)
        session.endTime = Date()
        session.duration = duration
        
        print("📚 Ending study session: \(duration)s, \(session.cardsReviewed) cards reviewed")
        
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
        
        print("📚 Study session ended successfully")
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
    func loadAnalytics() {
        loadCardPerformances()
        loadDailyStats()
        calculateStudyStreak()
        calculateTotalStudyTime()
        calculateTotalCardsMastered()
    }
    
    /// Force refresh analytics data and notify UI
    func refreshAnalytics() {
        loadAnalytics()
        objectWillChange.send()
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
            
            // Check if user studied today
            let hasStudiedToday = stats.contains { stat in
                guard let date = stat.date else { return false }
                return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: today)
            }
            
            if !hasStudiedToday {
                studyStreak = 0
                return
            }
            
            // Calculate consecutive days streak
            var currentDate = today
            var consecutiveDays = 0
            
            while true {
                let hasStudiedOnDate = stats.contains { stat in
                    guard let date = stat.date else { return false }
                    return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: currentDate)
                }
                
                if hasStudiedOnDate {
                    consecutiveDays += 1
                    // Move to previous day
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                } else {
                    break
                }
            }
            
            studyStreak = consecutiveDays
            print("📊 Study streak calculated: \(consecutiveDays) days")
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
            print("📊 Created new daily stats for today")
        }
        
        guard let stats = dailyStats else { 
            print("❌ Failed to get daily stats")
            return 
        }
        
        let previousStudyTime = stats.totalStudyTime
        let previousCardsStudied = stats.cardsStudied
        
        stats.totalStudyTime += session.duration
        stats.cardsStudied += session.cardsReviewed
        stats.sessionsCompleted += 1
        
        // Update streak after updating today's stats
        calculateStudyStreak()
        stats.streakDays = Int32(studyStreak)
        
        print("📊 Updated daily stats - Added: \(session.duration)s, \(session.cardsReviewed) cards")
        print("📊 Total today: \(stats.totalStudyTime)s, \(stats.cardsStudied) cards, \(stats.sessionsCompleted) sessions, Streak: \(studyStreak)")
        
        // Save the updated daily stats
        saveContext()
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
        let allCards = cardsProvider.cards
        let total = allCards.count
        let mastered = cardPerformances.values.filter { $0.isMastered }.count
        let learning = cardPerformances.values.filter { $0.masteryLevel > 0 && !$0.isMastered }.count
        let needsReview = getCardsNeedingReview().count
        
        return (total, mastered, learning, needsReview)
    }
    
    /// Calculate overall accuracy from all card performances
    func getOverallAccuracy() -> Double {
        let performances = cardPerformances.values
        guard !performances.isEmpty else { return 0.0 }
        
        let totalReviews = performances.reduce(0) { $0 + $1.totalReviews }
        let totalCorrect = performances.reduce(0) { $0 + $1.correctReviews }
        
        guard totalReviews > 0 else { return 0.0 }
        let accuracy = Double(totalCorrect) / Double(totalReviews)
        
        print("📊 Accuracy calculation: \(totalCorrect) correct out of \(totalReviews) total reviews = \(accuracy * 100)%")
        
        return accuracy
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
    
    /// Get study data for different time ranges
    func getStudyData(for timeRange: AnalyticsDashboard.TimeRange) -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil // All time
        }
        
        let request = DailyStats.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "date <= %@", today as NSDate)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: true)]
        
        do {
            let stats = try coreDataService.context.fetch(request)
            return stats.compactMap { stat in
                guard let date = stat.date else { return nil }
                return (date: date, studyTime: stat.totalStudyTime, cardsStudied: Int(stat.cardsStudied))
            }
        } catch {
            print("❌ Failed to get study data for \(timeRange): \(error)")
            return []
        }
    }
    
    /// Get study data for DetailedAnalytics time ranges (includes All Time)
    func getDetailedAnalyticsStudyData(for timeRange: AnalyticsDashboard.TimeRange) -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil // All time
        }
        
        let request = DailyStats.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "date <= %@", today as NSDate)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: true)]
        
        do {
            let stats = try coreDataService.context.fetch(request)
            return stats.compactMap { stat in
                guard let date = stat.date else { return nil }
                return (date: date, studyTime: stat.totalStudyTime, cardsStudied: Int(stat.cardsStudied))
            }
        } catch {
            print("❌ Failed to get detailed analytics study data for \(timeRange): \(error)")
            return []
        }
    }
    
    /// Get study patterns analysis
    func getStudyPatterns() -> (mostActiveTime: String, preferredSessionLength: String, studyFrequency: String) {
        let request = StudySession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StudySession.startTime, ascending: false)]
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            
            // Calculate most active time
            let mostActiveTime = calculateMostActiveTime(from: sessions)
            
            // Calculate preferred session length
            let preferredSessionLength = calculatePreferredSessionLength(from: sessions)
            
            // Calculate study frequency
            let studyFrequency = calculateStudyFrequency(from: sessions)
            
            return (mostActiveTime, preferredSessionLength, studyFrequency)
        } catch {
            print("❌ Failed to get study patterns: \(error)")
            return ("Not enough data", "Not enough data", "Not enough data")
        }
    }
    
    /// Calculate most active study time
    private func calculateMostActiveTime(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return "Not enough data" }
        
        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]
        
        for session in sessions {
            guard let startTime = session.startTime else { continue }
            let hour = calendar.component(.hour, from: startTime)
            hourCounts[hour, default: 0] += 1
        }
        
        guard let mostActiveHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return "Not enough data"
        }
        
        switch mostActiveHour {
        case 6..<12:
            return "Morning (6-12 AM)"
        case 12..<17:
            return "Afternoon (12-5 PM)"
        case 17..<21:
            return "Evening (5-9 PM)"
        case 21..<24, 0..<6:
            return "Night (9 PM-6 AM)"
        default:
            return "Evening (5-9 PM)"
        }
    }
    
    /// Calculate preferred session length
    private func calculatePreferredSessionLength(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return "Not enough data" }
        
        let durations = sessions.compactMap { $0.duration }.filter { $0 > 0 }
        guard !durations.isEmpty else { return "Not enough data" }
        
        let averageDuration = durations.reduce(0, +) / Double(durations.count)
        let minutes = Int(averageDuration / 60)
        
        if minutes < 10 {
            return "Under 10 minutes"
        } else if minutes < 20 {
            return "10-20 minutes"
        } else if minutes < 30 {
            return "20-30 minutes"
        } else if minutes < 60 {
            return "30-60 minutes"
        } else {
            return "Over 60 minutes"
        }
    }
    
    /// Calculate study frequency
    private func calculateStudyFrequency(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return "Not enough data" }
        
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let recentSessions = sessions.filter { session in
            guard let startTime = session.startTime else { return false }
            return startTime >= weekAgo
        }
        
        let sessionCount = recentSessions.count
        
        switch sessionCount {
        case 0:
            return "No recent activity"
        case 1:
            return "Once this week"
        case 2...3:
            return "A few times this week"
        case 4...6:
            return "Most days this week"
        case 7...:
            return "Daily"
        default:
            return "Not enough data"
        }
    }
    
    /// Get language progress data
    func getLanguageProgress() -> (languagePair: String, progress: Double, vocabularyCount: Int) {
        let languagePair = "\(languageManager.userLanguage.displayName) → \(languageManager.targetLanguage.displayName)"
        
        // Calculate progress based on mastered cards vs total cards
        let totalCards = cardsProvider.cards.count
        let masteredCards = totalCardsMastered
        let progress = totalCards > 0 ? Double(masteredCards) / Double(totalCards) : 0.0
        
        return (languagePair, progress, totalCards)
    }
    
    /// Get time-range-specific study statistics
    func getTimeRangeStudyStats(for timeRange: AnalyticsDashboard.TimeRange) -> (totalStudyTime: TimeInterval, averageSessionTime: TimeInterval, sessionsCount: Int) {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil
        }
        
        let request = DailyStats.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "date <= %@", today as NSDate)
        }
        
        do {
            let stats = try coreDataService.context.fetch(request)
            let totalStudyTime = stats.reduce(0) { $0 + $1.totalStudyTime }
            let totalSessions = stats.reduce(0) { $0 + $1.sessionsCompleted }
            let averageSessionTime = totalSessions > 0 ? totalStudyTime / Double(totalSessions) : 0
            
            return (totalStudyTime, averageSessionTime, Int(totalSessions))
        } catch {
            print("❌ Failed to get time range study stats: \(error)")
            return (0, 0, 0)
        }
    }
    
    /// Get accuracy trends data for the selected time range
    func getAccuracyTrends(for timeRange: AnalyticsDashboard.TimeRange) -> [AccuracyDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        let numberOfDays: Int
        
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
            numberOfDays = 7
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: today)!
            numberOfDays = 30
        case .year:
            startDate = calendar.date(byAdding: .day, value: -365, to: today)!
            numberOfDays = 365
        case .all:
            startDate = nil
            numberOfDays = 365 // Show last year for all time
        }
        
        let request = DailyStats.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "date <= %@", today as NSDate)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: true)]
        
        do {
            let stats = try coreDataService.context.fetch(request)
            return stats.compactMap { stat in
                guard let date = stat.date else { return nil }
                // Calculate daily accuracy based on card performances for that day
                let dailyAccuracy = calculateDailyAccuracy(for: date)
                return AccuracyDataPoint(date: date, accuracy: dailyAccuracy)
            }
        } catch {
            print("❌ Failed to get accuracy trends: \(error)")
            return []
        }
    }
    
    /// Calculate daily accuracy for a specific date
    private func calculateDailyAccuracy(for date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Get all card performances that were reviewed on this day
        let performances = cardPerformances.values.filter { performance in
            guard let lastReviewed = performance.lastReviewed else { return false }
            return lastReviewed >= startOfDay && lastReviewed < endOfDay
        }
        
        guard !performances.isEmpty else { return 0.0 }
        
        let totalReviews = performances.reduce(0) { $0 + $1.totalReviews }
        let totalCorrect = performances.reduce(0) { $0 + $1.correctReviews }
        
        return totalReviews > 0 ? Double(totalCorrect) / Double(totalReviews) : 0.0
    }
    
    /// Get session performance metrics for the selected time range
    func getSessionPerformance(for timeRange: AnalyticsDashboard.TimeRange) -> (averageDuration: TimeInterval, cardsPerSession: Double, sessionFrequency: Double) {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil
        }
        
        let request = StudySession.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "startTime >= %@ AND startTime <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "startTime <= %@", today as NSDate)
        }
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            let validSessions = sessions.filter { $0.duration > 0 }
            
            guard !validSessions.isEmpty else { return (0, 0, 0) }
            
            let averageDuration = validSessions.reduce(0) { $0 + $1.duration } / Double(validSessions.count)
            let totalCards = validSessions.reduce(0) { $0 + $1.cardsReviewed }
            let cardsPerSession = Double(totalCards) / Double(validSessions.count)
            
            // Calculate session frequency (sessions per day)
            let daysInRange: Double
            if let startDate = startDate {
                daysInRange = Double(calendar.dateComponents([.day], from: startDate, to: today).day ?? 1)
            } else {
                daysInRange = 365 // Assume 1 year for all time
            }
            let sessionFrequency = Double(validSessions.count) / daysInRange
            
            return (averageDuration, cardsPerSession, sessionFrequency)
        } catch {
            print("❌ Failed to get session performance: \(error)")
            return (0, 0, 0)
        }
    }
    
    /// Get card difficulty distribution
    func getCardDifficultyDistribution() -> [(level: String, count: Int, percentage: Int, color: Color)] {
        let performances = cardPerformances.values
        guard !performances.isEmpty else { return [] }
        
        var distribution: [Int16: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        
        for performance in performances {
            let difficulty = performance.difficultyLevel
            distribution[difficulty, default: 0] += 1
        }
        
        let total = performances.count
        let easy = distribution[1, default: 0] + distribution[2, default: 0]
        let medium = distribution[3, default: 0]
        let hard = distribution[4, default: 0] + distribution[5, default: 0]
        
        return [
            ("Easy", easy, total > 0 ? Int(Double(easy) / Double(total) * 100) : 0, .green),
            ("Medium", medium, total > 0 ? Int(Double(medium) / Double(total) * 100) : 0, .orange),
            ("Hard", hard, total > 0 ? Int(Double(hard) / Double(total) * 100) : 0, .red)
        ]
    }
    
    /// Get learning speed metrics
    func getLearningSpeedMetrics() -> (cardsPerHour: Double, vsAverage: Double) {
        let performances = cardPerformances.values
        guard !performances.isEmpty else { return (0, 0) }
        
        let totalTime = performances.reduce(0) { $0 + $1.timeSpent }
        let totalCards = performances.reduce(0) { $0 + $1.totalReviews }
        
        guard totalTime > 0 else { return (0, 0) }
        
        let cardsPerHour = Double(totalCards) / (totalTime / 3600) // Convert seconds to hours
        
        // Calculate vs average (assuming 20 cards/hour is average)
        let averageCardsPerHour = 20.0
        let vsAverage = cardsPerHour - averageCardsPerHour
        
        return (cardsPerHour, vsAverage)
    }
    
    /// Get mastery timeline events for the selected time range
    func getMasteryTimelineEvents(for timeRange: AnalyticsDashboard.TimeRange) -> [TimelineEvent] {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil
        }
        
        var events: [TimelineEvent] = []
        
        // Get study sessions for the time range
        let request = StudySession.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "startTime >= %@ AND startTime <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "startTime <= %@", today as NSDate)
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StudySession.startTime, ascending: false)]
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            
            // Add recent study session events
            let recentSessions = Array(sessions.prefix(3))
            for session in recentSessions {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                let dateString = dateFormatter.string(from: session.startTime ?? Date())
                
                let event = TimelineEvent(
                    date: dateString,
                    title: "Completed study session",
                    description: "Reviewed \(session.cardsReviewed) cards in \(session.duration.formattedStudyTime)",
                    isCompleted: true
                )
                events.append(event)
            }
            
            // Add mastery milestone events
            let masteredCards = cardPerformances.values.filter { $0.masteryLevel >= 5 }.count
            if masteredCards > 0 {
                let event = TimelineEvent(
                    date: "Recent",
                    title: "Reached \(masteredCards) cards mastered",
                    description: "Great progress! You're building a strong foundation.",
                    isCompleted: true
                )
                events.append(event)
            }
            
        } catch {
            print("❌ Failed to get mastery timeline events: \(error)")
        }
        
        return events
    }
    
    /// Get vocabulary growth data for the selected time range
    func getVocabularyGrowthData(for timeRange: AnalyticsDashboard.TimeRange) -> (totalCards: Int, weeklyGrowth: Int, growthData: [VocabularyGrowthPoint]) {
        let calendar = Calendar.current
        let today = Date()
        
        let startDate: Date?
        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        case .all:
            startDate = nil
        }
        
        let totalCards = cardsProvider.cards.count
        let masteredCards = cardPerformances.values.filter { $0.masteryLevel >= 5 }.count
        
        // Calculate weekly growth (cards mastered in the last 7 days)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        let weeklyGrowth = cardPerformances.values.filter { performance in
            guard let lastReviewed = performance.lastReviewed else { return false }
            return lastReviewed >= weekAgo && performance.masteryLevel >= 5
        }.count
        
        // Generate growth data points
        var growthData: [VocabularyGrowthPoint] = []
        let numberOfPoints = timeRange == .week ? 7 : (timeRange == .month ? 30 : 12)
        
        for i in 0..<numberOfPoints {
            let date: Date
            if timeRange == .week {
                date = calendar.date(byAdding: .day, value: -i, to: today)!
            } else if timeRange == .month {
                date = calendar.date(byAdding: .day, value: -i, to: today)!
            } else {
                date = calendar.date(byAdding: .month, value: -i, to: today)!
            }
            
            // Simulate growth data (in a real app, this would come from historical data)
            let growthValue = masteredCards - (numberOfPoints - i) * 2
            let point = VocabularyGrowthPoint(
                date: date,
                masteredCards: max(0, growthValue),
                totalCards: totalCards
            )
            growthData.append(point)
        }
        
        growthData.reverse() // Show oldest to newest
        
        return (totalCards, weeklyGrowth, growthData)
    }
    
    /// Get learning milestones with real completion status
    func getLearningMilestones() -> [LearningMilestone] {
        let masteredCards = cardPerformances.values.filter { $0.masteryLevel >= 5 }.count
        
        return [
            LearningMilestone(
                title: "First 10 cards mastered",
                isCompleted: masteredCards >= 10,
                date: masteredCards >= 10 ? "Completed" : "In progress"
            ),
            LearningMilestone(
                title: "7-day study streak",
                isCompleted: studyStreak >= 7,
                date: studyStreak >= 7 ? "Completed" : "In progress"
            ),
            LearningMilestone(
                title: "50 cards mastered",
                isCompleted: masteredCards >= 50,
                date: masteredCards >= 50 ? "Completed" : "In progress"
            ),
            LearningMilestone(
                title: "30-day study streak",
                isCompleted: studyStreak >= 30,
                date: studyStreak >= 30 ? "Completed" : "In progress"
            )
        ]
    }
    
    /// Get personalized insights based on user data
    func getPersonalizedInsights(for timeRange: AnalyticsDashboard.TimeRange) -> [PersonalizedInsight] {
        var insights: [PersonalizedInsight] = []
        
        // Analyze study patterns
        let patterns = getStudyPatterns()
        
        // Insight 1: Most productive time
        if !patterns.mostActiveTime.isEmpty {
            insights.append(PersonalizedInsight(
                title: "You're most productive in the \(patterns.mostActiveTime.lowercased())",
                description: "Your study sessions during this time show better focus and retention.",
                icon: "clock.fill",
                color: .indigo
            ))
        }
        
        // Insight 2: Session length preference
        if !patterns.preferredSessionLength.isEmpty {
            insights.append(PersonalizedInsight(
                title: "Optimal session length",
                description: "Your \(patterns.preferredSessionLength.lowercased()) sessions show the best results.",
                icon: "timer",
                color: .blue
            ))
        }
        
        // Insight 3: Study frequency
        if !patterns.studyFrequency.isEmpty {
            insights.append(PersonalizedInsight(
                title: "Consistent learning pattern",
                description: "Your \(patterns.studyFrequency.lowercased()) study routine is working well.",
                icon: "calendar",
                color: .green
            ))
        }
        
        // Insight 4: Accuracy trends
        let accuracyData = getAccuracyTrends(for: timeRange)
        if accuracyData.count >= 2 {
            let recentAccuracy = accuracyData.suffix(3).map { $0.accuracy }.reduce(0, +) / Double(accuracyData.suffix(3).count)
            let olderAccuracy = accuracyData.prefix(3).map { $0.accuracy }.reduce(0, +) / Double(accuracyData.prefix(3).count)
            
            if recentAccuracy > olderAccuracy {
                insights.append(PersonalizedInsight(
                    title: "Improving accuracy",
                    description: "Your recent accuracy is \(Int((recentAccuracy - olderAccuracy) * 100))% higher than before.",
                    icon: "arrow.up.circle.fill",
                    color: .green
                ))
            } else if recentAccuracy < olderAccuracy {
                insights.append(PersonalizedInsight(
                    title: "Focus on accuracy",
                    description: "Your recent accuracy has decreased. Consider reviewing difficult cards.",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                ))
            }
        }
        
        // Insight 5: Vocabulary growth
        let masteredCards = cardPerformances.values.filter { $0.masteryLevel >= 5 }.count
        let totalCards = cardsProvider.cards.count
        if totalCards > 0 {
            let masteryPercentage = Double(masteredCards) / Double(totalCards)
            if masteryPercentage >= 0.8 {
                insights.append(PersonalizedInsight(
                    title: "Excellent progress",
                    description: "You've mastered \(Int(masteryPercentage * 100))% of your vocabulary!",
                    icon: "star.fill",
                    color: .yellow
                ))
            } else if masteryPercentage >= 0.5 {
                insights.append(PersonalizedInsight(
                    title: "Good foundation",
                    description: "You've mastered \(Int(masteryPercentage * 100))% of your vocabulary. Keep going!",
                    icon: "checkmark.circle.fill",
                    color: .green
                ))
            }
        }
        
        return insights
    }
    
    /// Get personalized recommendations based on user data
    func getPersonalizedRecommendations() -> [PersonalizedRecommendation] {
        var recommendations: [PersonalizedRecommendation] = []
        
        // Recommendation 1: Difficult cards
        let difficultCards = cardPerformances.values.filter { $0.difficultyLevel >= 4 && $0.masteryLevel < 3 }.count
        if difficultCards > 0 {
            recommendations.append(PersonalizedRecommendation(
                title: "Review difficult cards",
                description: "\(difficultCards) cards need more practice. Focus on these to improve accuracy.",
                action: "Start Review",
                color: .orange
            ))
        }
        
        // Recommendation 2: Add more vocabulary
        let masteredCards = cardPerformances.values.filter { $0.masteryLevel >= 5 }.count
        let totalCards = cardsProvider.cards.count
        if Double(masteredCards) >= Double(totalCards) * 0.7 && totalCards < 100 {
            recommendations.append(PersonalizedRecommendation(
                title: "Add more vocabulary",
                description: "You've mastered most of your current cards. Ready for new challenges!",
                action: "Browse Collections",
                color: .blue
            ))
        }
        
        // Recommendation 3: Extend streak (only if haven't studied today)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastStudyDate = getLastStudyDate()
        
        if let lastStudy = lastStudyDate {
            let lastStudyDay = calendar.startOfDay(for: lastStudy)
            if lastStudyDay < today {
                let nextStreakMilestone = getNextStreakMilestone()
                if nextStreakMilestone > 0 {
                    recommendations.append(PersonalizedRecommendation(
                        title: "Extend your streak",
                        description: "You're \(nextStreakMilestone) days away from a new achievement!",
                        action: "Study Now",
                        color: .green
                    ))
                }
            }
        }
        
        // Recommendation 4: Study more frequently
        if studyStreak < 3 {
            recommendations.append(PersonalizedRecommendation(
                title: "Build consistency",
                description: "Try to study daily to build a strong learning habit.",
                action: "Study Now",
                color: .purple
            ))
        }
        
        // Recommendation 5: Focus on accuracy
        let overallAccuracy = getOverallAccuracy()
        if overallAccuracy < 0.7 {
            recommendations.append(PersonalizedRecommendation(
                title: "Improve accuracy",
                description: "Your accuracy is \(Int(overallAccuracy * 100))%. Focus on quality over speed.",
                action: "Practice Mode",
                color: .red
            ))
        }
        
        return recommendations
    }
    
    /// Get next streak milestone
    private func getNextStreakMilestone() -> Int {
        let milestones = [7, 14, 30, 60, 100]
        for milestone in milestones {
            if studyStreak < milestone {
                return milestone - studyStreak
            }
        }
        return 0
    }
    
    /// Get the last study date
    private func getLastStudyDate() -> Date? {
        let request = StudySession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StudySession.startTime, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            return sessions.first?.startTime
        } catch {
            print("❌ Failed to get last study date: \(error)")
            return nil
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
