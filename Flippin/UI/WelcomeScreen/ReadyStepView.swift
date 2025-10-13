//
//  ReadyStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

extension WelcomeSheet {
    struct ReadyStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
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
                        // Success icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)

                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                        VStack(spacing: 16) {
                            Text(Loc.WelcomeScreen.readyToStart)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                            Text(Loc.WelcomeScreen.readyToStartDesc)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }

                    Spacer()

                    // Final features preview
                    VStack(spacing: 16) {
                        FinalFeatureRow(
                            icon: "plus.circle.fill",
                            text: Loc.WelcomeScreen.finalFeatureAdd,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        FinalFeatureRow(
                            icon: "play.circle.fill",
                            text: Loc.WelcomeScreen.finalFeaturePractice,
                            animateContent: animateContent,
                            delay: 0.9
                        )

                        FinalFeatureRow(
                            icon: "chart.line.uptrend.xyaxis.circle.fill",
                            text: Loc.WelcomeScreen.finalFeatureProgress,
                            animateContent: animateContent,
                            delay: 1.1
                        )

                        FinalFeatureRow(
                            icon: "brain.head.profile",
                            text: Loc.WelcomeScreen.finalFeatureModes,
                            animateContent: animateContent,
                            delay: 1.3
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Final button
                    ActionButton(
                        Loc.WelcomeScreen.getStarted,
                        style: .borderedProminent
                    ) {
                        HapticService.shared.buttonTapped()
                        profileService.completeOnboarding()
                        onContinue()
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
