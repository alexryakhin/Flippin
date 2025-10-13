//
//  WelcomeStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

extension WelcomeSheet {
    struct WelcomeStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @State private var animateContent = false

        let onContinue: () -> Void

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                    // App icon and title
                    VStack(spacing: 24) {
                        // Animated app icon
                        Image(.iconRounded)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 144, height: 144)
                            .foregroundStyle(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                        VStack(spacing: 16) {
                            Text(Loc.WelcomeScreen.welcomeScreenTitle)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)

                            Text(Loc.WelcomeScreen.welcomeScreenMessage)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }

                    // Feature highlights
                    VStack(spacing: 20) {
                        FeatureRow(
                            icon: "translate",
                            title: Loc.WelcomeScreen.featureLearning,
                            description: Loc.WelcomeScreen.featureLearningDesc,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        FeatureRow(
                            icon: "globe",
                            title: Loc.WelcomeScreen.featureLanguages,
                            description: Loc.WelcomeScreen.featureLanguagesDesc,
                            animateContent: animateContent,
                            delay: 0.9
                        )

                        FeatureRow(
                            icon: "speaker.wave.2.bubble.fill",
                            title: Loc.WelcomeScreen.featureSmart,
                            description: Loc.WelcomeScreen.featureSmartDesc,
                            animateContent: animateContent,
                            delay: 1.1
                        )

                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: Loc.WelcomeScreen.featureAnalytics,
                            description: Loc.WelcomeScreen.featureAnalyticsDesc,
                            animateContent: animateContent,
                            delay: 1.3
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                NavigationLink(destination: NameInputStepView(onContinue: onContinue)) {
                    ActionButton(
                        Loc.WelcomeScreen.continueButton,
                        style: .borderedProminent,
                        action: {}
                    )
                    .allowsHitTesting(false)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    HapticService.shared.buttonTapped()
                })
                .padding(vertical: 12, horizontal: 16)
            }
            .background {
                AnimatedBackground()
                    .ignoresSafeArea()
            }
        }
    }
}
