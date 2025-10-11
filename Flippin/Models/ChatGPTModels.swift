//
//  ChatGPTModels.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import Foundation
import OpenAI

// MARK: - Collection Generation Response

struct GeneratedCollection: JSONSchemaConvertible {
    let collectionName: String
    let description: String
    let cards: [GeneratedCard]
    
    static let example: Self = {
        .init(
            collectionName: "Spanish Restaurant Phrases",
            description: "Essential phrases for ordering food and drinks at restaurants in Spanish",
            cards: [
                GeneratedCard(
                    frontText: "La cuenta, por favor",
                    backText: "The bill, please",
                    notes: "Polite way to ask for the check",
                    tags: ["restaurant", "polite"],
                    difficulty: 2
                ),
                GeneratedCard(
                    frontText: "¿Qué recomienda?",
                    backText: "What do you recommend?",
                    notes: "Useful when you can't decide what to order",
                    tags: ["restaurant", "recommendation"],
                    difficulty: 3
                )
            ]
        )
    }()
}

struct GeneratedCard: Codable {
    let frontText: String
    let backText: String
    let notes: String
    let tags: [String]
    let difficulty: Int
}

// MARK: - Learning Coach Response

struct CoachInsight: Codable, Hashable, JSONSchemaConvertible {
    let title: String
    let summary: String
    let insights: [Insight]
    let recommendations: [Recommendation]
    
    static let example: Self = {
        .init(
            title: "Great Progress This Week! 🎉",
            summary: "You've shown excellent consistency with 5 study days and improved your accuracy to 85%",
            insights: [
                Insight(icon: "checkmark.circle.fill", text: "Consistency is your strength - keep it up!", type: .positive),
                Insight(icon: "exclamationmark.triangle", text: "Some cards are taking longer - consider reviewing them more", type: .warning),
                Insight(icon: "brain.head.profile", text: "Your vocabulary is expanding steadily", type: .neutral)
            ],
            recommendations: [
                Recommendation(action: "Review difficult cards", description: "Spend extra time on cards with low accuracy", priority: 1),
                Recommendation(action: "Increase daily goal", description: "Try adding 5 more cards per day", priority: 2),
                Recommendation(action: "Practice pronunciation", description: "Use text-to-speech for new vocabulary", priority: 3)
            ]
        )
    }()
}

struct Insight: Codable, Hashable {
    let icon: String
    let text: String
    let type: InsightType
}

enum InsightType: String, Codable, JSONSchemaEnumConvertible {
    case positive = "positive"
    case warning = "warning"
    case neutral = "neutral"
    
    var caseNames: [String] { Self.allCases.map { $0.rawValue } }
}

struct Recommendation: Codable, Hashable {
    let action: String
    let description: String
    let priority: Int
}

// MARK: - Analytics Data for Coach

struct AnalyticsDataSnapshot: Codable {
    let weeklyAccuracy: Double
    let cardsReviewed: Int
    let studyConsistency: Int
    let difficultCards: [String]
    let averageTimePerCard: Double
    let masteryDistribution: [String: Int]
    let streakDays: Int
    let totalCards: Int
    let masteredCards: Int
}

