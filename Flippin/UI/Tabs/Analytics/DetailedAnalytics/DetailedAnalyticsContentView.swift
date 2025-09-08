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
                return Loc.Analytics.overview
            case .performance:
                return Loc.Analytics.performance
            case .progress:
                return Loc.Analytics.progress
            case .insights:
                return Loc.Analytics.insights
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
                case .overview:
                    OverviewTab(selectedTimeRange: selectedTimeRange)
                case .performance:
                    PerformanceTab(selectedTimeRange: selectedTimeRange)
                case .progress:
                    ProgressTab(selectedTimeRange: selectedTimeRange)
                case .insights:
                    InsightsTab(
                        selectedTimeRange: selectedTimeRange,
                        onDismiss: { dismiss() }
                    )
                }
            }
            .navigation(
                title: Loc.Analytics.detailedAnalytics,
                mode: .inline(withBackButton: true),
                trailingContent: {
                    HeaderButtonMenu(selectedTimeRange.name) {
                        Picker(Loc.Analytics.timeRange, selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.name).tag(range)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                },
                bottomContent: {
                    Picker(Loc.DetailedAnalytics.analyticsTab, selection: $selectedTab) {
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
