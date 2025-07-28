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
                        value: analyticsService.getOverallAccuracy().asPercentage,
                        icon: "target",
                        color: .green
                    )
                }
            }
        }

        // MARK: - Study Time Chart Section

        private var studyTimeChartSection: some View {
            CustomSectionView(header: "Study Time") {
                StudyTimeChart(
                    data: analyticsService.getStudyData(for: selectedTimeRange),
                    timeRange: selectedTimeRange,
                    tintColor: colorManager.tintColor
                )
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
        
        private var strideBy: Calendar.Component {
            switch selectedTimeRange {
            case .week:
                return .day
            case .month:
                return .weekOfYear
            case .year:
                return .month
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

// MARK: - Study Time Chart

struct StudyTimeChart: View {
    let data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)]
    let timeRange: AnalyticsDashboard.TimeRange
    let tintColor: Color
    
    var body: some View {
        if data.isEmpty {
            // Empty state
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.title2)
                    .foregroundColor(.secondary)
                Text("No study data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 200)
        } else {
            Chart(data, id: \.date) { dataPoint in
                BarMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Study Time", dataPoint.studyTime / 60) // Convert to minutes
                )
                .foregroundStyle(tintColor.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: strideBy)) { value in
                    AxisValueLabel(format: axisLabelFormat)
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
        }
    }
    
    private var strideBy: Calendar.Component {
        switch timeRange {
        case .week:
            return .day
        case .month:
            return .weekOfYear
        case .year:
            return .month
        }
    }
    
    private var axisLabelFormat: Date.FormatStyle {
        switch timeRange {
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.month().day()
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
}

// MARK: - Preview Data

extension StudyTimeChart {
    static func generatePreviewData(for timeRange: AnalyticsDashboard.TimeRange) -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        let numberOfDays: Int
        switch timeRange {
        case .week:
            numberOfDays = 7
        case .month:
            numberOfDays = 30
        case .year:
            numberOfDays = 365
        }
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            
            // Generate realistic study data
            let hasStudied = Bool.random()
            let studyTime: TimeInterval = hasStudied ? Double.random(in: 300...3600) : 0 // 5-60 minutes
            let cardsStudied = hasStudied ? Int.random(in: 5...25) : 0
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed() // Sort by date ascending
    }
    
    static func generateEmptyData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        return []
    }
    
    static func generateConsistentData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let studyTime: TimeInterval = 1800 // 30 minutes daily
            let cardsStudied = 15
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed()
    }
    
    static func generateVariableData() -> [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        var data: [(date: Date, studyTime: TimeInterval, cardsStudied: Int)] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let studyTime: TimeInterval = Double.random(in: 600...3600) // 10-60 minutes
            let cardsStudied = Int.random(in: 8...30)
            
            data.append((date: date, studyTime: studyTime, cardsStudied: cardsStudied))
        }
        
        return data.reversed()
    }
}

#Preview("Study Time Chart - Week View") {
    VStack(spacing: 20) {
        StudyTimeChart(
            data: StudyTimeChart.generatePreviewData(for: .week),
            timeRange: .week,
            tintColor: .blue
        )
        .padding(16)
        
        StudyTimeChart(
            data: StudyTimeChart.generateConsistentData(),
            timeRange: .week,
            tintColor: .green
        )
        .padding(16)

        StudyTimeChart(
            data: StudyTimeChart.generateVariableData(),
            timeRange: .week,
            tintColor: .purple
        )
        .padding(16)
    }
}

#Preview("Study Time Chart - Empty State") {
    StudyTimeChart(
        data: StudyTimeChart.generateEmptyData(),
        timeRange: .week,
        tintColor: .blue
    )
    .padding(16)
}

#Preview("Study Time Chart - Month View") {
    StudyTimeChart(
        data: StudyTimeChart.generatePreviewData(for: .month),
        timeRange: .month,
        tintColor: .orange
    )
    .padding(16)
}

#Preview("Study Time Chart - Year View") {
    StudyTimeChart(
        data: StudyTimeChart.generatePreviewData(for: .year),
        timeRange: .year,
        tintColor: .red
    )
    .padding(16)
}

#Preview {
    AnalyticsDashboard.ContentView()
}
