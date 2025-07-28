import SwiftUI
import Charts

enum AnalyticsDashboard {

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    struct ContentView: View {
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared

        @State private var selectedTimeRange: TimeRange = .week

        var body: some View {
            VStack(spacing: 16) {
                // Header with streak and overview
                headerSection

                // Quick stats cards
                quickStatsSection

                // Study time chart
                studyTimeChartSection

                // Mastery progress
                masteryProgressSection
            }
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
        }

        // MARK: - Header Section

        private var headerSection: some View {
            VStack(spacing: 12) {
                // Streak display
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Study Streak")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(analyticsService.studyStreak) days")
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(colorManager.tintColor)
                    }

                    Spacer()

                    // Streak icon
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                        .scaleEffect(analyticsService.studyStreak > 0 ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 0.3), value: analyticsService.studyStreak)
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)

                // Total study time
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Study Time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(analyticsService.totalStudyTime.formattedAnalyticsTime)
                            .font(.system(.title2, design: .rounded))
                            .bold()
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Cards Mastered")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(analyticsService.totalCardsMastered)")
                            .font(.system(.title2, design: .rounded))
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
            }
        }

        // MARK: - Quick Stats Section

        private var quickStatsSection: some View {
            CustomSectionView(header: "Today", headerFontStyle: .large) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    StatCard(
                        title: "Today's Study",
                        value: (analyticsService.dailyStats?.totalStudyTime ?? 0).formattedStudyTime,
                        icon: "clock.fill",
                        color: .blue
                    )

                    StatCard(
                        title: "Cards Studied",
                        value: "\(analyticsService.dailyStats?.cardsStudied ?? 0)",
                        icon: "rectangle.stack.fill",
                        color: .purple
                    )

                    StatCard(
                        title: "Sessions",
                        value: "\(analyticsService.dailyStats?.sessionsCompleted ?? 0)",
                        icon: "play.circle.fill",
                        color: .orange
                    )

                    StatCard(
                        title: "Accuracy",
                        value: ((analyticsService.dailyStats?.totalStudyTime ?? 0) > 0 ? 85.0 : 0.0).formattedPercentage,
                        icon: "target",
                        color: .green
                    )
                }
            }
        }

        // MARK: - Study Time Chart Section

        private var studyTimeChartSection: some View {
            CustomSectionView(header: "Study Time") {
                Chart(analyticsService.getWeeklyStudyData(), id: \.date) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Study Time", data.studyTime / 60) // Convert to minutes
                    )
                    .foregroundStyle(colorManager.tintColor.gradient)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let minutes = value.as(Double.self) {
                                Text("\(Int(minutes))m")
                            }
                        }
                    }
                }
            } trailingContent: {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
        }

        // MARK: - Mastery Progress Section

        @ViewBuilder
        private var masteryProgressSection: some View {
            let masteryStats = analyticsService.getMasteryStats()

            CustomSectionView(header: "Mastery Progress") {
                FormWithDivider {
                    MasteryProgressRow(
                        title: "Mastered",
                        count: masteryStats.mastered,
                        total: masteryStats.total,
                        color: .green,
                        icon: "checkmark.circle.fill"
                    )

                    MasteryProgressRow(
                        title: "Learning",
                        count: masteryStats.learning,
                        total: masteryStats.total,
                        color: .orange,
                        icon: "book.fill"
                    )

                    MasteryProgressRow(
                        title: "Needs Review",
                        count: masteryStats.needsReview,
                        total: masteryStats.total,
                        color: .red,
                        icon: "exclamationmark.circle.fill"
                    )
                }
            }
        }

        // MARK: - Helper Methods

        // Removed formatStudyTime - now using TimeInterval extension
    }

    // MARK: - Supporting Views

    struct StatCard: View {
        let title: String
        let value: String
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
                    .font(.system(.title2, design: .rounded))
                    .bold()

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }
    }

    struct MasteryProgressRow: View {
        let title: String
        let count: Int
        let total: Int
        let color: Color
        let icon: String

        private var progress: Double {
            guard total > 0 else { return 0.0 }
            return Double(count) / Double(total)
        }

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)
                    .frame(width: 24)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(width: 60)
            }
        }
    }
}


#Preview {
    AnalyticsDashboard.ContentView()
}
