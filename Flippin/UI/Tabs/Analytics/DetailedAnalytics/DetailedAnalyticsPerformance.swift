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
            CustomSectionView(
                header: "Accuracy Trends",
                backgroundStyle: .standard
            ) {
                Chart(0..<7, id: \.self) { day in
                    LineMark(
                        x: .value("Day", day),
                        y: .value("Accuracy", 70 + Double(day) * 3 + Double.random(in: -5...5))
                    )
                    .foregroundStyle(colorManager.tintColor.gradient)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartYScale(domain: 60...100)
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let accuracy = value.as(Double.self) {
                                Text(Int(accuracy).asPercentage)
                            }
                        }
                    }
                }
            }
        }

        private var sessionPerformanceSection: some View {
            CustomSectionView(
                header: "Session Performance",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    PerformanceMetricRow(
                        title: "Average Session Duration",
                        value: "18 minutes",
                        trend: "+2 min",
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: "Cards per Session",
                        value: "12 cards",
                        trend: "+1 card",
                        isPositive: true
                    )

                    PerformanceMetricRow(
                        title: "Session Frequency",
                        value: "2.3 sessions/day",
                        trend: "-0.2",
                        isPositive: false
                    )
                }
            }
        }

        private var cardDifficultySection: some View {
            CustomSectionView(
                header: "Card Difficulty Analysis",
                backgroundStyle: .standard
            ) {
                VStack(spacing: 12) {
                    DifficultyRow(
                        level: "Easy",
                        count: 45,
                        percentage: 60,
                        color: .green
                    )

                    DifficultyRow(
                        level: "Medium",
                        count: 25,
                        percentage: 33,
                        color: .orange
                    )

                    DifficultyRow(
                        level: "Hard",
                        count: 5,
                        percentage: 7,
                        color: .red
                    )
                }
            }
        }

        private var learningSpeedSection: some View {
            CustomSectionView(
                header: "Learning Speed",
                backgroundStyle: .standard
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cards per Hour")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("24")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(colorManager.tintColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("vs. Average")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("+8")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
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
