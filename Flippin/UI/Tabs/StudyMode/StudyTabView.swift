import SwiftUI

/**
 Study Mode Tab View - Dedicated study session interface.
 Provides focused study experience with progress tracking.
 */

enum StudyTab {

    struct ContentView: View {
        // MARK: - State Objects

        @StateObject private var cardsProvider = CardsProvider.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var analyticsService = LearningAnalyticsService.shared

        // MARK: - State Variables

        @State private var showStudyMode = false
        @State private var premiumFeature: PremiumFeature?

        // MARK: - Computed Properties

        var cardsNeedingReview: [CardItem] {
            analyticsService.getCardsNeedingReview()
        }

        var masteryStats: (total: Int, mastered: Int, learning: Int, needsReview: Int) {
            analyticsService.getMasteryStats()
        }

        var studyTimeStats: (total: TimeInterval, today: TimeInterval, average: TimeInterval) {
            analyticsService.getStudyTimeStats()
        }

        // MARK: - Body

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick stats
                    quickStatsSection

                    // Study options
                    studyOptionsSection

                    // Recent activity
                    recentActivitySection
                }
                .padding(16)
            }
            .if(isPad) { view in
                view.frame(maxWidth: 500, alignment: .center)
            }
            .navigation(title: "Study")
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .sheet(isPresented: $showStudyMode) {
                StudyModeView()
            }
            .premiumAlert(feature: $premiumFeature)
        }

        // MARK: - UI Components

        private var quickStatsSection: some View {
            CustomSectionView(header: "Quick Stats", headerFontStyle: .large) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                    spacing: 8
                ) {
                    StatCard(
                        title: "Cards to Review",
                        value: "\(cardsNeedingReview.count)",
                        icon: "clock.fill",
                        color: .orange
                    )

                    StatCard(
                        title: "Total Cards",
                        value: "\(cardsProvider.cards.count)",
                        icon: "rectangle.stack.fill",
                        color: .blue
                    )

                    StatCard(
                        title: "Mastered",
                        value: "\(masteryStats.mastered)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    StatCard(
                        title: "Study Time Today",
                        value: formatStudyTime(studyTimeStats.today),
                        icon: "clock",
                        color: .purple
                    )
                }
            }
        }

        private var studyOptionsSection: some View {
            CustomSectionView(header: "Study Options", headerFontStyle: .large) {
                VStack(spacing: 12) {
                    // Start study session
                    studyOptionButton(
                        image: Image(systemName: "play.fill"),
                        text: "Start Study Session",
                        color: .green,
                        isDisabled: cardsProvider.cards.isEmpty,
                        action: { showStudyMode = true }
                    )

                    // Review cards
                    if !cardsNeedingReview.isEmpty {
                        studyOptionButton(
                            image: Image(systemName: "clock.fill"),
                            text: "Review Due Cards (\(cardsNeedingReview.count))",
                            color: .orange,
                            isDisabled: cardsProvider.cards.isEmpty,
                            action: { showStudyMode = true }
                        )
                    }

                    // Practice all cards
                    if !cardsProvider.cards.isEmpty {
                        studyOptionButton(
                            image: Image(.icCardsStack),
                            text: "Practice All Cards",
                            color: .blue,
                            action: { showStudyMode = true }
                        )
                    }
                }
            }
        }

        private func studyOptionButton(
            image: Image,
            text: String,
            color: Color,
            isDisabled: Bool = false,
            action: @escaping () -> Void
        ) -> some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(text)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding(16)
                .background(color.opacity(0.1))
                .foregroundStyle(color)
                .cornerRadius(12)
            }
            .disabled(isDisabled)
        }

        private var recentActivitySection: some View {
            CustomSectionView(header: "Recent Activity", headerFontStyle: .large) {
                if cardsProvider.cards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                            Text("No Study Data")
                        }
                    } description: {
                        Text("Start studying to see your progress!")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundColor(colorManager.foregroundColor)
                } else {
                    VStack(spacing: 12) {
                        ActivityRow(
                            title: "Total Study Time",
                            value: formatStudyTime(studyTimeStats.total),
                            icon: "clock.fill",
                            color: .purple
                        )

                        ActivityRow(
                            title: "Average Session",
                            value: formatStudyTime(studyTimeStats.average),
                            icon: "timer",
                            color: .blue
                        )

                        ActivityRow(
                            title: "Learning Progress",
                            value: "\(masteryStats.learning) cards",
                            icon: "brain.head.profile",
                            color: .orange
                        )
                    }
                }
            }
        }

        // MARK: - Helper Methods

        private func formatStudyTime(_ timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60

            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            } else {
                return "\(seconds)s"
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
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(16)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }

    struct ActivityRow: View {
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
    StudyTab.ContentView()
}
