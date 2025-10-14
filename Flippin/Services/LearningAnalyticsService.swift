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

    enum Action {
        case studyNow
        case startReview
        case browseCollections
        case practiceMode

        var name: String {
            switch self {
            case .studyNow:
                return Loc.DetailedAnalytics.studyNow
            case .startReview:
                return Loc.DetailedAnalytics.startReview
            case .browseCollections:
                return Loc.DetailedAnalytics.browseCollections
            case .practiceMode:
                return Loc.DetailedAnalytics.practiceMode
            }
        }
    }

    let id = UUID()
    let title: String
    let description: String
    let action: Action
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

        debugPrint("📚 Started study session: \(sessionType)")
    }

    /// End the current study session
    func endStudySession() {
        guard let session = currentSession,
              let startTime = sessionStartTime else {
            debugPrint("📚 No active session to end")
            return
        }

        let duration = Date().timeIntervalSince(startTime)
        session.endTime = Date()
        session.duration = duration

        debugPrint("📚 Ending study session: \(duration)s, \(session.cardsReviewed) cards reviewed")

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

        debugPrint("📚 Study session ended successfully")
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
        initializeStudyStreak()
        calculateTotalStudyTime()
        calculateTotalCardsMastered()
    }

    /// Force refresh analytics data and notify UI
    func refreshAnalytics() {
        loadAnalytics()
        objectWillChange.send()
    }

    /// Initialize study streak properly when app starts
    private func initializeStudyStreak() {
        let request = DailyStats.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: false)]

        do {
            let stats = try coreDataService.context.fetch(request)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // Check if user studied today
            let hasStudiedToday = stats.contains { stat in
                guard let date = stat.date else { return false }
                return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: today)
            }

            if hasStudiedToday {
                // If user has studied today, calculate the streak normally
                calculateStudyStreak()
            } else {
                // If user hasn't studied today, calculate streak from previous days
                calculateStreakFromPreviousDays(stats: stats, calendar: calendar, today: today)
            }
        } catch {
            debugPrint("❌ Failed to initialize study streak: \(error)")
        }
    }

    /// Calculate streak from previous days when user hasn't studied today
    private func calculateStreakFromPreviousDays(stats: [DailyStats], calendar: Calendar, today: Date) {
        var currentDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
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
        debugPrint("📊 Study streak initialized from previous days: \(consecutiveDays) days")
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
            debugPrint("❌ Failed to load card performances: \(error)")
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
            debugPrint("❌ Failed to load daily stats: \(error)")
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
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // Check if user studied today
            let hasStudiedToday = stats.contains { stat in
                guard let date = stat.date else { return false }
                return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: today)
            }

            // If no daily stats exist for today, we can't calculate a streak yet
            // This prevents the streak from being reset to 0 when the app starts
            if !hasStudiedToday {
                // Don't reset streak to 0 here - just return the current value
                // The streak will be properly calculated when a session ends
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

            let oldStreak = studyStreak
            studyStreak = consecutiveDays
            debugPrint("📊 Study streak calculated: \(consecutiveDays) days")
            
            // Track study streak extended if it increased
            if studyStreak > oldStreak {
                AnalyticsService.trackEvent(.studyStreakExtended, parameters: [
                    "new_streak": studyStreak,
                    "previous_streak": oldStreak
                ])
            }
        } catch {
            debugPrint("❌ Failed to calculate study streak: \(error)")
        }
    }

    /// Calculate total study time
    private func calculateTotalStudyTime() {
        let request = StudySession.fetchRequest()

        do {
            let sessions = try coreDataService.context.fetch(request)
            totalStudyTime = sessions.reduce(0) { $0 + $1.duration }
        } catch {
            debugPrint("❌ Failed to calculate total study time: \(error)")
        }
    }

    /// Get today's study time from formal study sessions only
    func getTodayStudyTime() -> TimeInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let request = StudySession.fetchRequest()
        request.predicate = NSPredicate(format: "startTime >= %@ AND startTime < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            return sessions.reduce(0) { $0 + $1.duration }
        } catch {
            debugPrint("❌ Failed to calculate today's study time: \(error)")
            return 0
        }
    }

    /// Get average session time from formal study sessions
    func getAverageSessionTime() -> TimeInterval {
        let request = StudySession.fetchRequest()
        
        do {
            let sessions = try coreDataService.context.fetch(request)
            guard !sessions.isEmpty else { return 0 }
            
            let totalTime = sessions.reduce(0) { $0 + $1.duration }
            return totalTime / Double(sessions.count)
        } catch {
            debugPrint("❌ Failed to calculate average session time: \(error)")
            return 0
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
        let totalReviews = performance.totalReviews
        
        // Base mastery calculation based on accuracy
        var mastery = Int16(accuracy * 100)
        
        // Require minimum reviews before considering mastery
        if totalReviews < 3 {
            // Not enough data yet - cap mastery at 50%
            mastery = min(mastery, 50)
        } else if totalReviews < 5 {
            // Some data but not enough for full mastery - cap at 75%
            mastery = min(mastery, 75)
        }
        
        // Bonus for consecutive correct answers (only if enough reviews)
        if totalReviews >= 3 {
            if consecutiveCorrect >= 5 {
                mastery += 15
            } else if consecutiveCorrect >= 3 {
                mastery += 10
            }
        }
        
        // Penalty for recent mistakes
        if performance.consecutiveIncorrect >= 2 {
            mastery -= 20
        } else if performance.consecutiveIncorrect >= 1 {
            mastery -= 10
        }
        
        // Ensure mastery stays within bounds
        let oldMasteryLevel = performance.masteryLevel
        performance.masteryLevel = max(0, min(100, mastery))
        
        // Track mastery level reached if it increased significantly
        if performance.masteryLevel >= 80 && oldMasteryLevel < 80 {
            AnalyticsService.trackEvent(.masteryLevelReached, parameters: [
                "card_id": performance.cardId ?? "unknown",
                "mastery_level": performance.masteryLevel,
                "accuracy_rate": performance.accuracyRate
            ])
        }
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
            debugPrint("📊 Created new daily stats for today")
        }

        guard let stats = dailyStats else {
            debugPrint("❌ Failed to get daily stats")
            return
        }

        stats.totalStudyTime += session.duration
        stats.cardsStudied += session.cardsReviewed
        stats.sessionsCompleted += 1

        // Update streak after updating today's stats
        // This ensures today's study session is included in the streak calculation
        calculateStreakWithCurrentStats()
        stats.streakDays = Int32(studyStreak)

        debugPrint("📊 Updated daily stats - Added: \(session.duration)s, \(session.cardsReviewed) cards")
        debugPrint("📊 Total today: \(stats.totalStudyTime)s, \(stats.cardsStudied) cards, \(stats.sessionsCompleted) sessions, Streak: \(studyStreak)")

        // Save the updated daily stats
        saveContext()
    }

    /// Calculate streak using current in-memory dailyStats
    private func calculateStreakWithCurrentStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // If we have dailyStats for today, calculate streak including today
        if let currentStats = dailyStats, let currentDate = currentStats.date,
           calendar.isDate(calendar.startOfDay(for: currentDate), inSameDayAs: today) {
            
            // Fetch all daily stats from Core Data
            let request = DailyStats.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \DailyStats.date, ascending: false)]

            do {
                let allStats = try coreDataService.context.fetch(request)
                var consecutiveDays = 0
                var currentDate = today

                while true {
                    // Check if we have stats for this date (either from Core Data or in-memory)
                    let hasStudiedOnDate = allStats.contains { stat in
                        guard let date = stat.date else { return false }
                        return calendar.isDate(calendar.startOfDay(for: date), inSameDayAs: currentDate)
                    } || (calendar.isDate(currentDate, inSameDayAs: today) && currentStats.cardsStudied > 0)

                    if hasStudiedOnDate {
                        consecutiveDays += 1
                        // Move to previous day
                        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    } else {
                        break
                    }
                }

                let oldStreak = studyStreak
                studyStreak = consecutiveDays
                debugPrint("📊 Study streak calculated with current stats: \(consecutiveDays) days")
                
                // Track study streak extended if it increased
                if studyStreak > oldStreak {
                    AnalyticsService.trackEvent(.studyStreakExtended, parameters: [
                        "new_streak": studyStreak,
                        "previous_streak": oldStreak
                    ])
                }
            } catch {
                debugPrint("❌ Failed to calculate streak with current stats: \(error)")
            }
        }
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
            debugPrint("❌ Failed to get cards by difficulty: \(error)")
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
        case 1: return Loc.LearningAnalyticsService.veryEasy
        case 2: return Loc.LearningAnalyticsService.easy
        case 3: return Loc.LearningAnalyticsService.medium
        case 4: return Loc.LearningAnalyticsService.hard
        case 5: return Loc.LearningAnalyticsService.veryHard
        default: return Loc.LearningAnalyticsService.unknown
        }
    }

    /// Get cards that need review
    func getCardsNeedingReview() -> [CardItem] {
        let cardsProvider = CardsProvider.shared
        let allCards = cardsProvider.cards

        let cardsNeedingReview = allCards.filter { card in
            guard let cardId = card.id else { return false }
            let performance = cardPerformances[cardId]

            // If no performance data exists, card needs review
            guard let performance = performance else { return true }

            // Check if card needs review based on nextReviewDate
            if performance.needsReview {
                return true
            }

            // Also include difficult cards (level 4-5) that should be reviewed more frequently
            if performance.difficultyLevel >= 4 {
                return true
            }

            return false
        }

        return cardsNeedingReview
    }

    /// Get difficult cards (level 4-5) that need review
    func getDifficultCardsNeedingReview() -> [CardItem] {
        let cardsProvider = CardsProvider.shared
        return cardsProvider.cards.filter { card in
            guard let cardId = card.id else { return false }
            let performance = cardPerformances[cardId]

            // If no performance data exists, don't include in difficult cards
            guard let performance = performance else { return false }

            // Only include cards with difficulty level 4 or 5
            return performance.difficultyLevel >= 4
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

        debugPrint("📊 Accuracy calculation: \(totalCorrect) correct out of \(totalReviews) total reviews = \(accuracy * 100)%")

        return accuracy
    }

    /// Get study time statistics
    func getStudyTimeStats() -> (total: TimeInterval, today: TimeInterval, average: TimeInterval) {
        let total = totalStudyTime
        let today = dailyStats?.totalStudyTime ?? 0
        let average = dailyStats?.averageSessionTime ?? 0

        return (total, today, average)
    }

    /// Get total study time including both formal sessions and card flipping
    func getTotalStudyTimeIncludingCardFlipping() -> TimeInterval {
        // Get all daily stats to calculate total study time including card flipping
        let request = DailyStats.fetchRequest()
        
        do {
            let allStats = try coreDataService.context.fetch(request)
            let totalStudyTimeIncludingCardFlipping = allStats.reduce(0) { $0 + $1.totalStudyTime }
            return totalStudyTimeIncludingCardFlipping
        } catch {
            debugPrint("❌ Failed to calculate total study time including card flipping: \(error)")
            return totalStudyTime // Fallback to formal sessions only
        }
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
            debugPrint("❌ Failed to get weekly study data: \(error)")
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
            request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        }

        do {
            let stats = try coreDataService.context.fetch(request)
            
            // Group by date and sum the values
            var groupedData: [Date: (studyTime: TimeInterval, cardsStudied: Int)] = [:]
            
            for stat in stats where stat.date != nil {
                let date = stat.date!
                let existing = groupedData[date] ?? (studyTime: 0, cardsStudied: 0)
                groupedData[date] = (
                    studyTime: existing.studyTime + stat.totalStudyTime,
                    cardsStudied: existing.cardsStudied + Int(stat.cardsStudied)
                )
            }
            
            // Convert to array and sort by date
            return groupedData.map { (date, data) in
                (date: date, studyTime: data.studyTime, cardsStudied: data.cardsStudied)
            }.sorted { $0.date < $1.date }
            
        } catch {
            debugPrint("❌ Failed to fetch study data: \(error)")
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
            debugPrint("❌ Failed to get detailed analytics study data for \(timeRange): \(error)")
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
            debugPrint("❌ Failed to get study patterns: \(error)")
            return (Loc.LearningAnalyticsService.notEnoughData, Loc.LearningAnalyticsService.notEnoughData, Loc.LearningAnalyticsService.notEnoughData)
        }
    }

    /// Calculate most active study time
    private func calculateMostActiveTime(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return Loc.LearningAnalyticsService.notEnoughData }

        let calendar = Calendar.current
        var hourCounts: [Int: Int] = [:]

        for session in sessions {
            guard let startTime = session.startTime else { continue }
            let hour = calendar.component(.hour, from: startTime)
            hourCounts[hour, default: 0] += 1
        }

        guard let mostActiveHour = hourCounts.max(by: { $0.value < $1.value })?.key else {
            return Loc.LearningAnalyticsService.notEnoughData
        }

        switch mostActiveHour {
        case 6..<12:
            return Loc.LearningAnalyticsService.morning
        case 12..<17:
            return Loc.LearningAnalyticsService.afternoon
        case 17..<21:
            return Loc.LearningAnalyticsService.evening
        case 21..<24, 0..<6:
            return Loc.LearningAnalyticsService.night
        default:
            return Loc.LearningAnalyticsService.evening
        }
    }

    /// Calculate preferred session length
    private func calculatePreferredSessionLength(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return Loc.LearningAnalyticsService.notEnoughData }

        let durations = sessions.compactMap { $0.duration }.filter { $0 > 0 }
        guard !durations.isEmpty else { return Loc.LearningAnalyticsService.notEnoughData }

        let averageDuration = durations.reduce(0, +) / Double(durations.count)
        let minutes = Int(averageDuration / 60)

        if minutes < 10 {
            return Loc.LearningAnalyticsService.under10Minutes
        } else if minutes < 20 {
            return Loc.LearningAnalyticsService.tenTo20Minutes
        } else if minutes < 30 {
            return Loc.LearningAnalyticsService.twentyTo30Minutes
        } else if minutes < 60 {
            return Loc.LearningAnalyticsService.thirtyTo60Minutes
        } else {
            return Loc.LearningAnalyticsService.over60Minutes
        }
    }

    /// Calculate study frequency
    private func calculateStudyFrequency(from sessions: [StudySession]) -> String {
        guard !sessions.isEmpty else { return Loc.LearningAnalyticsService.notEnoughData }

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
            return Loc.Analytics.noRecentActivity
        case 1:
            return Loc.LearningAnalyticsService.onceThisWeek
        case 2...3:
            return Loc.LearningAnalyticsService.fewTimesThisWeek
        case 4...6:
            return Loc.LearningAnalyticsService.mostDaysThisWeek
        case 7...:
            return Loc.LearningAnalyticsService.daily
        default:
            return Loc.LearningAnalyticsService.notEnoughData
        }
    }

    /// Get language progress data
    func getLanguageProgress() -> (languagePair: String, progress: Double, vocabularyCount: Int) {
        let languagePair = "\(languageManager.userLanguage.displayName) → \(languageManager.targetLanguage.displayName)"

        // Get cards for current language pair only
        let currentLanguageCards = cardsProvider.cards.filter { card in
            card.frontLanguage == languageManager.targetLanguage &&
            card.backLanguage == languageManager.userLanguage
        }

        // Calculate mastered cards for current language pair only
        let currentLanguageMastered = currentLanguageCards.filter { card in
            guard let performance = getCardPerformance(for: card.id) else { return false }
            return performance.isMastered
        }.count

        let totalCards = currentLanguageCards.count
        let progress = totalCards > 0 ? Double(currentLanguageMastered) / Double(totalCards) : 0.0

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

        let request = StudySession.fetchRequest()
        if let startDate = startDate {
            request.predicate = NSPredicate(format: "startTime >= %@ AND startTime <= %@", startDate as NSDate, today as NSDate)
        } else {
            request.predicate = NSPredicate(format: "startTime <= %@", today as NSDate)
        }

        do {
            let sessions = try coreDataService.context.fetch(request)
            let totalStudyTime = sessions.reduce(0) { $0 + $1.duration }
            let totalSessions = sessions.count
            let averageSessionTime = totalSessions > 0 ? totalStudyTime / Double(totalSessions) : 0

            return (totalStudyTime, averageSessionTime, totalSessions)
        } catch {
            debugPrint("❌ Failed to get time range study stats: \(error)")
            return (0, 0, 0)
        }
    }

    /// Get accuracy trends data for the selected time range
    func getAccuracyTrends(for timeRange: AnalyticsDashboard.TimeRange) -> [AccuracyDataPoint] {
        let calendar = Calendar.current
        let today = Date()

        let startDate: Date?

        switch timeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today)
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: today)
        case .year:
            startDate = calendar.date(byAdding: .day, value: -365, to: today)
        case .all:
            startDate = nil
        }

        let request = DailyStats.fetchRequest()
        if let startDate {
            request.predicate = NSPredicate(
                format: "date >= %@ AND date <= %@",
                startDate as NSDate,
                today as NSDate
            )
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
            debugPrint("❌ Failed to get accuracy trends: \(error)")
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
            debugPrint("❌ Failed to get session performance: \(error)")
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
            (Loc.LearningAnalyticsService.easy, easy, total > 0 ? Int(Double(easy) / Double(total) * 100) : 0, .green),
            (Loc.LearningAnalyticsService.medium, medium, total > 0 ? Int(Double(medium) / Double(total) * 100) : 0, .orange),
            (Loc.LearningAnalyticsService.hard, hard, total > 0 ? Int(Double(hard) / Double(total) * 100) : 0, .red)
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
                    title: Loc.LearningAnalyticsService.completedStudySession,
                    description: Loc.LearningAnalyticsService.reviewedCardsInTime(Int(session.cardsReviewed), session.duration.formattedStudyTime),
                    isCompleted: true
                )
                events.append(event)
            }

            // Add mastery milestone events
            let masteredCards = cardPerformances.values.filter { $0.isMastered }.count
            if masteredCards > 0 {
                let event = TimelineEvent(
                    date: Loc.LearningAnalyticsService.recent,
                    title: Loc.LearningAnalyticsService.reachedCardsMastered(masteredCards),
                    description: Loc.LearningAnalyticsService.greatProgressBuildingFoundation,
                    isCompleted: true
                )
                events.append(event)
            }

        } catch {
            debugPrint("❌ Failed to get mastery timeline events: \(error)")
        }

        return events
    }

    /// Get vocabulary growth data for the selected time range
    func getVocabularyGrowthData(for timeRange: AnalyticsDashboard.TimeRange) -> (totalCards: Int, weeklyGrowth: Int, growthData: [VocabularyGrowthPoint]) {
        let calendar = Calendar.current
        let today = Date()

        let totalCards = cardsProvider.cards.count
        let masteredCards = cardPerformances.values.filter { $0.isMastered }.count

        // Calculate growth for the selected time range
        let growthPeriod: Int

        switch timeRange {
        case .week:
            growthPeriod = 7
        case .month:
            growthPeriod = 30
        case .year:
            growthPeriod = 365
        case .all:
            growthPeriod = 365
        }
        
        let periodAgo = calendar.date(byAdding: .day, value: -growthPeriod, to: today)!
        let periodGrowth = cardPerformances.values.filter { performance in
            guard let lastReviewed = performance.lastReviewed else { return false }
            return lastReviewed >= periodAgo && performance.isMastered
        }.count

        // Generate growth data points
        var growthData: [VocabularyGrowthPoint] = []
        let numberOfPoints = timeRange == .week ? 7 : (timeRange == .month ? 30 : 12)

        for i in 0..<numberOfPoints {
            let date: Date
            if timeRange == .week {
                date = calendar.date(byAdding: .day, value: -(numberOfPoints - 1 - i), to: today)!
            } else if timeRange == .month {
                date = calendar.date(byAdding: .day, value: -(numberOfPoints - 1 - i), to: today)!
            } else {
                date = calendar.date(byAdding: .month, value: -(numberOfPoints - 1 - i), to: today)!
            }

            // Simulate growth data (in a real app, this would come from historical data)
            let growthValue = masteredCards - (numberOfPoints - 1 - i) * 2
            let point = VocabularyGrowthPoint(
                date: date,
                masteredCards: max(0, growthValue),
                totalCards: totalCards
            )
            growthData.append(point)
        }

        return (totalCards, periodGrowth, growthData)
    }

    /// Get learning milestones with real completion status
    func getLearningMilestones() -> [LearningMilestone] {
        let masteredCards = cardPerformances.values.filter { $0.isMastered }.count

        return [
            LearningMilestone(
                title: Loc.LearningAnalyticsService.first10CardsMastered,
                isCompleted: masteredCards >= 10,
                date: masteredCards >= 10 ? Loc.LearningAnalyticsService.completed : Loc.LearningAnalyticsService.inProgress
            ),
            LearningMilestone(
                title: Loc.LearningAnalyticsService.sevenDayStudyStreak,
                isCompleted: studyStreak >= 7,
                date: studyStreak >= 7 ? Loc.LearningAnalyticsService.completed : Loc.LearningAnalyticsService.inProgress
            ),
            LearningMilestone(
                title: Loc.LearningAnalyticsService.fiftyCardsMastered,
                isCompleted: masteredCards >= 50,
                date: masteredCards >= 50 ? Loc.LearningAnalyticsService.completed : Loc.LearningAnalyticsService.inProgress
            ),
            LearningMilestone(
                title: Loc.LearningAnalyticsService.thirtyDayStudyStreak,
                isCompleted: studyStreak >= 30,
                date: studyStreak >= 30 ? Loc.LearningAnalyticsService.completed : Loc.LearningAnalyticsService.inProgress
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
                title: Loc.LearningAnalyticsService.youreMostProductiveIn(patterns.mostActiveTime.lowercased()),
                description: Loc.LearningAnalyticsService.studySessionsDuringThisTime,
                icon: "clock.fill",
                color: .indigo
            ))
        }

        // Insight 2: Session length preference
        if !patterns.preferredSessionLength.isEmpty {
            insights.append(PersonalizedInsight(
                title: Loc.LearningAnalyticsService.optimalSessionLength,
                description: Loc.LearningAnalyticsService.yourSessionsShowBestResults(patterns.preferredSessionLength.lowercased()),
                icon: "timer",
                color: .blue
            ))
        }

        // Insight 3: Study frequency
        if !patterns.studyFrequency.isEmpty {
            insights.append(PersonalizedInsight(
                title: Loc.LearningAnalyticsService.consistentLearningPattern,
                description: Loc.LearningAnalyticsService.yourStudyRoutineWorkingWell(patterns.studyFrequency.lowercased()),
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
                    title: Loc.LearningAnalyticsService.improvingAccuracy,
                    description: Loc.LearningAnalyticsService.recentAccuracyHigherThanBefore(Int((recentAccuracy - olderAccuracy) * 100)),
                    icon: "arrow.up.circle.fill",
                    color: .green
                ))
            } else if recentAccuracy < olderAccuracy {
                insights.append(PersonalizedInsight(
                    title: Loc.LearningAnalyticsService.focusOnAccuracy,
                    description: Loc.LearningAnalyticsService.recentAccuracyDecreased,
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                ))
            }
        }

        // Insight 5: Vocabulary growth
        let masteredCards = cardPerformances.values.filter { $0.isMastered }.count
        let totalCards = cardsProvider.cards.count
        if totalCards > 0 {
            let masteryPercentage = Double(masteredCards) / Double(totalCards)
            if masteryPercentage >= 0.8 {
                insights.append(PersonalizedInsight(
                    title: Loc.LearningAnalyticsService.excellentProgress,
                    description: Loc.LearningAnalyticsService.masteredVocabularyPercentage(Int(masteryPercentage * 100)),
                    icon: "star.fill",
                    color: .yellow
                ))
            } else if masteryPercentage >= 0.5 {
                insights.append(PersonalizedInsight(
                    title: Loc.LearningAnalyticsService.goodFoundation,
                    description: Loc.LearningAnalyticsService.masteredVocabularyKeepGoing(Int(masteryPercentage * 100)),
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
        let difficultCards = getDifficultCardsNeedingReview()
        if !difficultCards.isEmpty {
            recommendations.append(PersonalizedRecommendation(
                title: Loc.LearningAnalyticsService.reviewDifficultCards,
                description: Loc.LearningAnalyticsService.cardsNeedMorePractice(difficultCards.count),
                action: .startReview,
                color: .orange
            ))
        }

        // Recommendation 2: Add more vocabulary
        let masteredCards = cardPerformances.values.filter { $0.isMastered }.count
        let totalCards = cardsProvider.cards.count
        if Double(masteredCards) >= Double(totalCards) * 0.7 && totalCards < 100 {
            recommendations.append(PersonalizedRecommendation(
                title: Loc.LearningAnalyticsService.addMoreVocabulary,
                description: Loc.LearningAnalyticsService.masteredMostCurrentCards,
                action: .browseCollections,
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
                        title: Loc.LearningAnalyticsService.extendYourStreak,
                        description: Loc.LearningAnalyticsService.daysAwayFromAchievement(nextStreakMilestone),
                        action: .studyNow,
                        color: .green
                    ))
                }
            }
        }

        // Recommendation 4: Study more frequently
        if studyStreak < 3 {
            recommendations.append(PersonalizedRecommendation(
                title: Loc.LearningAnalyticsService.buildConsistency,
                description: Loc.LearningAnalyticsService.tryToStudyDaily,
                action: .studyNow,
                color: .purple
            ))
        }

        // Recommendation 5: Focus on accuracy
        let overallAccuracy = getOverallAccuracy()
        if overallAccuracy < 0.7 {
            recommendations.append(PersonalizedRecommendation(
                title: Loc.LearningAnalyticsService.improveAccuracy,
                description: Loc.LearningAnalyticsService.accuracyPercentageFocusQuality(Int(overallAccuracy * 100)),
                action: .practiceMode,
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
            debugPrint("❌ Failed to get last study date: \(error)")
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
            debugPrint("❌ Failed to save analytics context: \(error)")
        }
    }
}
