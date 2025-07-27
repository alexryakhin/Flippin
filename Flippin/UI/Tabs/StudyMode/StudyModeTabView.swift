import SwiftUI

/**
 Study Mode Tab View - Dedicated study session interface.
 Provides focused study experience with progress tracking.
 */

enum StudyModeTab {

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
            VStack(spacing: 16) {
                Text("Quick Stats")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
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
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        private var studyOptionsSection: some View {
            VStack(spacing: 16) {
                Text("Study Options")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    // Start study session
                    Button {
                        showStudyMode = true
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.title2)
                            Text("Start Study Session")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .padding(16)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                    }
                    .disabled(cardsProvider.cards.isEmpty)

                    // Review cards
                    if !cardsNeedingReview.isEmpty {
                        Button {
                            showStudyMode = true
                        } label: {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.title2)
                                Text("Review Due Cards (\(cardsNeedingReview.count))")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(12)
                        }
                        .disabled(cardsProvider.cards.isEmpty)
                    }

                    // Practice all cards
                    if !cardsProvider.cards.isEmpty {
                        Button {
                            showStudyMode = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.title2)
                                Text("Practice All Cards")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .padding(16)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        .disabled(cardsProvider.cards.isEmpty)
                    }
                }
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
        }

        private var recentActivitySection: some View {
            VStack(spacing: 16) {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
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
    StudyModeTab.ContentView()
}
