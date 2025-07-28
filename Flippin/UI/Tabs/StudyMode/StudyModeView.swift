import SwiftUI

struct StudyModeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    
    let studyMode: StudyMode
    
    init(studyMode: StudyMode) {
        self.studyMode = studyMode
    }
    
    @State private var currentCardIndex = 0
    @State private var showingAnswer = false
    @State private var cardStartTime = Date()
    @State private var studyCards: [CardItem] = []
    @State private var showingResults = false
    @State private var sessionResults: SessionResults?
    @State private var sessionStartTime = Date()
    @State private var sessionStats = SessionStats()
    @State private var multipleChoiceOptions: [String] = []
    @State private var selectedAnswer: String?
    @State private var showAnswerResult = false
    @State private var isAnswerCorrect = false
    
    enum StudyMode: Int, Identifiable, Hashable {
        case practice    // Practice all cards
        case practice10  // Practice just 10 cards
        case difficult   // Practice difficult cards only
        case multipleChoice // Multiple choice quiz

        var id: Int { rawValue }
    }
    
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
        .navigation(title: "Study Mode", mode: .inline, clipMode: .rectangle, trailingContent: {
            Button("Exit") {
                HapticService.shared.buttonTapped()
                endStudySession()
                analyticsService.refreshAnalytics()
                dismiss()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.secondary)
            .clipShape(Capsule())
        }, bottomContent: {
            HStack(spacing: 8) {
                // Progress text
                Text("\(currentCardIndex + 1) of \(studyCards.count)")
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
                
                if studyMode == .multipleChoice {
                    multipleChoiceCard(card: card)
                } else {
                    translationCard(card: card)
                }
            }
            
            Spacer()
        }
    }
    
    private func translationCard(card: CardItem) -> some View {
        VStack(spacing: 16) {
            // Question
            VStack(spacing: 8) {
                Text("Translate to \(card.frontLanguage?.displayName ?? LocalizationKeys.targetLanguage.localized)")
                    .font(.subheadline)
                    .foregroundColor(colorManager.foregroundColor)

                Text(card.backText.orEmpty)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
            }
            
            // Answer (shown after user interaction)
            if showingAnswer {
                VStack(spacing: 8) {
                    Text("Correct Answer")
                        .font(.subheadline)
                        .foregroundColor(colorManager.foregroundColor)

                    Text(card.frontText.orEmpty)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .frame(maxWidth: .infinity)
                        .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }
    
    private func multipleChoiceCard(card: CardItem) -> some View {
        VStack(spacing: 20) {
            // Question
            VStack(spacing: 8) {
                Text("Select the correct translation")
                    .font(.subheadline)
                    .foregroundColor(colorManager.foregroundColor)

                Text(card.frontText.orEmpty)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
            }
            
            // Multiple choice options
            if !multipleChoiceOptions.isEmpty {
                VStack(spacing: 12) {
                    ForEach(multipleChoiceOptions, id: \.self) { option in
                        multipleChoiceButton(
                            text: option,
                            isSelected: selectedAnswer == option,
                            isCorrect: showAnswerResult && option == card.backText.orEmpty,
                            isIncorrect: showAnswerResult && selectedAnswer == option && option != card.backText.orEmpty
                        ) {
                            if selectedAnswer == nil {
                                selectedAnswer = option
                                checkMultipleChoiceAnswer(card: card)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if studyMode != .multipleChoice {
                if !showingAnswer {
                    // Show answer button
                    Button("Show Answer") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingAnswer = true
                        }
                    }
                    .foregroundStyle(colorManager.borderedProminentForegroundColor)
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                } else {
                    // Correct/Incorrect buttons
                    HStack(spacing: 16) {
                        Button("Incorrect") {
                            recordAnswer(wasCorrect: false)
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(Capsule())
                        .tint(.red)

                        Button("Correct") {
                            recordAnswer(wasCorrect: true)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Results header
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Study Session Complete!")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // Results stats
            if let results = sessionResults {
                VStack(spacing: 16) {
                    ResultStatRow(
                        title: "Accuracy",
                        value: results.accuracy.asPercentage,
                        icon: "target",
                        color: results.accuracy >= 0.8 ? .green : .orange
                    )
                    
                    ResultStatRow(
                        title: "Cards Studied",
                        value: "\(results.totalCards)",
                        icon: "rectangle.stack.fill",
                        color: .blue
                    )
                    
                    ResultStatRow(
                        title: "Time Spent",
                        value: results.totalTime.formattedSessionTime,
                        icon: "clock.fill",
                        color: .purple
                    )
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
                .padding(.horizontal)
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Study Again") {
                    setupStudySession()
                }
                .foregroundStyle(colorManager.borderedProminentForegroundColor)
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())

                Button("Done") {
                    // Force refresh analytics data and notify UI
                    analyticsService.refreshAnalytics()
                    
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
                .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupStudySession() {
        switch studyMode {
        case .practice:
            // Practice all cards
            studyCards = cardsProvider.cards
        case .practice10:
            let allCards = cardsProvider.cards
            if allCards.count <= 10 {
                studyCards = allCards
            } else {
                // Take a random sample of 10 cards
                studyCards = Array(allCards.shuffled().prefix(10))
            }
        case .difficult:
            // Practice difficult cards only
            studyCards = analyticsService.getDifficultCardsNeedingReview()
            if studyCards.isEmpty {
                // If no difficult cards, fall back to all cards
                studyCards = cardsProvider.cards
            }
        case .multipleChoice:
            // For multiple choice, use all cards but limit to 10 for manageable sessions
            let allCards = cardsProvider.cards
            if allCards.count <= 10 {
                studyCards = allCards
            } else {
                // Take a random sample of 10 cards for multiple choice
                studyCards = Array(allCards.shuffled().prefix(10))
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
        
        // Generate multiple choice options if needed
        if studyMode == .multipleChoice && !studyCards.isEmpty {
            let firstCard = studyCards[0]
            generateMultipleChoiceOptions(for: firstCard)
        }
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
        if currentCardIndex + 1 < studyCards.count {
            currentCardIndex += 1
            showingAnswer = false
            cardStartTime = Date()
            
            // Haptic feedback
            HapticService.shared.cardFlipped()
        } else {
            // End session
            endStudySession()
            showResults()
        }
    }
    
    private func endStudySession() {
        analyticsService.endStudySession()
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
    
    // MARK: - Multiple Choice Methods
    
    private func generateMultipleChoiceOptions(for card: CardItem) {
        let correctAnswer = card.backText.orEmpty
        var options = [correctAnswer]
        
        // Get other cards to use as wrong options
        let otherCards = cardsProvider.cards.filter { $0.id != card.id }
        let shuffledOthers = otherCards.shuffled()
        
        // Add 3 wrong options
        for otherCard in shuffledOthers.prefix(3) {
            let wrongAnswer = otherCard.backText.orEmpty
            if !options.contains(wrongAnswer) {
                options.append(wrongAnswer)
            }
        }
        
        // If we don't have enough options, add some generic ones
        while options.count < 4 {
            let genericOptions = ["I don't know", "Maybe", "Not sure", "Skip"]
            for option in genericOptions {
                if !options.contains(option) {
                    options.append(option)
                    break
                }
            }
        }
        
        // Shuffle the options
        multipleChoiceOptions = options.shuffled()
    }
    
    private func checkMultipleChoiceAnswer(card: CardItem) {
        let correctAnswer = card.backText.orEmpty
        isAnswerCorrect = selectedAnswer == correctAnswer
        
        // Show result for a moment
        showAnswerResult = true
        
        // Record the answer
        recordMultipleChoiceAnswer(card: card, wasCorrect: isAnswerCorrect)
        
        // Move to next card after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            moveToNextCard()
        }
    }
    
    private func recordMultipleChoiceAnswer(card: CardItem, wasCorrect: Bool) {
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
    }
    
    private func moveToNextCard() {
        if currentCardIndex + 1 < studyCards.count {
            currentCardIndex += 1
            resetMultipleChoiceState()
            cardStartTime = Date()
            
            // Haptic feedback
            HapticService.shared.cardFlipped()
        } else {
            // End session
            endStudySession()
            showResults()
        }
    }
    
    private func resetMultipleChoiceState() {
        selectedAnswer = nil
        showAnswerResult = false
        multipleChoiceOptions = []
        
        // Generate options for the new card
        if currentCardIndex < studyCards.count {
            let card = studyCards[currentCardIndex]
            generateMultipleChoiceOptions(for: card)
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

extension StudyModeView {
    func multipleChoiceButton(
        text: String,
        isSelected: Bool,
        isCorrect: Bool,
        isIncorrect: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                        .font(.title2)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        isIncorrect: isIncorrect
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor(
                                isSelected: isSelected,
                                isCorrect: isCorrect,
                                isIncorrect: isIncorrect
                            ), lineWidth: 2)
                    )
            )
            .foregroundColor(textColor(
                isSelected: isSelected,
                isCorrect: isCorrect,
                isIncorrect: isIncorrect
            ))
        }
        .disabled(isSelected)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isCorrect)
        .animation(.easeInOut(duration: 0.2), value: isIncorrect)
    }
    
    private func backgroundColor(isSelected: Bool, isCorrect: Bool, isIncorrect: Bool) -> Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isIncorrect {
            return .red.opacity(0.2)
        } else if isSelected {
            return colorManager.tintColor.opacity(0.2)
        } else {
            return Color(.tertiarySystemGroupedBackground)
        }
    }
    
    private func borderColor(isSelected: Bool, isCorrect: Bool, isIncorrect: Bool) -> Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else if isSelected {
            return colorManager.tintColor
        } else {
            return Color(.separator)
        }
    }
    
    private func textColor(isSelected: Bool, isCorrect: Bool, isIncorrect: Bool) -> Color {
        if isCorrect || isIncorrect {
            return .primary
        } else if isSelected {
            return colorManager.tintColor
        } else {
            return .primary
        }
    }
}

#Preview {
    StudyModeView(studyMode: .practice)
}
