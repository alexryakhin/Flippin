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
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedProficiency: LanguageProficiency = .beginner

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
                                .foregroundStyle(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                        VStack(spacing: 16) {
                            Text(Loc.WelcomeScreen.chooseLanguages)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                            Text(Loc.WelcomeScreen.chooseLanguagesDesc)
                                .font(.body)
                                .foregroundStyle(.secondary)
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
                            title: Loc.WelcomeScreen.myLanguage,
                            subtitle: Loc.WelcomeScreen.myLanguageDesc,
                            selection: $languageManager.userLanguageRaw,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        LanguagePickerCard(
                            title: Loc.WelcomeScreen.imLearning,
                            subtitle: Loc.WelcomeScreen.imLearningDesc,
                            selection: $languageManager.targetLanguageRaw,
                            animateContent: animateContent,
                            delay: 0.9
                        )
                        
                        // Proficiency Level Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Loc.UserProfile.proficiencyLevel)
                                .font(.headline)
                                .offset(x: animateContent ? 0 : -20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Picker(Loc.UserProfile.proficiencyLevel, selection: $selectedProficiency) {
                                ForEach(LanguageProficiency.allCases) { level in
                                    Text(level.displayName).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                            .scaleEffect(animateContent ? 1 : 0.95)
                            .opacity(animateContent ? 1 : 0)
                        }
                        .padding(20)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .animation(.easeInOut(duration: 0.4).delay(1.1), value: animateContent)
                    }

                    Spacer()

                    NavigationLink(destination: InterestsSelectionStepView(onContinue: onContinue)) {
                        ActionButton(
                            Loc.WelcomeScreen.continueButton,
                            style: .borderedProminent,
                            action: {}
                        )
                        .allowsHitTesting(false)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        saveAndContinue()
                    })
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    if let proficiency = profileService.currentProfile?.currentTargetLanguageProficiency {
                        selectedProficiency = proficiency
                    }
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            profileService.updateProfile(proficiency: selectedProficiency)
            HapticService.shared.buttonTapped()
        }
    }
}
