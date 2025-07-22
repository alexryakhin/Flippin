//
//  WelcomeStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

extension WelcomeSheet {
    struct WelcomeStepView: View {
        @State private var animateContent = false

        let title: String
        let message: String
        let onContinue: () -> Void

        var body: some View {
            VStack(spacing: 0) {
                Spacer()

                // App icon and title
                VStack(spacing: 24) {
                    // Animated app icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(animateContent ? 1 : 0.5)
                            .opacity(animateContent ? 1 : 0)

                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    VStack(spacing: 16) {
                        Text(title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)

                        Text(message)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                }

                Spacer()

                // Feature highlights
                VStack(spacing: 20) {
                    FeatureRow(
                        icon: "translate",
                        title: LocalizationKeys.featureLearning.localized,
                        description: LocalizationKeys.featureLearningDesc.localized,
                        animateContent: animateContent,
                        delay: 0.7
                    )

                    FeatureRow(
                        icon: "globe",
                        title: LocalizationKeys.featureLanguages.localized,
                        description: LocalizationKeys.featureLanguagesDesc.localized,
                        animateContent: animateContent,
                        delay: 0.9
                    )

                    FeatureRow(
                        icon: "speaker.wave.2.bubble.fill",
                        title: LocalizationKeys.featureSmart.localized,
                        description: LocalizationKeys.featureSmartDesc.localized,
                        animateContent: animateContent,
                        delay: 1.1
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Navigation button
                NavigationLink(
                    destination: LanguageSelectionStepView(onContinue: onContinue)
                ) {
                    Text(LocalizationKeys.continueButton.localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(vertical: 12, horizontal: 16)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(vertical: 12, horizontal: 16)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }
}
