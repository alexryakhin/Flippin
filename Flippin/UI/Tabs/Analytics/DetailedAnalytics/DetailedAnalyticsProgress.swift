//
//  DetailedAnalyticsProgress.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

extension DetailedAnalytics {

    struct ProgressTab: View {

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
            CustomSectionView(
                header: "Mastery Timeline",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 16) {
                    TimelineEvent(
                        date: "Today",
                        title: "Reached 75 cards mastered",
                        description: "Great progress! You're on track for your weekly goal.",
                        isCompleted: true
                    )

                    TimelineEvent(
                        date: "Yesterday",
                        title: "Completed 3 study sessions",
                        description: "Consistent daily practice is key to success.",
                        isCompleted: true
                    )

                    TimelineEvent(
                        date: "3 days ago",
                        title: "Started new vocabulary set",
                        description: "Added 15 new travel phrases to your collection.",
                        isCompleted: true
                    )
                }
            }
        }

        private var vocabularyGrowthSection: some View {
            CustomSectionView(
                header: "Vocabulary Growth",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Vocabulary")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("\(analyticsService.totalCardsMastered + 25)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorManager.tintColor)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("This Week")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("+12")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }

                    // Growth chart placeholder
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 100)
                        .overlay(
                            Text("Vocabulary growth chart")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        )
                }
            }
        }

        private var learningMilestonesSection: some View {
            CustomSectionView(
                header: "Learning Milestones",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    MilestoneRow(
                        title: "First 10 cards mastered",
                        isCompleted: true,
                        date: "2 weeks ago"
                    )

                    MilestoneRow(
                        title: "7-day study streak",
                        isCompleted: analyticsService.studyStreak >= 7,
                        date: analyticsService.studyStreak >= 7 ? "1 week ago" : "In progress"
                    )

                    MilestoneRow(
                        title: "50 cards mastered",
                        isCompleted: analyticsService.totalCardsMastered >= 50,
                        date: analyticsService.totalCardsMastered >= 50 ? "3 days ago" : "In progress"
                    )

                    MilestoneRow(
                        title: "30-day study streak",
                        isCompleted: analyticsService.studyStreak >= 30,
                        date: analyticsService.studyStreak >= 30 ? "Today" : "In progress"
                    )
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
                    .foregroundColor(isCompleted ? .green : .gray)
                    .font(.subheadline)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 