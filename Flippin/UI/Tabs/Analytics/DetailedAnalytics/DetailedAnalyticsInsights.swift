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
        @State private var showingPresetCollections = false

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
            .sheet(isPresented: $showingPresetCollections) {
                PresetCollectionsView()
            }
        }

        private var personalizedInsightsSection: some View {
            let insights = analyticsService.getPersonalizedInsights(for: selectedTimeRange)
            
            return CustomSectionView(
                header: "Personalized Insights",
                backgroundStyle: .standard
            ) {
                if insights.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No insights available yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 12) {
                        ForEach(insights) { insight in
                            InsightCard(
                                title: insight.title,
                                description: insight.description,
                                icon: insight.icon,
                                color: insight.color
                            )
                        }
                    }
                }
            }
        }

        private var recommendationsSection: some View {
            let recommendations = analyticsService.getPersonalizedRecommendations()
            
            return CustomSectionView(
                header: "Recommendations",
                backgroundStyle: .standard
            ) {
                if recommendations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No recommendations at this time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 12) {
                        ForEach(recommendations) { recommendation in
                            RecommendationCard(
                                title: recommendation.title,
                                description: recommendation.description,
                                action: recommendation.action,
                                color: recommendation.color,
                                onAction: {
                                    handleRecommendationAction(recommendation)
                                }
                            )
                        }
                    }
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
        
        private func handleRecommendationAction(_ recommendation: PersonalizedRecommendation) {
            switch recommendation.action {
            case "Study Now":
                // Navigate to study mode
                print("🎯 Starting study session from recommendation")
                // In a real app, this would trigger navigation to study mode
                break
            case "Start Review":
                // Navigate to review mode for difficult cards
                print("🎯 Starting review session for difficult cards")
                break
            case "Browse Collections":
                // Present PresetCollectionsView
                showingPresetCollections = true
                break
            case "Practice Mode":
                // Navigate to practice mode
                print("🎯 Starting practice mode")
                break
            default:
                print("🎯 Unknown recommendation action: \(recommendation.action)")
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
        let onAction: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: onAction) {
                    Text(action)
                        .font(.caption)
                        .foregroundColor(color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.1))
                        .clipShape(Capsule())
                }
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
