//
//  LearningGoalStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct LearningGoalStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedGoal: LearningGoal?
        
        let onContinue: () -> Void
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(animateContent ? 1 : 0.5)
                            .opacity(animateContent ? 1 : 0)

                        Image(systemName: "flag.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    VStack(spacing: 16) {
                        Text(Loc.UserProfile.learningGoalTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)

                        Text(Loc.UserProfile.learningGoalSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)

                    VStack(spacing: 12) {
                        ForEach(Array(LearningGoal.allCases.enumerated()), id: \.element) { index, goal in
                            SelectionCard(
                                icon: goal.icon,
                                title: goal.displayName,
                                description: goal.description,
                                isSelected: selectedGoal == goal,
                                animateContent: animateContent,
                                delay: 0.7 + Double(index) * 0.1
                            ) {
                                selectedGoal = goal
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
            .onAppear {
                selectedGoal = profileService.currentProfile?.learningGoal
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
            .safeAreaBarIfAvailable {
                NavigationLink(
                    destination: ModeSelectionStepView(onContinue: onContinue),
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
                .disabled(selectedGoal == nil)
                .opacity(selectedGoal == nil ? 0.5 : 1)
                .padding(vertical: 12, horizontal: 16)
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            guard let goal = selectedGoal else { return }
            profileService.updateProfile(learningGoal: goal)
            HapticService.shared.buttonTapped()
        }
    }
}

