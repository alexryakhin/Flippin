import SwiftUI

/**
 Analytics Tab View - Learning progress and analytics interface.
 Provides comprehensive analytics dashboard and detailed insights.
 */

enum AnalyticsTab {

    struct ContentView: View {
        // MARK: - State Objects

        @StateObject private var cardsProvider = CardsProvider.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared

        // MARK: - State Variables

        @State private var premiumFeature: PremiumFeature?

        // MARK: - Body

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick overview
                    quickOverviewSection

                    // Premium features promotion
                    if !purchaseService.hasPremiumAccess {
                        premiumFeaturesSection
                    }
                }
                .padding(16)
                .if(isPad) { view in
                    view.frame(maxWidth: 500, alignment: .center)
                }
            }
            .navigation(
                title: Loc.Analytics.analytics,
                mode: .large,
                trailingContent: {
                    if purchaseService.hasPremiumAccess {
                        HeaderButton(
                            icon: "chart.line.uptrend.xyaxis",
                            size: .large,
                            style: .borderedProminent
                        ) {
                            NavigationManager.shared.navigate(to: .detailedAnalytics)
                        }
                    }
                }
            )
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .premiumAlert(feature: $premiumFeature)
            .onAppear {
                AnalyticsService.trackEvent(.analyticsViewed)
            }
        }

        // MARK: - UI Components

        @ViewBuilder
        private var quickOverviewSection: some View {
            if cardsProvider.cards.isEmpty {
                CustomSectionView(header: Loc.Analytics.today, headerFontStyle: .large) {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.largeTitle)
                            Text(Loc.Analytics.noAnalyticsData)
                        }
                    } description: {
                        Text(Loc.Analytics.startStudyingToSeeProgress)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                AnalyticsDashboard.ContentView()
            }
        }

        private var premiumFeaturesSection: some View {
            CustomSectionView(header: Loc.Analytics.unlockAdvancedAnalytics, headerFontStyle: .large) {
                VStack(alignment: .leading, spacing: 12) {
                    PremiumFeatureRow(
                        title: Loc.Analytics.detailedProgressReports,
                        description: Loc.Analytics.detailedProgressReportsDescription,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )

                    PremiumFeatureRow(
                        title: Loc.Analytics.performanceInsights,
                        description: Loc.Analytics.performanceInsightsDescription,
                        icon: "brain.head.profile",
                        color: .purple
                    )

                    PremiumFeatureRow(
                        title: Loc.Analytics.studyTimeAnalytics,
                        description: Loc.Analytics.studyTimeAnalyticsDescription,
                        icon: "clock.arrow.circlepath",
                        color: .green
                    )
                }
                .padding(.horizontal, 16)

                ActionButton(
                    Loc.Analytics.upgradeToPremium,
                    systemImage: "crown.fill",
                    style: .borderedProminent
                ) {
                    premiumFeature = .advancedAnalytics
                }
            }
        }

        private var recentActivityPreviewSection: some View {
            VStack(spacing: 16) {
                HStack {
                    Text(Loc.Analytics.recentActivity)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        Button(Loc.Analytics.viewAll) {
                            NavigationManager.shared.navigate(to: .detailedAnalytics)
                        }
                        .font(.subheadline)
                        .foregroundColor(colorManager.tintColor)
                    }
                }

                if cardsProvider.cards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.largeTitle)
                            Text(Loc.Analytics.noRecentActivity)
                        }
                    } description: {
                        Text(Loc.Analytics.studySessionsWillAppearHere)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundColor(colorManager.foregroundColor)
                } else {
                    VStack(spacing: 12) {
                        ActivityPreviewRow(
                            title: Loc.Analytics.lastStudySession,
                            value: "2 hours ago",
                            icon: "book.fill",
                            color: .blue
                        )

                        ActivityPreviewRow(
                            title: Loc.Analytics.cardsStudiedToday,
                            value: "15 cards",
                            icon: "rectangle.stack.fill",
                            color: .purple
                        )

                        ActivityPreviewRow(
                            title: Loc.Analytics.studyStreak,
                            value: "5 days",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                }
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }
    }

    // MARK: - Supporting Views

    struct PremiumFeatureRow: View {
        let title: String
        let description: String
        let icon: String
        let color: Color

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    struct ActivityPreviewRow: View {
        let title: String
        let value: String
        let icon: String
        let color: Color

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Text(title)
                    .font(.subheadline)

                Spacer()

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 4)
        }
    }
}


#Preview {
    AnalyticsTab.ContentView()
}
