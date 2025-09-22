//
//  DetailedAnalyticsPerformance.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI
import Charts

extension DetailedAnalytics {

    struct PerformanceTab: View {

        let selectedTimeRange: TimeRange

        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Accuracy trends
                    accuracyTrendsSection

                    // Session performance
                    sessionPerformanceSection

                    // Card difficulty analysis
                    cardDifficultySection

                    // Learning speed
                    learningSpeedSection
                }
                .padding(16)
                .if(isPad) { view in
                    view.frame(maxWidth: 500, alignment: .center)
                        .frame(maxWidth: .infinity)
                }
            }
            .groupedBackground()
        }

        private var accuracyTrendsSection: some View {
            let accuracyData = analyticsService.getAccuracyTrends(for: selectedTimeRange)
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.accuracyTrends,
                backgroundStyle: .standard
            ) {
                AccuracyTrendsChart(data: accuracyData, tintColor: colorManager.tintColor)
            }
        }

        private var sessionPerformanceSection: some View {
            let sessionStats = analyticsService.getSessionPerformance(for: selectedTimeRange)
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.sessionPerformance,
                backgroundStyle: .standard
            ) {
                FormWithDivider {
                    PerformanceMetricRow(
                        title: Loc.DetailedAnalytics.averageSessionDuration,
                        value: sessionStats.averageDuration.formattedStudyTime,
                        trend: Loc.DetailedAnalytics.basedOnData(selectedTimeRange.name.lowercased()),
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: Loc.DetailedAnalytics.cardsPerSession,
                        value: Loc.Plurals.cardsCount(Int(sessionStats.cardsPerSession)),
                        trend: Loc.DetailedAnalytics.average,
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: Loc.DetailedAnalytics.sessionFrequency,
                        value: Loc.Plurals.sessionsPerDay(Int(sessionStats.sessionFrequency)),
                        trend: Loc.DetailedAnalytics.basedOnData(selectedTimeRange.name.lowercased()),
                        isPositive: sessionStats.sessionFrequency > 0
                    )
                }
            }
        }

        private var cardDifficultySection: some View {
            let difficultyDistribution = analyticsService.getCardDifficultyDistribution()
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.cardDifficultyAnalysis,
                backgroundStyle: .standard
            ) {
                if difficultyDistribution.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text(Loc.DetailedAnalytics.noDifficultyDataAvailable)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    FormWithDivider {
                        ForEach(difficultyDistribution, id: \.level) { difficulty in
                            DifficultyRow(
                                level: difficulty.level,
                                count: difficulty.count,
                                percentage: difficulty.percentage,
                                color: difficulty.color
                            )
                        }
                    }
                }
            }
        }

        private var learningSpeedSection: some View {
            let learningSpeed = analyticsService.getLearningSpeedMetrics()
            
            return CustomSectionView(
                header: Loc.DetailedAnalytics.learningSpeed,
                backgroundStyle: .standard
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Loc.DetailedAnalytics.cardsPerHour)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f", learningSpeed.cardsPerHour))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorManager.tintColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(Loc.DetailedAnalytics.vsAverage)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(String(format: "%+.1f", learningSpeed.vsAverage))
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(learningSpeed.vsAverage >= 0 ? .green : .red)
                    }
                }
            }
        }
    }

    struct PerformanceMetricRow: View {
        let title: String
        let value: String
        let trend: String
        let isPositive: Bool

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                Text(trend)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
    }

    struct DifficultyRow: View {
        let level: String
        let count: Int
        let percentage: Int
        let color: Color

        var body: some View {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text(level)
                    .font(.subheadline)

                Spacer()

                Text(Loc.Plurals.cardsCount(count))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(percentage.asPercentage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
