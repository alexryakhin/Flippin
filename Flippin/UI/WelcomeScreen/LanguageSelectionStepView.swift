//
//  LanguageSelectionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

extension WelcomeSheet {
    struct LanguageSelectionStepView: View {
        @StateObject private var languageManager = LanguageManager.shared
        @StateObject private var colorManager = ColorManager.shared
        @State private var animateContent = false

        let onContinue: () -> Void

        var body: some View {
            ZStack {
                // Animated background
                AnimatedBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 24) {
                        // Language selection icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)

                            Image(systemName: "globe")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                        VStack(spacing: 16) {
                            Text(LocalizationKeys.Welcome.chooseLanguages.localized)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                            Text(LocalizationKeys.Welcome.chooseLanguagesDesc.localized)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }

                    Spacer()

                    // Language pickers
                    VStack(spacing: 16) {
                        LanguagePickerCard(
                            title: LocalizationKeys.Welcome.myLanguage.localized,
                            subtitle: LocalizationKeys.Welcome.myLanguageDesc.localized,
                            selection: $languageManager.userLanguageRaw,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        LanguagePickerCard(
                            title: LocalizationKeys.Welcome.imLearning.localized,
                            subtitle: LocalizationKeys.Welcome.imLearningDesc.localized,
                            selection: $languageManager.targetLanguageRaw,
                            animateContent: animateContent,
                            delay: 0.9
                        )
                    }

                    Spacer()



                    NavigationLink(destination: ReadyStepView(onContinue: onContinue)) {
                        ActionButton(
                            LocalizationKeys.Welcome.continueButton.localized,
                            style: .borderedProminent,
                            action: {}
                        )
                    }
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
}
