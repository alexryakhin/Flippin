import SwiftUI
import Charts

enum DetailedAnalytics {

    typealias TimeRange = AnalyticsDashboard.TimeRange

    enum Tab: Int, CaseIterable {
        case overview
        case performance
        case progress
        case insights

        var title: String {
            switch self {
            case .overview:
                return "Overview"
            case .performance:
                return "Performance"
            case .progress:
                return "Progress"
            case .insights:
                return "Insights"
            }
        }
    }

    struct ContentView: View {

        @Environment(\.dismiss) var dismiss
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        @State private var selectedTab = Tab.overview
        @State private var selectedTimeRange: TimeRange = .month

        var body: some View {
            VStack(spacing: 0) {
                switch selectedTab {
                    case .overview: OverviewTab(selectedTimeRange: selectedTimeRange)
                    case .performance: PerformanceTab(selectedTimeRange: selectedTimeRange)
                    case .progress: ProgressTab(selectedTimeRange: selectedTimeRange)
                    case .insights: InsightsTab(selectedTimeRange: selectedTimeRange)
                }
            }
            .navigation(
                title: "Detailed Analytics",
                mode: .inline,
                clipMode: .rectangle,
                trailingContent: {
                    HStack {
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.secondary)
                        .clipShape(Capsule())
                    }
                },
                bottomContent: {
                    Picker("Analytics Tab", selection: $selectedTab) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Text(tab.title)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            )
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
        }

        // MARK: - Overview Tab

        // MARK: - Performance Tab

        // MARK: - Progress Tab

        // MARK: - Insights Tab
    }

    // MARK: - Supporting Views
}

#Preview {
    DetailedAnalytics.ContentView()
}
