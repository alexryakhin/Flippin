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

        @State private var premiumFeature: PremiumFeature?
        @State private var currentStudyMode: StudyModeView.StudyMode?

        // MARK: - Computed Properties

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
            .sheet(item: $currentStudyMode) { mode in
                StudyModeView(studyMode: mode)
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
                        title: "Difficult Cards",
                        value: "\(analyticsService.getDifficultCardsNeedingReview().count)",
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )

                    StatCard(
                        title: "Study Time Today",
                        value: studyTimeStats.today.formattedStudyTime,
                        icon: "clock",
                        color: .purple
                    )
                }
            }
        }

        private var studyOptionsSection: some View {
            CustomSectionView(header: "Study Options", headerFontStyle: .large) {
                VStack(spacing: 12) {
                    // Start study session (only show if user has more than 10 cards)
                    if cardsProvider.cards.count > 10 {
                        studyOptionButton(
                            image: Image(systemName: "play.fill"),
                            text: "Start Study Session (10 cards)",
                            color: .green,
                            isDisabled: cardsProvider.cards.isEmpty,
                            action: { 
                                currentStudyMode = .practice10
                            }
                        )
                    }

                    // Practice all cards
                    if !cardsProvider.cards.isEmpty {
                        studyOptionButton(
                            image: Image(.icCardsStack),
                            text: "Practice All Cards (\(cardsProvider.cards.count))",
                            color: .blue,
                            action: { 
                                currentStudyMode = .practice
                            }
                        )
                    }
                    
                    // Practice difficult cards
                    let difficultCards = analyticsService.getDifficultCardsNeedingReview()
                    if !difficultCards.isEmpty {
                        studyOptionButton(
                            image: Image(systemName: "exclamationmark.triangle.fill"),
                            text: "Practice Difficult Cards (\(difficultCards.count))",
                            color: .red,
                            action: { 
                                currentStudyMode = .difficult
                            }
                        )
                    }
                    
                    // Multiple choice quiz
                    if !cardsProvider.cards.isEmpty {
                        studyOptionButton(
                            image: Image(systemName: "list.bullet.circle.fill"),
                            text: "Multiple Choice Quiz",
                            color: .purple,
                            action: { 
                                currentStudyMode = .multipleChoice
                            }
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
                            value: studyTimeStats.total.formattedAnalyticsTime,
                            icon: "clock.fill",
                            color: .purple
                        )

                        ActivityRow(
                            title: "Average Session",
                            value: studyTimeStats.average.formattedStudyTime,
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

        // Removed formatStudyTime - now using TimeInterval extension
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
