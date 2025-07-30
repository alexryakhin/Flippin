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

        @State private var showDetailedAnalytics = false
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
            }
            .if(isPad) { view in
                view.frame(maxWidth: 500, alignment: .center)
            }
            .navigation(
                title: LocalizationKeys.Analytics.analytics.localized,
                mode: .large,
                trailingContent: {
                    if purchaseService.hasPremiumAccess {
                        Button {
                            showDetailedAnalytics = true
                        } label: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.headline)
                                .foregroundStyle(colorManager.borderedProminentForegroundColor)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                    }
                }
            )
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .sheet(isPresented: $showDetailedAnalytics) {
                DetailedAnalytics.ContentView()
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
                CustomSectionView(header: LocalizationKeys.Analytics.today.localized, headerFontStyle: .large) {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.largeTitle)
                            Text(LocalizationKeys.Analytics.noAnalyticsData.localized)
                        }
                    } description: {
                        Text(LocalizationKeys.Analytics.startStudyingToSeeProgress.localized)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                AnalyticsDashboard.ContentView()
            }
        }

        private var premiumFeaturesSection: some View {
            CustomSectionView(header: LocalizationKeys.Analytics.unlockAdvancedAnalytics.localized, headerFontStyle: .large) {
                VStack(alignment: .leading, spacing: 12) {
                    PremiumFeatureRow(
                        title: LocalizationKeys.Analytics.detailedProgressReports.localized,
                        description: LocalizationKeys.Analytics.detailedProgressReportsDescription.localized,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )

                    PremiumFeatureRow(
                        title: LocalizationKeys.Analytics.performanceInsights.localized,
                        description: LocalizationKeys.Analytics.performanceInsightsDescription.localized,
                        icon: "brain.head.profile",
                        color: .purple
                    )

                    PremiumFeatureRow(
                        title: LocalizationKeys.Analytics.studyTimeAnalytics.localized,
                        description: LocalizationKeys.Analytics.studyTimeAnalyticsDescription.localized,
                        icon: "clock.arrow.circlepath",
                        color: .green
                    )
                }
                .padding(.horizontal, 16)

                Button {
                    premiumFeature = .advancedAnalytics
                } label: {
                    Text(LocalizationKeys.Analytics.upgradeToPremium.localized)
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(colorManager.borderedProminentForegroundColor)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
        }

        private var recentActivityPreviewSection: some View {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizationKeys.Analytics.recentActivity.localized)
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        Button(LocalizationKeys.Analytics.viewAll.localized) {
                            showDetailedAnalytics = true
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
                            Text(LocalizationKeys.Analytics.noRecentActivity.localized)
                        }
                    } description: {
                        Text(LocalizationKeys.Analytics.studySessionsWillAppearHere.localized)
                            .foregroundStyle(.secondary)
                    }
                    .foregroundColor(colorManager.foregroundColor)
                } else {
                    VStack(spacing: 12) {
                        ActivityPreviewRow(
                            title: LocalizationKeys.Analytics.lastStudySession.localized,
                            value: "2 hours ago",
                            icon: "book.fill",
                            color: .blue
                        )

                        ActivityPreviewRow(
                            title: LocalizationKeys.Analytics.cardsStudiedToday.localized,
                            value: "15 cards",
                            icon: "rectangle.stack.fill",
                            color: .purple
                        )

                        ActivityPreviewRow(
                            title: LocalizationKeys.Analytics.studyStreak.localized,
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
