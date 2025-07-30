import SwiftUI

enum StudyMode: Int, Identifiable, Hashable {

    case practice    // Practice all cards
    case practice10  // Practice just 10 cards
    case difficult   // Practice difficult cards only
    case multipleChoice // Multiple choice quiz
    case fillInTheBlank // Fill in the blank exercise

    var id: Int { rawValue }
    
    var isRandomMode: Bool {
        switch self {
        case .practice, .practice10, .difficult:
            return true
        case .multipleChoice, .fillInTheBlank:
            return false
        }
    }

    struct ContentView: View {
        @Environment(\.dismiss) var dismiss
        @StateObject private var analyticsService = LearningAnalyticsService.shared
        @StateObject private var cardsProvider = CardsProvider.shared
        @StateObject private var colorManager = ColorManager.shared
        
        let studyMode: StudyMode
        
        @State private var currentCardIndex = 0
        @State private var showingAnswer = false
        @State private var cardStartTime = Date()
        @State private var studyCards: [CardItem] = []
        @State private var showingResults = false
        @State private var sessionResults: SessionResults?
        @State private var sessionStartTime = Date()
        @State private var sessionStats = SessionStats()
        @State private var currentCardMode: StudyMode = .practice // Track current card's mode
        
        struct SessionResults {
            let totalCards: Int
            let correctAnswers: Int
            let incorrectAnswers: Int
            let totalTime: TimeInterval
            let accuracy: Double
        }
        
        struct SessionStats {
            var correctAnswers: Int = 0
            var incorrectAnswers: Int = 0
            var totalTime: TimeInterval = 0
        }
        
        var body: some View {
            VStack(spacing: 0) {
                if !showingResults {
                    // Card content
                    cardContent

                    // Action buttons
                    actionButtons
                } else {
                    // Results view
                    resultsView
                }
            }
            .padding(vertical: 12, horizontal: 16)
            .background {
                AnimatedBackground(style: colorManager.backgroundStyle)
            }
            .navigation(
                title: LocalizationKeys.Study.practiceMode.localized,
                mode: .inline,
                clipMode: .rectangle,
                trailingContent: {
                    Button(LocalizationKeys.Study.exit.localized) {
                        HapticService.shared.buttonTapped()
                        endStudySession()
                        analyticsService.refreshAnalytics()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
                },
                bottomContent: {
                HStack(spacing: 8) {
                    // Progress text
                    Text(LocalizationKeys.Study.studyProgress.localized(with: currentCardIndex + 1, studyCards.count))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Progress bar
                    ProgressView(value: Double(currentCardIndex) / Double(studyCards.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                        .animation(.spring, value: currentCardIndex)
                }
            })
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .onAppear {
                setupStudySession()
            }
            .onDisappear {
                // Ensure session is ended if view disappears
                if analyticsService.currentSession != nil {
                    endStudySession()
                }
            }
            .interactiveDismissDisabled()
        }
        
        // MARK: - Card Content
        
        private var cardContent: some View {
            VStack(spacing: 0) {
                Spacer()
                
                if currentCardIndex < studyCards.count {
                    let card = studyCards[currentCardIndex]
                    
                    // Determine the mode for this card
                    let cardMode = studyMode.isRandomMode ? currentCardMode : studyMode
                    
                    switch cardMode {
                    case .multipleChoice:
                        StudyMode.MultipleChoiceQuizView(
                            card: card,
                            onAnswerSelected: { isCorrect in
                                recordAnswer(wasCorrect: isCorrect)
                            }
                        )
                    case .fillInTheBlank:
                        StudyMode.FillInTheBlankView(
                            card: card,
                            onAnswerSubmitted: { isCorrect in
                                recordAnswer(wasCorrect: isCorrect)
                            }
                        )
                    default:
                        StudyMode.RegularPracticeView(
                            card: card,
                            showingAnswer: showingAnswer
                        )
                    }
                }
                
                Spacer()
            }
        }
        
        // MARK: - Action Buttons

        @ViewBuilder
        private var actionButtons: some View {
            // Determine the mode for this card
            let cardMode = studyMode.isRandomMode ? currentCardMode : studyMode

            if cardMode != .multipleChoice && cardMode != .fillInTheBlank {
                VStack(spacing: 16) {
                    if !showingAnswer {
                        // Show answer button
                        Button(LocalizationKeys.Study.showAnswer.localized) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingAnswer = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                    } else {
                        // Correct/Incorrect buttons
                        HStack(spacing: 16) {
                            Button(LocalizationKeys.Study.incorrect.localized) {
                                recordAnswer(wasCorrect: false)
                            }
                            .tint(.red)
                            .buttonStyle(.borderedProminent)
                            .clipShape(Capsule())

                            Button(LocalizationKeys.Study.correct.localized) {
                                recordAnswer(wasCorrect: true)
                            }
                            .tint(.green)
                            .buttonStyle(.borderedProminent)
                            .clipShape(Capsule())
                        }
                    }
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
            }
        }
        
        // MARK: - Results View
        
        private var resultsView: some View {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Results header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text(LocalizationKeys.Study.practiceSessionComplete.localized)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }

                    // Results stats
                    if let results = sessionResults {
                        VStack(spacing: 16) {
                            ResultStatRow(
                                title: LocalizationKeys.Study.accuracy.localized,
                                value: results.accuracy.asPercentage,
                                icon: "target",
                                color: results.accuracy >= 0.8 ? .green : .orange
                            )

                            ResultStatRow(
                                title: LocalizationKeys.Study.cardsStudied.localized,
                                value: "\(results.totalCards)",
                                icon: "rectangle.stack.fill",
                                color: .blue
                            )

                            ResultStatRow(
                                title: LocalizationKeys.Study.timeSpent.localized,
                                value: results.totalTime.formattedSessionTime,
                                icon: "clock.fill",
                                color: .purple
                            )
                        }
                        .clippedWithPaddingAndBackgroundMaterial()
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(LocalizationKeys.Study.practiceAgain.localized) {
                            setupStudySession()
                        }
                        .foregroundStyle(colorManager.borderedProminentForegroundColor)
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())

                        Button(LocalizationKeys.Study.done.localized) {
                            // Force refresh analytics data and notify UI
                            analyticsService.refreshAnalytics()

                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.secondary)
                        .clipShape(Capsule())
                    }
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)

                Spacer()
            }
        }
        
        // MARK: - Helper Methods
        
        private func setupStudySession() {
            switch studyMode {
            case .practice:
                // Practice all cards
                studyCards = cardsProvider.cards
                // Initialize random mode for first card
                selectRandomModeForCard()
            case .practice10:
                let allCards = cardsProvider.cards
                if allCards.count <= 10 {
                    studyCards = allCards
                } else {
                    // Take a random sample of 10 cards
                    studyCards = Array(allCards.shuffled().prefix(10))
                }
                // Initialize random mode for first card
                selectRandomModeForCard()
            case .difficult:
                // Practice difficult cards only
                studyCards = analyticsService.getDifficultCardsNeedingReview()
                if studyCards.isEmpty {
                    // If no difficult cards, fall back to all cards
                    studyCards = cardsProvider.cards
                }
                // Initialize random mode for first card
                selectRandomModeForCard()
            case .multipleChoice:
                // Multiple choice quiz - use all cards
                studyCards = cardsProvider.cards
            case .fillInTheBlank:
                // Fill in the blank - only use cards with 3 or more words
                studyCards = cardsProvider.cards.filter { card in
                    let wordCount = card.frontText.orEmpty.components(separatedBy: .whitespacesAndNewlines)
                        .filter { !$0.isEmpty }.count
                    return wordCount >= 3
                }
                
                // If no cards with 3+ words, fall back to all cards
                if studyCards.isEmpty {
                    studyCards = cardsProvider.cards
                }
            }
            
            // Shuffle cards for study
            studyCards.shuffle()
            
            // Reset state
            currentCardIndex = 0
            showingAnswer = false
            showingResults = false
            sessionResults = nil
            sessionStartTime = Date()
            sessionStats = SessionStats()
            
            // Start analytics session
            analyticsService.startStudySession(sessionType: "study")
            
            // Start timing for first card
            cardStartTime = Date()
        }
        
        private func recordAnswer(wasCorrect: Bool) {
            guard currentCardIndex < studyCards.count else { return }
            
            let card = studyCards[currentCardIndex]
            let timeSpent = Date().timeIntervalSince(cardStartTime)
            
            // Update local session stats
            if wasCorrect {
                sessionStats.correctAnswers += 1
            } else {
                sessionStats.incorrectAnswers += 1
            }
            sessionStats.totalTime += timeSpent
            
            // Record the answer in analytics
            if let cardId = card.id {
                analyticsService.recordCardReview(
                    cardId: cardId,
                    wasCorrect: wasCorrect,
                    timeSpent: timeSpent    
                )
            }
            
            // Move to next card or end session
            moveToNextCard()
        }
        
        private func endStudySession() {
            analyticsService.endStudySession()
            showResults()
        }
        
        private func showResults() {
            let totalCards = studyCards.count
            let totalTime = Date().timeIntervalSince(sessionStartTime)
            let accuracy = totalCards > 0 ? Double(sessionStats.correctAnswers) / Double(totalCards) : 0.0
            
            sessionResults = SessionResults(
                totalCards: totalCards,
                correctAnswers: sessionStats.correctAnswers,
                incorrectAnswers: sessionStats.incorrectAnswers,
                totalTime: totalTime,
                accuracy: accuracy
            )
            
            // Ensure analytics data is saved
            analyticsService.objectWillChange.send()
            
            withAnimation(.easeInOut(duration: 0.5)) {
                showingResults = true
            }
        }
        
        private func moveToNextCard() {
            if currentCardIndex < studyCards.count - 1 {
                currentCardIndex += 1
                showingAnswer = false
                cardStartTime = Date()
                
                // For practice modes, randomly select mode for next card
                if studyMode.isRandomMode {
                    selectRandomModeForCard()
                }
            } else {
                // Session completed
                endStudySession()
            }
        }
        
        private func selectRandomModeForCard() {
            // Get the current card
            guard currentCardIndex < studyCards.count else { return }
            let currentCard = studyCards[currentCardIndex]
            
            // Count words in the card
            let wordCount = currentCard.frontText.orEmpty.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }.count
            
            if wordCount < 3 {
                // Single words: only use standard practice
                currentCardMode = .practice
            } else {
                // 3+ words: 50/50 between fill-in-the-blank and multiple choice
                let random = Double.random(in: 0...1)
                currentCardMode = random < 0.5 ? .fillInTheBlank : .multipleChoice
            }
        }
    }
}

// MARK: - Supporting Views

struct ResultStatRow: View {
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
    }
}

#Preview {
    StudyMode.ContentView(studyMode: .practice)
} 
