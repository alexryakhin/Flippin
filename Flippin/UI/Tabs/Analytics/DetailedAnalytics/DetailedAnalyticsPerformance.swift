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
            }
            .background(Color(.systemGroupedBackground))
        }

        private var accuracyTrendsSection: some View {
            let accuracyData = analyticsService.getAccuracyTrends(for: selectedTimeRange)
            
            return CustomSectionView(
                header: "Accuracy Trends",
                backgroundStyle: .standard
            ) {
                AccuracyTrendsChart(data: accuracyData, tintColor: colorManager.tintColor)
            }
        }

        private var sessionPerformanceSection: some View {
            let sessionStats = analyticsService.getSessionPerformance(for: selectedTimeRange)
            
            return CustomSectionView(
                header: "Session Performance",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    PerformanceMetricRow(
                        title: "Average Session Duration",
                        value: sessionStats.averageDuration.formattedStudyTime,
                        trend: "Based on \(selectedTimeRange.rawValue.lowercased()) data",
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: "Cards per Session",
                        value: String(format: "%.1f cards", sessionStats.cardsPerSession),
                        trend: "Average",
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: "Session Frequency",
                        value: String(format: "%.1f sessions/day", sessionStats.sessionFrequency),
                        trend: "Based on \(selectedTimeRange.rawValue.lowercased()) data",
                        isPositive: sessionStats.sessionFrequency > 0
                    )
                }
            }
        }

        private var cardDifficultySection: some View {
            let difficultyDistribution = analyticsService.getCardDifficultyDistribution()
            
            return CustomSectionView(
                header: "Card Difficulty Analysis",
                backgroundStyle: .standard
            ) {
                if difficultyDistribution.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No difficulty data available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                } else {
                    VStack(spacing: 12) {
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
                header: "Learning Speed",
                backgroundStyle: .standard
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cards per Hour")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.1f", learningSpeed.cardsPerHour))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorManager.tintColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("vs. Average")
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

                Text("\(count) cards")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(percentage.asPercentage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
} 
