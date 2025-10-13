//
//  WeeklyGoalStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct WeeklyGoalStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedGoal: WeeklyGoal?
        
        let onContinue: () -> Void
        
        var body: some View {
            ZStack {
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.orange, .yellow],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)
                            
                            Image(systemName: "target")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        VStack(spacing: 16) {
                            Text(Loc.UserProfile.weeklyGoalTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Text(Loc.UserProfile.weeklyGoalSubtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        ForEach(Array(WeeklyGoal.allCases.enumerated()), id: \.element) { index, goal in
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
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: LearningGoalStepView(onContinue: onContinue),
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
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    selectedGoal = profileService.currentProfile?.weeklyGoal
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            guard let goal = selectedGoal else { return }
            profileService.updateProfile(weeklyGoal: goal)
            HapticService.shared.buttonTapped()
        }
    }
}

