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
        let onDismiss: () -> Void

        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var tagManager = TagManager.shared
        @StateObject private var navigationManager = NavigationManager.shared
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
                header: LocalizationKeys.Analytics.personalizedInsights.localized,
                backgroundStyle: .standard
            ) {
                if insights.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(LocalizationKeys.Analytics.noInsightsAvailableYet.localized)
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
                header: LocalizationKeys.Analytics.recommendations.localized,
                backgroundStyle: .standard
            ) {
                if recommendations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(LocalizationKeys.Analytics.noRecommendationsAtThisTime.localized)
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
            return CustomSectionView(
                header: LocalizationKeys.Analytics.learningTips.localized,
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    TipCard(
                        title: LocalizationKeys.Analytics.spacedRepetition.localized,
                        description: LocalizationKeys.Analytics.spacedRepetitionDescription.localized,
                        icon: "clock.arrow.circlepath"
                    )

                    TipCard(
                        title: LocalizationKeys.Analytics.activeRecall.localized,
                        description: LocalizationKeys.Analytics.activeRecallDescription.localized,
                        icon: "brain.head.profile"
                    )

                    TipCard(
                        title: LocalizationKeys.Analytics.contextLearning.localized,
                        description: LocalizationKeys.Analytics.contextLearningDescription.localized,
                        icon: "text.bubble"
                    )
                }
            }
        }
        
        private func handleRecommendationAction(_ recommendation: PersonalizedRecommendation) {
            switch recommendation.action {
            case .studyNow:
                onDismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    navigationManager.switchToTab(.stack)
                })
            case .startReview:
                tagManager.isDifficultFilterOn = true
                tagManager.selectedFilterTag = nil
                tagManager.isFavoriteFilterOn = false
                onDismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    navigationManager.switchToTab(.stack)
                })
            case .browseCollections:
                showingPresetCollections = true
            case .practiceMode:
                onDismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    navigationManager.switchToTab(.practice)
                })
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
        let action: PersonalizedRecommendation.Action
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
                    Text(action.name)
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
