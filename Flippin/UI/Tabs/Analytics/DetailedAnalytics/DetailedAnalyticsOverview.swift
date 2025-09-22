//
//  DetailedAnalyticsOverview.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

extension DetailedAnalytics {

    struct OverviewTab: View {
        let selectedTimeRange: DetailedAnalytics.TimeRange
        
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
                .if(isPad) { view in
                    view.frame(maxWidth: 500, alignment: .center)
                        .frame(maxWidth: .infinity)
                }
            }
            .groupedBackground()
        }

        private var summaryCardsSection: some View {
            let timeRangeStats = analyticsService.getTimeRangeStudyStats(for: selectedTimeRange)
            
            return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                DetailedStatCard(
                    title: Loc.DetailedAnalytics.practiceTimeTitle,
                    value: timeRangeStats.totalStudyTime.formattedAnalyticsTime,
                    subtitle: selectedTimeRange.name,
                    icon: "clock.fill",
                    color: .blue
                )

                DetailedStatCard(
                    title: Loc.DetailedAnalytics.cardsMasteredTitle,
                    value: "\(analyticsService.totalCardsMastered)",
                    subtitle: "90%+ accuracy", // This is a static subtitle, not a calculated value
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                DetailedStatCard(
                    title: Loc.DetailedAnalytics.studyStreakTitle,
                    value: "\(analyticsService.studyStreak)",
                    subtitle: Loc.DetailedAnalytics.consecutiveDays,
                    icon: "flame.fill",
                    color: .orange
                )

                DetailedStatCard(
                    title: Loc.DetailedAnalytics.averageSessionTitle,
                    value: timeRangeStats.averageSessionTime.formattedStudyTime,
                    subtitle: Loc.DetailedAnalytics.perSession,
                    icon: "timer",
                    color: .purple
                )
            }
        }

        private var studyPatternsSection: some View {
            let patterns = analyticsService.getStudyPatterns()
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.studyPatterns,
                backgroundStyle: .standard
            ) {
                FormWithDivider {
                    PatternRow(
                        title: Loc.DetailedAnalytics.mostActiveTime,
                        value: patterns.mostActiveTime,
                        icon: "moon.fill",
                        color: .blue
                    )

                    PatternRow(
                        title: Loc.DetailedAnalytics.preferredSessionLength,
                        value: patterns.preferredSessionLength,
                        icon: "timer",
                        color: .green
                    )

                    PatternRow(
                        title: Loc.DetailedAnalytics.studyFrequency,
                        value: patterns.studyFrequency,
                        icon: "calendar",
                        color: .orange
                    )
                }
            }
        }

        private var languageProgressSection: some View {
            let languageProgress = analyticsService.getLanguageProgress()
            
            // Calculate mastered cards for current language pair
            let currentLanguageCards = LanguageManager.shared.filterCards(CardsProvider.shared.cards)
            
            let currentLanguageMastered = currentLanguageCards.filter { card in
                guard let performance = analyticsService.getCardPerformance(for: card.id) else { return false }
                return performance.isMastered
            }.count
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.languageProgress,
                backgroundStyle: .standard
            ) {
                VStack(alignment: .leading, spacing: 12) {

                    // Language pair progress
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(languageProgress.languagePair)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            ProgressView(value: languageProgress.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                        }

                        Spacer()

                        Text(languageProgress.progress.asPercentage)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(colorManager.tintColor)
                    }

                    // Vocabulary count
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Loc.DetailedAnalytics.collectionSize)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(Loc.Plurals.cardsCount(languageProgress.vocabularyCount))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(colorManager.tintColor)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(Loc.Analytics.mastered)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(Loc.Plurals.cardsCount(currentLanguageMastered))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }

        private var achievementBadgesSection: some View {
            CustomSectionView(header: Loc.DetailedAnalytics.achievements, backgroundStyle: .standard) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                    AchievementBadge(
                        title: Loc.DetailedAnalytics.firstSteps,
                        icon: "star",
                        isUnlocked: analyticsService.totalStudyTime > 0,
                        color: .green
                    )

                    AchievementBadge(
                        title: Loc.DetailedAnalytics.weekWarrior,
                        icon: "7.circle.fill",
                        isUnlocked: analyticsService.studyStreak >= 7,
                        color: .blue
                    )

                    AchievementBadge(
                        title: Loc.DetailedAnalytics.masterLearner,
                        icon: "brain",
                        isUnlocked: analyticsService.totalCardsMastered >= 50,
                        color: .orange
                    )

                    AchievementBadge(
                        title: Loc.DetailedAnalytics.dedicated,
                        icon: "30.circle.fill",
                        isUnlocked: analyticsService.studyStreak >= 30,
                        color: .purple
                    )

                    AchievementBadge(
                        title: Loc.DetailedAnalytics.vocabularyMaster,
                        icon: "character.magnify",
                        isUnlocked: analyticsService.totalCardsMastered >= 100,
                        color: .red
                    )

                    AchievementBadge(
                        title: Loc.DetailedAnalytics.timeMaster,
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
                in: .rect(cornerRadius: 8)
            )
        }
    }
}
