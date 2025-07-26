import SwiftUI

struct StudyModeView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    
    @State private var currentCardIndex = 0
    @State private var showingAnswer = false
    @State private var cardStartTime = Date()
    @State private var studyCards: [CardItem] = []
    @State private var showingResults = false
    @State private var sessionResults: SessionResults?
    
    struct SessionResults {
        let totalCards: Int
        let correctAnswers: Int
        let incorrectAnswers: Int
        let totalTime: TimeInterval
        let accuracy: Double
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !showingResults {
                    // Progress indicator
                    progressHeader
                    
                    // Card content
                    cardContent
                    
                    // Action buttons
                    actionButtons
                } else {
                    // Results view
                    resultsView
                }
            }
            .background {
                AnimatedBackground(style: colorManager.backgroundStyle)
            }
            .navigationTitle("Study Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Exit") {
                        endStudySession()
                        dismiss()
                    }
                }
            }
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .onAppear {
            setupStudySession()
        }
        .onDisappear {
            endStudySession()
        }
    }
    
    // MARK: - Progress Header
    
    private var progressHeader: some View {
        VStack(spacing: 8) {
            // Progress bar
            ProgressView(value: Double(currentCardIndex), total: Double(studyCards.count))
                .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                .padding(.horizontal)
            
            // Progress text
            HStack {
                Text("\(currentCardIndex + 1) of \(studyCards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Study Mode")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorManager.tintColor.opacity(0.2))
                    .foregroundColor(colorManager.tintColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if currentCardIndex < studyCards.count {
                let card = studyCards[currentCardIndex]
                
                VStack(spacing: 16) {
                    // Question
                    VStack(spacing: 8) {
                        Text("Translate to \(card.frontLanguage?.displayName ?? LocalizationKeys.targetLanguage.localized)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(card.backText.orEmpty)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Answer (shown after user interaction)
                    if showingAnswer {
                        VStack(spacing: 8) {
                            Text("Correct Answer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(card.frontText.orEmpty)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if !showingAnswer {
                // Show answer button
                Button("Show Answer") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAnswer = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(colorManager.tintColor)
                .font(.headline)
            } else {
                // Correct/Incorrect buttons
                HStack(spacing: 16) {
                    Button("Incorrect") {
                        recordAnswer(wasCorrect: false)
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .font(.headline)
                    
                    Button("Correct") {
                        recordAnswer(wasCorrect: true)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .font(.headline)
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
                        value: "\(Int(results.accuracy * 100))%",
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
                        value: formatStudyTime(results.totalTime),
                        icon: "clock.fill",
                        color: .purple
                    )
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Study Again") {
                    setupStudySession()
                }
                .buttonStyle(.borderedProminent)
                .tint(colorManager.tintColor)
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupStudySession() {
        // Get cards that need review or all cards if none need review
        let cardsNeedingReview = analyticsService.getCardsNeedingReview()
        studyCards = cardsNeedingReview.isEmpty ? cardsProvider.cards : cardsNeedingReview
        
        // Shuffle cards for study
        studyCards.shuffle()
        
        // Reset state
        currentCardIndex = 0
        showingAnswer = false
        showingResults = false
        sessionResults = nil
        
        // Start analytics session
        analyticsService.startStudySession(sessionType: "study")
        
        // Start timing for first card
        cardStartTime = Date()
    }
    
    private func recordAnswer(wasCorrect: Bool) {
        guard currentCardIndex < studyCards.count else { return }
        
        let card = studyCards[currentCardIndex]
        let timeSpent = Date().timeIntervalSince(cardStartTime)
        
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
        let correctAnswers = analyticsService.currentSession?.cardsCorrect ?? 0
        let incorrectAnswers = analyticsService.currentSession?.cardsIncorrect ?? 0
        let totalTime = analyticsService.currentSession?.duration ?? 0
        let accuracy = totalCards > 0 ? Double(correctAnswers) / Double(totalCards) : 0.0
        
        sessionResults = SessionResults(
            totalCards: totalCards,
            correctAnswers: Int(correctAnswers),
            incorrectAnswers: Int(incorrectAnswers),
            totalTime: totalTime,
            accuracy: accuracy
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showingResults = true
        }
    }
    
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
    StudyModeView()
} 
