//
//  ImageOnboardingView.swift
//  Flippin
//
//  Created by AI Assistant
//

import SwiftUI

struct ImageOnboardingView: View {
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @State private var animateContent = false
    @State private var exampleCards: [MockCardView.Model] = []
    @Environment(\.dismiss) var dismiss
    
    let onContinue: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {

                    // Header
                    VStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(colorManager.tintColor.gradient)
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)

                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                            VStack(spacing: 12) {
                                Text(Loc.CardImages.ImageOnboarding.title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                                Text(Loc.CardImages.ImageOnboarding.subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                                .padding(.horizontal, 16)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }

                    // Mock Card Examples
                    VStack(spacing: 24) {
                        Text(Loc.CardImages.ImageOnboarding.previewTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateContent)
                        
                        ForEach(Array(exampleCards.enumerated()), id: \.offset) { index, card in
                            VStack(spacing: 16) {
                                Text("\(languageManager.targetLanguage.displayName) → \(languageManager.userLanguage.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                    .tracking(1)

                                MockCardView(
                                    model: card,
                                    animateContent: animateContent,
                                    delay: 0.8 + Double(index) * 0.2
                                )
                            }
                        }
                    }

                    // Benefits
                    VStack(spacing: 16) {
                        BenefitRow(
                            icon: "brain.head.profile",
                            title: Loc.CardImages.ImageOnboarding.Benefit.Memory.title,
                            description: Loc.CardImages.ImageOnboarding.Benefit.Memory.description,
                            animateContent: animateContent,
                            delay: 1.2
                        )

                        BenefitRow(
                            icon: "eye.fill",
                            title: Loc.CardImages.ImageOnboarding.Benefit.Visual.title,
                            description: Loc.CardImages.ImageOnboarding.Benefit.Visual.description,
                            animateContent: animateContent,
                            delay: 1.4
                        )

                        BenefitRow(
                            icon: "sparkles",
                            title: Loc.CardImages.ImageOnboarding.Benefit.Enhanced.title,
                            description: Loc.CardImages.ImageOnboarding.Benefit.Enhanced.description,
                            animateContent: animateContent,
                            delay: 1.6
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .background {
                WelcomeSheet.AnimatedBackground()
                    .ignoresSafeArea()
            }
            .safeAreaBarIfAvailable {
                ActionButton(
                    Loc.CardImages.ImageOnboarding.getStarted,
                    style: .borderedProminent
                ) {
                    onContinue()
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(Loc.CardImages.ImageOnboarding.skip) {
                        onContinue()
                    }
                    .foregroundStyle(colorManager.tintColor)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                animateContent = true
            }
            loadExampleCards()
        }
    }
    
    // MARK: - Methods
    
    private func loadExampleCards() {
        // Get localized strings for the target language
        let card1Front = localizedString("imageOnboarding.example.card1", language: languageManager.targetLanguage)
        let card2Front = localizedString("imageOnboarding.example.card2", language: languageManager.targetLanguage)
        let card3Front = localizedString("imageOnboarding.example.card3", language: languageManager.targetLanguage)
        
        // Get localized strings for the user language (back side)
        let card1Back = localizedString("imageOnboarding.example.card1", language: languageManager.userLanguage)
        let card2Back = localizedString("imageOnboarding.example.card2", language: languageManager.userLanguage)
        let card3Back = localizedString("imageOnboarding.example.card3", language: languageManager.userLanguage)
        
        exampleCards = [
            .init(
                frontText: card1Front,
                backText: card1Back,
                image: Image(.imageCard),
                tags: ["work", "business", "career"]
            ),
            .init(
                frontText: card2Front,
                backText: card2Back,
                image: Image(.imageStretching),
                tags: ["gym", "fitness", "health"]
            ),
            .init(
                frontText: card3Front,
                backText: card3Back,
                image: Image(.imagePlane),
                tags: ["travel", "vacation", "journey"]
            )
        ]
    }
    
    private func localizedString(_ key: String, language: Language) -> String {
        // Get the bundle path for the language
        guard let path = Bundle.main.path(forResource: language.voiceOverCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle if language not found
            return NSLocalizedString(key, tableName: "CardImages", comment: "")
        }
        
        return bundle.localizedString(forKey: key, value: nil, table: "CardImages")
    }
}

extension ImageOnboardingView {
    // MARK: - Mock Card View
    struct MockCardView: View {
        struct Model {
            let frontText: String
            let backText: String
            let image: Image
            let tags: [String]
        }
        let model: Model
        let animateContent: Bool
        let delay: Double

        @State private var isFlipped = false

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                VStack(spacing: 12) {
                    Text(isFlipped ? model.backText : model.frontText)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)

                    model.image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(.rect(cornerRadius: 12))

                    HStack(spacing: 8) {
                        ForEach(model.tags, id: \.self) { tag in
                            TagView(title: tag, isSelected: false)
                        }
                    }
                }
                .padding(16)
            }
            .scaleEffect(animateContent ? 1 : 0.8)
            .opacity(animateContent ? 1 : 0)
            .animation(.easeInOut(duration: 0.5).delay(delay), value: animateContent)
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
        }
    }

    // MARK: - Benefit Row
    struct BenefitRow: View {
        let icon: String
        let title: String
        let description: String
        let animateContent: Bool
        let delay: Double

        @StateObject private var colorManager = ColorManager.shared

        var body: some View {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(colorManager.tintColor.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(colorManager.tintColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .offset(x: animateContent ? 0 : -20)
            .opacity(animateContent ? 1 : 0)
            .animation(.easeInOut(duration: 0.5).delay(delay), value: animateContent)
        }
    }
}


#Preview {
    ImageOnboardingView {
        debugPrint("Onboarding completed")
    }
}
