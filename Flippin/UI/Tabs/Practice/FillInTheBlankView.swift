import SwiftUI
import Flow

extension StudyMode {

    struct FillInTheBlankView: View {
        @StateObject private var colorManager = ColorManager.shared
        
        let card: CardItem
        let onAnswerSubmitted: (Bool) -> Void
        
        @State private var showResult = false
        @State private var isCorrect = false
        @State private var correctAnswer = ""
        @State private var sentenceWithBlank = ""
        @State private var answerOptions: [String] = []
        @State private var selectedAnswer: String?
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Instructions
                    VStack(spacing: 4) {
                        Text(Loc.Study.fillInMissingWord)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(Loc.Study.completeSentence)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Sentence with blank
                    Text(sentenceWithBlank)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .clippedWithPaddingAndBackgroundMaterial()

                    // Answer options in capsules
                    VStack(alignment: .center, spacing: 16) {
                        Text(Loc.Study.chooseCorrectWord)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HFlow {
                            ForEach(answerOptions, id: \.self) { option in
                                CapsuleButton(
                                    title: option,
                                    isSelected: option == selectedAnswer,
                                    isCorrect: showResult && option == correctAnswer,
                                    isIncorrect: showResult && option == selectedAnswer && option != correctAnswer,
                                    onTap: {
                                        if !showResult {
                                            selectedAnswer = option
                                            checkAnswer(selectedAnswer: option)
                                        }
                                    }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.vertical)
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial)

                Spacer()
            }
            .onAppear {
                setupSentenceWithBlank()
            }
            .id(card.id) // Force view recreation when card changes
        }
        
        // MARK: - Helper Methods
        
        private func setupSentenceWithBlank() {
            let sentence = card.frontText.orEmpty
            let words = sentence.components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
            
            // Select a random word to replace with blank
            let randomIndex = Int.random(in: 0..<words.count)
            correctAnswer = words[randomIndex]
            
            // Create sentence with blank
            var sentenceWords = words
            sentenceWords[randomIndex] = "_____"
            sentenceWithBlank = sentenceWords.joined(separator: " ")
            
            // Generate answer options
            generateAnswerOptions()
        }
        
        private func generateAnswerOptions() {
            var options = [correctAnswer]
            
            // Get all words from all cards to create distractors
            let allCards = CardsProvider.shared.cards
            let allWords = allCards.flatMap { card in
                card.frontText.orEmpty.components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }
            }
            
            // Remove the correct answer from all words to avoid duplicates
            let availableWords = allWords.filter { $0 != correctAnswer }
            
            // Add random distractors (4-6 more words)
            let numberOfDistractors = min(6, availableWords.count)
            let randomDistractors = Array(availableWords.shuffled().prefix(numberOfDistractors))
            options.append(contentsOf: randomDistractors)
            
            // Shuffle the options
            answerOptions = options.shuffled()
        }
        
        private func checkAnswer(selectedAnswer: String) {
            isCorrect = selectedAnswer.lowercased() == correctAnswer.lowercased()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showResult = true
            }
            
            // Notify parent after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onAnswerSubmitted(isCorrect)
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    showResult = false
                    self.selectedAnswer = nil
                }
            }
        }
    }
    
    // MARK: - Supporting Views
    
    struct CapsuleButton: View {
        let title: String
        let isSelected: Bool
        let isCorrect: Bool
        let isIncorrect: Bool
        let onTap: () -> Void
        
        @StateObject private var colorManager = ColorManager.shared
        
        var body: some View {
            Button(action: onTap) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(backgroundColor)
                    )
                    .overlay(
                        Capsule()
                            .stroke(borderColor, lineWidth: 2)
                    )
            }
            .disabled(isCorrect || isIncorrect)
        }
        
        private var foregroundColor: Color {
            if isCorrect {
                return .white
            } else if isIncorrect {
                return .white
            } else {
                return isSelected ? .white : colorManager.tintColor
            }
        }
        
        private var backgroundColor: Color {
            if isCorrect {
                return .green
            } else if isIncorrect {
                return .red
            } else {
                return isSelected ? colorManager.tintColor : colorManager.tintColor.opacity(0.1)
            }
        }
        
        private var borderColor: Color {
            if isCorrect {
                return .green
            } else if isIncorrect {
                return .red
            } else {
                return isSelected ? colorManager.tintColor : .clear
            }
        }
    }
}
