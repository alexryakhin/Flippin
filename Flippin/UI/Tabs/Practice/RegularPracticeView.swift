import SwiftUI

extension StudyMode {

    struct RegularPracticeView: View {
        @StateObject private var colorManager = ColorManager.shared
        
        let card: CardItem
        let showingAnswer: Bool
        
        var body: some View {
            VStack(spacing: 16) {
                // Question
                VStack(spacing: 8) {
                    Text(Loc.Study.translateTo(card.frontLanguage?.displayName ?? Loc.PresetCollections.targetLanguage))
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
                        Text(Loc.Study.correctAnswer)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

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
    }
}

