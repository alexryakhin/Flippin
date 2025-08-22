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
                                .foregroundColor(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                        VStack(spacing: 16) {
                            Text(LocalizationKeys.Welcome.readyToStart.localized)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                            Text(LocalizationKeys.Welcome.readyToStartDesc.localized)
                                .font(.body)
                                .foregroundColor(.secondary)
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
                            text: LocalizationKeys.Welcome.finalFeatureAdd.localized,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        FinalFeatureRow(
                            icon: "play.circle.fill",
                            text: LocalizationKeys.Welcome.finalFeaturePractice.localized,
                            animateContent: animateContent,
                            delay: 0.9
                        )

                        FinalFeatureRow(
                            icon: "chart.line.uptrend.xyaxis.circle.fill",
                            text: LocalizationKeys.Welcome.finalFeatureProgress.localized,
                            animateContent: animateContent,
                            delay: 1.1
                        )

                        FinalFeatureRow(
                            icon: "brain.head.profile",
                            text: LocalizationKeys.Welcome.finalFeatureModes.localized,
                            animateContent: animateContent,
                            delay: 1.3
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Final button
                    ActionButton(
                        LocalizationKeys.Welcome.getStarted.localized,
                        style: .borderedProminent
                    ) {
                        HapticService.shared.buttonTapped()
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
