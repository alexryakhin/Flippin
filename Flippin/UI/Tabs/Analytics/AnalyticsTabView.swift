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
                title: "Analytics",
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
        }

        // MARK: - UI Components

        @ViewBuilder
        private var quickOverviewSection: some View {
            if cardsProvider.cards.isEmpty {
                CustomSectionView(header: "Today", headerFontStyle: .large) {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.largeTitle)
                            Text("No Analytics Data")
                        }
                    } description: {
                        Text("Start studying to see your learning progress!")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                AnalyticsDashboard.ContentView()
            }
        }

        private var premiumFeaturesSection: some View {
            CustomSectionView(header: "Unlock Advanced Analytics", headerFontStyle: .large) {
                VStack(alignment: .leading, spacing: 12) {
                    PremiumFeatureRow(
                        title: "Detailed Progress Reports",
                        description: "Track your learning patterns and improvement over time",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .blue
                    )

                    PremiumFeatureRow(
                        title: "Performance Insights",
                        description: "Get personalized recommendations to improve your study habits",
                        icon: "brain.head.profile",
                        color: .purple
                    )

                    PremiumFeatureRow(
                        title: "Study Time Analytics",
                        description: "Analyze your study sessions and optimize your learning",
                        icon: "clock.arrow.circlepath",
                        color: .green
                    )
                }
                .padding(.horizontal, 16)

                Button {
                    premiumFeature = .advancedAnalytics
                } label: {
                    Text("Upgrade to Premium")
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
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        Button("View All") {
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
                            Text("No Recent Activity")
                        }
                    } description: {
                        Text("Your study sessions will appear here")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundColor(colorManager.foregroundColor)
                } else {
                    VStack(spacing: 12) {
                        ActivityPreviewRow(
                            title: "Last Study Session",
                            value: "2 hours ago",
                            icon: "book.fill",
                            color: .blue
                        )

                        ActivityPreviewRow(
                            title: "Cards Studied Today",
                            value: "12 cards",
                            icon: "rectangle.stack.fill",
                            color: .green
                        )

                        ActivityPreviewRow(
                            title: "Study Streak",
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
