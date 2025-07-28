//
//  DetailedAnalyticsOverview.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

extension DetailedAnalytics {

    struct OverviewTab: View {

        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary cards
                    summaryCardsSection

                    // Study patterns
                    studyPatternsSection

                    // Language progress
                    languageProgressSection

                    // Achievement badges
                    achievementBadgesSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
        }

        private var summaryCardsSection: some View {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                DetailedStatCard(
                    title: "Total Study Time",
                    value: analyticsService.totalStudyTime.formattedAnalyticsTime,
                    subtitle: "Lifetime",
                    icon: "clock.fill",
                    color: .blue
                )

                DetailedStatCard(
                    title: "Cards Mastered",
                    value: "\(analyticsService.totalCardsMastered)",
                    subtitle: "90%+ accuracy", // This is a static subtitle, not a calculated value
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                DetailedStatCard(
                    title: "Study Streak",
                    value: "\(analyticsService.studyStreak)",
                    subtitle: "consecutive days",
                    icon: "flame.fill",
                    color: .orange
                )

                DetailedStatCard(
                    title: "Average Session",
                    value: (analyticsService.dailyStats?.averageSessionTime ?? 0).formattedStudyTime,
                    subtitle: "per session",
                    icon: "timer",
                    color: .purple
                )
            }
        }

        private var studyPatternsSection: some View {
            CustomSectionView(
                header: "Study Patterns",
                backgroundStyle: .standard
            ) {
                FormWithDivider {
                    PatternRow(
                        title: "Most Active Time",
                        value: "Evening (6-9 PM)",
                        icon: "moon.fill",
                        color: .indigo
                    )
                    PatternRow(
                        title: "Preferred Session Length",
                        value: "15-20 minutes",
                        icon: "timer",
                        color: .blue
                    )
                    PatternRow(
                        title: "Study Frequency",
                        value: "Daily",
                        icon: "calendar",
                        color: .green
                    )
                }
            }
        }

        private var languageProgressSection: some View {
            CustomSectionView(
                header: "Language Progress",
                backgroundStyle: .standard
            ) {
                VStack(alignment: .leading, spacing: 12) {

                    // Language pair progress
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("English → Spanish")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ProgressView(value: 0.75)
                                .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                        }

                        Spacer()

                        Text(75.asPercentage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorManager.tintColor)
                    }

                    // Vocabulary growth chart placeholder
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 120)
                        .overlay(
                            VStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Vocabulary Growth")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            }
        }

        private var achievementBadgesSection: some View {
            CustomSectionView(header: "Achievements", backgroundStyle: .standard) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                    spacing: 8
                ) {
                    AchievementBadge(
                        title: "First Steps",
                        icon: "1.circle.fill",
                        isUnlocked: true,
                        color: .green
                    )

                    AchievementBadge(
                        title: "Week Warrior",
                        icon: "7.circle.fill",
                        isUnlocked: analyticsService.studyStreak >= 7,
                        color: .blue
                    )

                    AchievementBadge(
                        title: "Master Learner",
                        icon: "brain",
                        isUnlocked: analyticsService.totalCardsMastered >= 50,
                        color: .orange
                    )

                    AchievementBadge(
                        title: "Dedicated",
                        icon: "30.circle.fill",
                        isUnlocked: analyticsService.studyStreak >= 30,
                        color: .purple
                    )

                    AchievementBadge(
                        title: "Vocabulary Master",
                        icon: "character.magnify",
                        isUnlocked: analyticsService.totalCardsMastered >= 100,
                        color: .red
                    )

                    AchievementBadge(
                        title: "Time Master",
                        icon: "clock.fill",
                        isUnlocked: analyticsService.totalStudyTime >= 3600 * 10, // 10 hours
                        color: .indigo
                    )
                }
            }
        }

        // MARK: - Helper Methods

        // Removed formatStudyTime - now using TimeInterval extension
    }

    struct DetailedStatCard: View {
        let title: String
        let value: String
        let subtitle: String
        let icon: String
        let color: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)

                    Spacer()
                }

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .clippedWithBackground()
        }
    }

    struct PatternRow: View {
        let title: String
        let value: String
        let icon: String
        let color: Color

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }

    struct AchievementBadge: View {
        let title: String
        let icon: String
        let isUnlocked: Bool
        let color: Color

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : .gray)

                Text(title)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clippedWithPaddingAndBackground(
                isUnlocked ? color.opacity(0.1) : Color.gray.opacity(0.1),
                cornerRadius: 8
            )
        }
    }
}
