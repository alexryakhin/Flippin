//
//  ModeSelectionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct ModeSelectionStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var prefersTravelMode = false
        
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
                                        colors: [.cyan, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)
                            
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        VStack(spacing: 16) {
                            Text(Loc.UserProfile.modeSelectionTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Text(Loc.UserProfile.modeSelectionSubtitle)
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
                        SelectionCard(
                            icon: "book.fill",
                            title: Loc.Settings.learningMode,
                            description: Loc.Settings.learningModeDescription,
                            isSelected: !prefersTravelMode,
                            animateContent: animateContent,
                            delay: 0.7
                        ) {
                            prefersTravelMode = false
                            HapticService.shared.selection()
                        }
                        
                        SelectionCard(
                            icon: "airplane.departure",
                            title: Loc.Settings.travelMode,
                            description: Loc.Settings.travelModeDescription,
                            isSelected: prefersTravelMode,
                            animateContent: animateContent,
                            delay: 0.9
                        ) {
                            prefersTravelMode = true
                            HapticService.shared.selection()
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: StreakExplanationStepView(onContinue: onContinue),
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
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    prefersTravelMode = profileService.currentProfile?.prefersTravelMode ?? false
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            profileService.updateProfile(prefersTravelMode: prefersTravelMode)
            UserDefaults.standard.set(prefersTravelMode, forKey: UserDefaultsKey.cardDisplayMode)
            HapticService.shared.buttonTapped()
        }
    }
}

