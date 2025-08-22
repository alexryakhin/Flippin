import SwiftUI

/**
 Practice Mode Tab View - Dedicated practice session interface.
 Provides focused practice experience with progress tracking.
 */

enum PracticeTab {

    struct ContentView: View {
        // MARK: - State Objects

        @StateObject private var cardsProvider = CardsProvider.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var purchaseService = PurchaseService.shared

        // MARK: - State Variables

        @State private var premiumFeature: PremiumFeature?
        @State private var currentStudyMode: StudyMode?

        // MARK: - Computed Properties

        var masteryStats: (total: Int, mastered: Int, learning: Int, needsReview: Int) {
            analyticsService.getMasteryStats()
        }

        var practiceTimeStats: (total: TimeInterval, today: TimeInterval, average: TimeInterval) {
            // Calculate practice time (only formal study sessions, not card flipping)
            let total = analyticsService.totalStudyTime
            
            // Calculate today's practice time from formal study sessions only
            let today = analyticsService.getTodayStudyTime()
            
            // Calculate average session time
            let average = analyticsService.getAverageSessionTime()
            
            return (total, today, average)
        }

        // MARK: - Body

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick stats
                    quickStatsSection

                    // Practice options
                    practiceOptionsSection

                    // Recent activity
                    recentActivitySection
                }
                .padding(16)
                .if(isPad) { view in
                    view.frame(maxWidth: 500, alignment: .center)
                }
            }
            .navigation(title: LocalizationKeys.Study.practice.localized)
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .sheet(item: $currentStudyMode) { mode in
                StudyMode.ContentView(studyMode: mode)
            }
            .premiumAlert(feature: $premiumFeature)
        }

        // MARK: - UI Components

        private var quickStatsSection: some View {
            CustomSectionView(header: LocalizationKeys.Study.quickStats.localized, headerFontStyle: .large) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                    spacing: 8
                ) {
                    StatCard(
                        title: LocalizationKeys.Study.totalCards.localized,
                        value: "\(cardsProvider.cards.count)",
                        icon: "rectangle.stack.fill",
                        color: .blue
                    )

                    StatCard(
                        title: LocalizationKeys.Study.mastered.localized,
                        value: "\(masteryStats.mastered)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    StatCard(
                        title: LocalizationKeys.Study.difficultCards.localized,
                        value: "\(analyticsService.getDifficultCardsNeedingReview().count)",
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )

                    StatCard(
                        title: LocalizationKeys.Study.practiceTimeToday.localized,
                        value: practiceTimeStats.today.formattedStudyTime,
                        icon: "clock",
                        color: .purple
                    )
                }
            }
        }

        @ViewBuilder
        private var practiceOptionsSection: some View {
            if !cardsProvider.cards.isEmpty {
                CustomSectionView(header: LocalizationKeys.Study.practiceOptions.localized, headerFontStyle: .large) {
                    VStack(spacing: 12) {
                        // Start practice session (only show if user has more than 10 cards)
                        if cardsProvider.cards.count > 10 {
                            practiceOptionButton(
                                image: Image(systemName: "play.fill"),
                                text: LocalizationKeys.Study.startPracticeSession.localized,
                                color: .green,
                                isDisabled: cardsProvider.cards.isEmpty,
                                action: {
                                    currentStudyMode = .practice10
                                }
                            )
                        }

                        // Practice all cards
                        practiceOptionButton(
                            image: Image(.icCardStackFill),
                            text: LocalizationKeys.Study.practiceAllCards.localized(with: cardsProvider.cards.count),
                            color: .blue,
                            action: {
                                currentStudyMode = .practice
                            }
                        )

                        // Practice difficult cards
                        let difficultCards = analyticsService.getDifficultCardsNeedingReview()
                        if !difficultCards.isEmpty {
                            practiceOptionButton(
                                image: Image(systemName: "exclamationmark.triangle.fill"),
                                text: LocalizationKeys.Study.practiceDifficultCards.localized(with: difficultCards.count),
                                color: .red,
                                action: {
                                    currentStudyMode = .difficult
                                }
                            )
                        }

                        if purchaseService.hasPremiumAccess {
                            // Multiple choice quiz
                            practiceOptionButton(
                                image: Image(systemName: "list.bullet.circle.fill"),
                                text: LocalizationKeys.Study.multipleChoiceQuiz.localized,
                                color: .purple,
                                action: {
                                    currentStudyMode = .multipleChoice
                                }
                            )

                            // Fill in the blank
                            let fillInTheBlankCards = cardsProvider.cards.filter { card in
                                let wordCount = card.frontText.orEmpty.components(separatedBy: .whitespacesAndNewlines)
                                    .filter { !$0.isEmpty }.count
                                return wordCount >= 3
                            }

                            practiceOptionButton(
                                image: Image(systemName: "pencil.circle.fill"),
                                text: LocalizationKeys.Study.fillInTheBlank.localized(with: fillInTheBlankCards.count),
                                color: .orange,
                                isDisabled: fillInTheBlankCards.isEmpty,
                                action: {
                                    currentStudyMode = .fillInTheBlank
                                }
                            )
                        } else {
                            practiceOptionButton(
                                image: Image(systemName: "crown.fill"),
                                text: LocalizationKeys.Study.unlockAllStudyModes.localized,
                                color: .teal,
                                action: {
                                    premiumFeature = .studyModes
                                }
                            )
                        }
                    }
                }
            }
        }

        private func practiceOptionButton(
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
                        .multilineTextAlignment(.leading)
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
            CustomSectionView(header: LocalizationKeys.Study.recentActivity.localized, headerFontStyle: .large) {
                if cardsProvider.cards.isEmpty {
                    ContentUnavailableView {
                        VStack {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                            Text(LocalizationKeys.Study.noStudyData.localized)
                        }
                    } description: {
                        Text(LocalizationKeys.Study.startStudyingToSeeProgress.localized)
                            .foregroundStyle(.secondary)
                    } actions: {
                        HeaderButton(
                            LocalizationKeys.Study.toCards.localized,
                            style: .borderedProminent
                        ) {
                            NavigationManager.shared.switchToTab(.study)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        ActivityRow(
                            title: LocalizationKeys.Study.totalPracticeTime.localized,
                            value: practiceTimeStats.total.formattedAnalyticsTime,
                            icon: "clock.fill",
                            color: .purple
                        )

                        ActivityRow(
                            title: LocalizationKeys.Study.averageSession.localized,
                            value: practiceTimeStats.average.formattedStudyTime,
                            icon: "timer",
                            color: .blue
                        )

                        ActivityRow(
                            title: LocalizationKeys.Study.learningProgress.localized,
                            value: LocalizationKeys.Analytics.cardsCount.localized(with: Int(masteryStats.learning)),
                            icon: "brain.head.profile",
                            color: .orange
                        )
                    }
                }
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
    PracticeTab.ContentView()
}
