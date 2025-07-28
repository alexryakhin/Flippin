//
//  DetailedAnalyticsInsights.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

extension DetailedAnalytics {

    struct InsightsTab: View {

        let selectedTimeRange: TimeRange

        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Personalized insights
                    personalizedInsightsSection

                    // Recommendations
                    recommendationsSection

                    // Learning tips
                    learningTipsSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
        }

        private var personalizedInsightsSection: some View {
            CustomSectionView(
                header: "Personalized Insights",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    InsightCard(
                        title: "You're most productive in the evening",
                        description: "Your accuracy is 15% higher during 6-9 PM sessions.",
                        icon: "moon.fill",
                        color: .indigo
                    )

                    InsightCard(
                        title: "Shorter sessions work better",
                        description: "Sessions under 20 minutes have 25% higher retention.",
                        icon: "timer",
                        color: .blue
                    )

                    InsightCard(
                        title: "Consistency is key",
                        description: "Daily practice has improved your learning speed by 40%.",
                        icon: "calendar",
                        color: .green
                    )
                }
            }
        }

        private var recommendationsSection: some View {
            CustomSectionView(
                header: "Recommendations",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    RecommendationCard(
                        title: "Review difficult cards",
                        description: "5 cards need more practice. Focus on these to improve accuracy.",
                        action: "Start Review",
                        color: .orange
                    )

                    RecommendationCard(
                        title: "Add more vocabulary",
                        description: "You're ready for intermediate level phrases.",
                        action: "Browse Collections",
                        color: .blue
                    )

                    RecommendationCard(
                        title: "Extend your streak",
                        description: "You're 3 days away from a new achievement!",
                        action: "Study Now",
                        color: .green
                    )
                }
            }
        }

        private var learningTipsSection: some View {
            CustomSectionView(
                header: "Learning Tips",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    TipCard(
                        title: "Spaced Repetition",
                        description: "Review cards at increasing intervals for better retention.",
                        icon: "clock.arrow.circlepath"
                    )

                    TipCard(
                        title: "Active Recall",
                        description: "Try to recall the answer before flipping the card.",
                        icon: "brain.head.profile"
                    )

                    TipCard(
                        title: "Context Learning",
                        description: "Learn words in phrases rather than isolation.",
                        icon: "text.bubble"
                    )
                }
            }
        }
    }

    struct InsightCard: View {
        let title: String
        let description: String
        let icon: String
        let color: Color

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clippedWithPaddingAndBackground(
                color.opacity(0.1),
                cornerRadius: 8
            )
        }
    }

    struct RecommendationCard: View {
        let title: String
        let description: String
        let action: String
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action) {
                    // Handle action
                }
                .font(.caption)
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(color.opacity(0.1))
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clippedWithPaddingAndBackground(
                Color(.tertiarySystemGroupedBackground).opacity(0.6),
                cornerRadius: 8
            )
        }
    }

    struct TipCard: View {
        let title: String
        let description: String
        let icon: String

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clippedWithPaddingAndBackground(
                Color(.tertiarySystemGroupedBackground).opacity(0.6),
                cornerRadius: 8
            )
        }
    }
} 
