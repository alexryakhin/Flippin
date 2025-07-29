import SwiftUI

extension StudyMode {

    struct MultipleChoiceQuizView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var cardsProvider = CardsProvider.shared
        
        let card: CardItem
        let onAnswerSelected: (Bool) -> Void
        
        @State private var multipleChoiceOptions: [String] = []
        @State private var selectedAnswer: String?
        @State private var showAnswerResult = false
        @State private var isAnswerCorrect = false
        
        var body: some View {
            VStack(spacing: 24) {
                // Question
                VStack(spacing: 16) {
                    Text("Select the correct translation")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Text(card.frontText.orEmpty)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(4)
                        .multilineTextAlignment(.center)
                        .clippedWithPaddingAndBackgroundMaterial()
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
                                    checkAnswer()
                                }
                            }
                        }
                    }
                }
            }
            .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)
            .onAppear {
                print("📊 MultipleChoiceQuizView appeared for card: \(card.frontText.orEmpty)")
                resetState()
                generateOptions()
            }
            .id(card.id) // Force view recreation when card changes
        }
        
        // MARK: - Helper Methods
        
        private func resetState() {
            print("📊 Resetting state for card: \(card.frontText.orEmpty)")
            selectedAnswer = nil
            showAnswerResult = false
            isAnswerCorrect = false
            multipleChoiceOptions = []
        }
        
        private func generateOptions() {
            let correctAnswer = card.backText.orEmpty
            var options = [correctAnswer]
            
            print("📊 Generating options for card: \(card.frontText.orEmpty)")
            print("📊 Correct answer: \(correctAnswer)")
            print("📊 Card back language: \(card.backLanguage?.displayName ?? "unknown")")
            
            // Get other cards with the SAME back language as the current card
            let sameLanguageCards = cardsProvider.cards.filter { otherCard in
                otherCard.id != card.id && 
                otherCard.backLanguage == card.backLanguage
            }
            let shuffledSameLanguage = sameLanguageCards.shuffled()
            
            print("📊 Available cards with same back language: \(sameLanguageCards.count)")
            
            // Add wrong options from cards with the same back language
            // But ensure they are DIFFERENT words, not just different cards
            var usedWords: Set<String> = [correctAnswer]
            
            for otherCard in shuffledSameLanguage.prefix(6) { // Check more cards to find different words
                let wrongAnswer = otherCard.backText.orEmpty
                
                // Only add if it's a different word (not the same translation)
                if !usedWords.contains(wrongAnswer) {
                    options.append(wrongAnswer)
                    usedWords.insert(wrongAnswer)
                    print("📊 Added wrong option: \(wrongAnswer)")
                    
                    // Stop when we have 4 total options
                    if options.count >= 4 {
                        break
                    }
                }
            }
            
            // If we don't have enough different words, add some generic ones
            while options.count < 4 {
                let genericOptions = ["I don't know", "Maybe", "Not sure", "Skip"]
                for option in genericOptions {
                    if !usedWords.contains(option) {
                        options.append(option)
                        usedWords.insert(option)
                        print("📊 Added generic option: \(option)")
                        break
                    }
                }
            }
            
            // Shuffle the options
            multipleChoiceOptions = options.shuffled()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                withAnimation {
                    multipleChoiceOptions.shuffle()
                }
            })

            print("📊 Final options: \(multipleChoiceOptions)")
            print("📊 Correct answer is in options: \(multipleChoiceOptions.contains(correctAnswer))")
        }
        
        private func checkAnswer() {
            let correctAnswer = card.backText.orEmpty
            isAnswerCorrect = selectedAnswer == correctAnswer
            
            // Show result for a moment
            showAnswerResult = true
            
            // Notify parent after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onAnswerSelected(isAnswerCorrect)
            }
        }
        
        // MARK: - Supporting Views
        
        private func multipleChoiceButton(
            text: String,
            isSelected: Bool,
            isCorrect: Bool,
            isIncorrect: Bool,
            action: @escaping () -> Void
        ) -> some View {
            Button(action: action) {
                Text(text)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
}
