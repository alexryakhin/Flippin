import SwiftUI
import Charts

enum AnalyticsDashboard {

    enum TimeRange: String, CaseIterable {
        case week
        case month
        case year
        case all

        var name: String {
            switch self {
            case .week: Loc.Analytics.week
            case .month: Loc.Analytics.month
            case .year: Loc.Analytics.year
            case .all: Loc.Analytics.allTime
            }
        }

        var growthPeriodLabel: String {
            switch self {
            case .week: Loc.DetailedAnalytics.thisWeek
            case .month: Loc.DetailedAnalytics.thisMonth
            case .year: Loc.DetailedAnalytics.thisYear
            case .all: Loc.Analytics.allTime
            }
        }

        static let chartCases: [TimeRange] = [.week, .month, .year]
    }

    struct ContentView: View {
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared

        @State private var selectedTimeRange: TimeRange = .week

        var body: some View {
            VStack(spacing: 16) {
                // Header with streak
                streakSection

                // Overview cards
                overviewSection

                // Study time chart
                studyTimeChartSection

                // Mastery progress
                masteryProgressSection
            }
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
        }

        // MARK: - Streak Section

        private var streakSection: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Loc.Analytics.studyStreak)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(TimeInterval.formatDayCount(analyticsService.studyStreak))
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
        }

        // MARK: - Overview Section

        private var overviewSection: some View {
            CustomSectionView(header: Loc.Analytics.overview, headerFontStyle: .large) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    StatCard(
                        title: Loc.Analytics.totalStudyTime,
                        value: analyticsService.getTotalStudyTimeIncludingCardFlipping().formattedStudyTime,
                        icon: "clock.fill",
                        color: .blue
                    )

                    StatCard(
                        title: Loc.Analytics.cardsStudied,
                        value: "\(analyticsService.dailyStats?.cardsStudied ?? 0)",
                        icon: "rectangle.stack.fill",
                        color: .purple
                    )

                    StatCard(
                        title: Loc.Analytics.sessions,
                        value: "\(analyticsService.dailyStats?.sessionsCompleted ?? 0)",
                        icon: "play.circle.fill",
                        color: .orange
                    )

                    StatCard(
                        title: Loc.Analytics.accuracy,
                        value: analyticsService.getOverallAccuracy().asPercentage,
                        icon: "target",
                        color: .green
                    )
                }
            }
        }

        // MARK: - Study Time Chart Section

        @ViewBuilder
        private var studyTimeChartSection: some View {
            if purchaseService.hasPremiumAccess {
                CustomSectionView(header: Loc.Analytics.studyTime) {
                    StudyTimeChart(
                        data: analyticsService.getStudyData(for: selectedTimeRange),
                        timeRange: selectedTimeRange,
                        tintColor: colorManager.tintColor
                    )
                } trailingContent: {
                    HeaderButtonMenu(selectedTimeRange.name) {
                        Picker(Loc.Analytics.timeRange, selection: $selectedTimeRange) {
                            ForEach(TimeRange.chartCases, id: \.self) { range in
                                Text(range.name).tag(range)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
        }

        // MARK: - Mastery Progress Section

        @ViewBuilder
        private var masteryProgressSection: some View {
            if purchaseService.hasPremiumAccess {
                let masteryStats = analyticsService.getMasteryStats()

                CustomSectionView(header: Loc.Analytics.masteryProgress) {
                    FormWithDivider {
                        MasteryProgressRow(
                            title: Loc.Analytics.mastered,
                            count: masteryStats.mastered,
                            total: masteryStats.total,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )

                        MasteryProgressRow(
                            title: Loc.Analytics.learning,
                            count: masteryStats.learning,
                            total: masteryStats.total,
                            color: .orange,
                            icon: "book.fill"
                        )

                        MasteryProgressRow(
                            title: Loc.Analytics.needsReview,
                            count: masteryStats.needsReview,
                            total: masteryStats.total,
                            color: .red,
                            icon: "exclamationmark.circle.fill"
                        )
                    }
                }
            }
        }

        // MARK: - Helper Methods
        
        private var strideBy: Calendar.Component {
            switch selectedTimeRange {
            case .week:
                return .day
            case .month:
                return .weekOfYear
            case .year:
                return .month
            case .all:
                return .year
            }
        }
        
        private var axisLabelFormat: Date.FormatStyle {
            switch selectedTimeRange {
            case .week:
                return .dateTime.weekday(.abbreviated)
            case .month:
                return .dateTime.month().day()
            case .year:
                return .dateTime.month(.abbreviated)
            case .all:
                return .dateTime.year()
            }
        }
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
