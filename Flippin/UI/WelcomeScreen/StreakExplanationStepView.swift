//
//  StreakExplanationStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct StreakExplanationStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @State private var animateContent = false
        @State private var flameScale: CGFloat = 1.0
        
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
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(flameScale)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        VStack(spacing: 16) {
                            Text(Loc.UserProfile.streakTitle)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Text(Loc.UserProfile.streakSubtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        StreakFeatureRow(
                            icon: "calendar.badge.checkmark",
                            text: Loc.UserProfile.streakFeature1,
                            animateContent: animateContent,
                            delay: 0.7
                        )
                        
                        StreakFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            text: Loc.UserProfile.streakFeature2,
                            animateContent: animateContent,
                            delay: 0.9
                        )
                        
                        StreakFeatureRow(
                            icon: "trophy.fill",
                            text: Loc.UserProfile.streakFeature3,
                            animateContent: animateContent,
                            delay: 1.1
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: NotificationPermissionStepView(onContinue: onContinue),
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
                        HapticService.shared.buttonTapped()
                    })
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                    
                    withAnimation(
                        .easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                        .delay(0.5)
                    ) {
                        flameScale = 1.15
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
    }
    
    // MARK: - Streak Feature Row
    
    struct StreakFeatureRow: View {
        let icon: String
        let text: String
        let animateContent: Bool
        let delay: Double
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 40)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Spacer()
            }
            .padding(20)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
        }
    }
}

