//
//  DetailedAnalyticsProgress.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

extension DetailedAnalytics {

    struct ProgressTab: View {

        let selectedTimeRange: TimeRange

        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Mastery timeline
                    masteryTimelineSection

                    // Vocabulary growth
                    vocabularyGrowthSection

                    // Learning milestones
                    learningMilestonesSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
        }

        private var masteryTimelineSection: some View {
            let timelineEvents = analyticsService.getMasteryTimelineEvents(for: selectedTimeRange)

            return CustomSectionView(
                header: LocalizationKeys.Analytics.masteryTimeline.localized,
                backgroundStyle: .standard
            ) {
                if timelineEvents.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "timeline.selection")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(LocalizationKeys.Analytics.noRecentActivity.localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 16) {
                        ForEach(timelineEvents) { event in
                            TimelineEvent(
                                date: event.date,
                                title: event.title,
                                description: event.description,
                                isCompleted: event.isCompleted
                            )
                        }
                    }
                }
            }
        }

        private var vocabularyGrowthSection: some View {
            let growthData = analyticsService.getVocabularyGrowthData(for: selectedTimeRange)

            return CustomSectionView(
                header: LocalizationKeys.Analytics.vocabularyGrowth.localized,
                backgroundStyle: .standard
            ) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizationKeys.Analytics.totalVocabulary.localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("\(growthData.totalCards)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorManager.tintColor)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(selectedTimeRange.growthPeriodLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("+\(growthData.weeklyGrowth)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }

                    // Growth chart
                    VocabularyGrowthChart(data: growthData.growthData, tintColor: colorManager.tintColor)
                }
            }
        }

        private var learningMilestonesSection: some View {
            let milestones = analyticsService.getLearningMilestones()

            return CustomSectionView(
                header: LocalizationKeys.Analytics.learningMilestones.localized,
                backgroundStyle: .standard
            ) {
                FormWithDivider {
                    ForEach(milestones, id: \.id) { milestone in
                        MilestoneRow(
                            title: milestone.title,
                            isCompleted: milestone.isCompleted,
                            date: milestone.date
                        )
                    }
                }
            }
        }
    }

    struct TimelineEvent: View {
        let date: String
        let title: String
        let description: String
        let isCompleted: Bool

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                VStack {
                    Circle()
                        .fill(isCompleted ? .green : .gray)
                        .frame(width: 12, height: 12)

                    if isCompleted {
                        Rectangle()
                            .fill(.green)
                            .frame(width: 2)
                            .frame(maxHeight: .infinity)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
    }

    struct MilestoneRow: View {
        let title: String
        let isCompleted: Bool
        let date: String

        var body: some View {
            HStack {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? .green : .gray)
                    .font(.subheadline)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
