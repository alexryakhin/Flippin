import SwiftUI
import Charts

enum AnalyticsDashboard {
    struct ContentView: View {
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared

        @State private var selectedTimeRange: TimeRange = .week
        @State private var showingDetailedStats = false

        enum TimeRange: String, CaseIterable {
            case week = "Week"
            case month = "Month"
            case year = "Year"
        }

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

                // Recent activity
                recentActivitySection

                // Premium features promotion
                if !purchaseService.hasPremiumAccess {
                    premiumFeaturesSection
                }
            }
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .sheet(isPresented: $showingDetailedStats) {
                DetailedAnalyticsView()
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

                        Text(formatStudyTime(analyticsService.totalStudyTime))
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                StatCard(
                    title: "Today's Study",
                    value: formatStudyTime(analyticsService.dailyStats?.totalStudyTime ?? 0),
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
                    value: "\(Int((analyticsService.dailyStats?.totalStudyTime ?? 0) > 0 ? 85.0 : 0.0))%",
                    icon: "target",
                    color: .green
                )
            }
        }

        // MARK: - Study Time Chart Section

        private var studyTimeChartSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Study Time")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }

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
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        // MARK: - Mastery Progress Section

        private var masteryProgressSection: some View {
            let masteryStats = analyticsService.getMasteryStats()

            return VStack(alignment: .leading, spacing: 16) {
                Text("Mastery Progress")
                    .font(.headline)
                    .fontWeight(.semibold)

                VStack(spacing: 12) {
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
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        // MARK: - Recent Activity Section

        private var recentActivitySection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)

                // Placeholder for recent activity
                VStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(colorManager.tintColor)
                                .frame(width: 8, height: 8)

                            Text("Studied \(5 - index) cards")
                                .font(.subheadline)

                            Spacer()

                            Text("\(2 - index)h ago")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        // MARK: - Premium Features Section

        private var premiumFeaturesSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)

                    Text("Unlock Premium Analytics")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Text("Get detailed insights, advanced charts, and personalized learning recommendations.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button("Upgrade to Premium") {
                    // Handle premium upgrade
                }
                .buttonStyle(.borderedProminent)
                .tint(colorManager.tintColor)
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        // MARK: - Helper Methods

        private func formatStudyTime(_ timeInterval: TimeInterval) -> String {
            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) % 3600 / 60

            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
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
            .padding(16)
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
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.subheadline)

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
