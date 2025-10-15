//
//  GenderSelectionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct GenderSelectionStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedGender: Gender?
        
        let onContinue: () -> Void
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(animateContent ? 1 : 0.5)
                            .opacity(animateContent ? 1 : 0)

                        Image(systemName: "person.2.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    VStack(spacing: 16) {
                        Text(Loc.UserProfile.genderTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)

                        Text(Loc.UserProfile.genderSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)

                    VStack(spacing: 12) {
                        ForEach(Array(Gender.allCases.enumerated()), id: \.element) { index, gender in
                            SelectionCard(
                                icon: gender.icon,
                                title: gender.displayName,
                                isSelected: selectedGender == gender,
                                animateContent: animateContent,
                                delay: 0.7 + Double(index) * 0.1
                            ) {
                                selectedGender = gender
                                HapticService.shared.selection()
                            }
                        }
                    }
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .background {
                AnimatedBackground()
                    .ignoresSafeArea()
            }
            .safeAreaBarIfAvailable {
                NavigationLink(
                    destination: LanguageSelectionStepView(onContinue: onContinue),
                    label: {
                        ActionButton(
                            Loc.WelcomeScreen.continueButton,
                            style: .borderedProminent,
                            action: {}
                        )
                        .allowsHitTesting(false)
                    }
                )
                .simultaneousGesture(TapGesture().onEnded {
                    saveAndContinue()
                })
                .disabled(selectedGender == nil)
                .opacity(selectedGender == nil ? 0.5 : 1)
                .padding(vertical: 12, horizontal: 16)
            }
            .onAppear {
                selectedGender = profileService.currentProfile?.gender
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            guard let gender = selectedGender else { return }
            profileService.updateProfile(gender: gender)
            HapticService.shared.buttonTapped()
        }
    }
}

