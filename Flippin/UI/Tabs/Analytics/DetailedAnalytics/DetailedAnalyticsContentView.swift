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
                return LocalizationKeys.Analytics.overview.localized
            case .performance:
                return LocalizationKeys.Analytics.performance.localized
            case .progress:
                return LocalizationKeys.Analytics.progress.localized
            case .insights:
                return LocalizationKeys.Analytics.insights.localized
            }
        }
    }

    struct ContentView: View {

        @Environment(\.dismiss) var dismiss
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var colorManager = ColorManager.shared

        @State private var selectedTab = Tab.overview
        @State private var selectedTimeRange: TimeRange = .week

        var body: some View {
            VStack(spacing: 0) {
                switch selectedTab {
                case .overview: OverviewTab(selectedTimeRange: selectedTimeRange)
                case .performance: PerformanceTab(selectedTimeRange: selectedTimeRange)
                case .progress: ProgressTab(selectedTimeRange: selectedTimeRange)
                case .insights: InsightsTab(
                    selectedTimeRange: selectedTimeRange,
                    onDismiss: { dismiss() }
                )
                }
            }
            .navigation(
                title: LocalizationKeys.Analytics.detailedAnalytics.localized,
                mode: .inline,
                trailingContent: {
                    HStack {
                        Picker(LocalizationKeys.Analytics.timeRange.localized, selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.name).tag(range)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                        .foregroundStyle(.secondary)
                        .clipShape(Capsule())
                    }
                },
                bottomContent: {
                    Picker(LocalizationKeys.Analytics.analyticsTab.localized, selection: $selectedTab) {
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
            .onAppear {
                AnalyticsService.trackEvent(.detailedAnalyticsViewed)
            }
        }
    }
}

#Preview {
    DetailedAnalytics.ContentView()
}
