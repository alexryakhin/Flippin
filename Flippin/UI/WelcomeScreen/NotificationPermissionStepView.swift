//
//  NotificationPermissionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct NotificationPermissionStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var notificationService = NotificationService.shared
        @StateObject private var purchaseService = PurchaseService.shared
        @State private var animateContent = false
        @State private var isRequestingPermission = false
        @State private var hasRequestedPermission = false
        
        let onContinue: () -> Void
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(animateContent ? 1 : 0.5)
                            .opacity(animateContent ? 1 : 0)

                        Image(systemName: "bell.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    VStack(spacing: 16) {
                        Text(Loc.UserProfile.notificationTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)

                        Text(Loc.UserProfile.notificationSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)

                    VStack(spacing: 16) {
                        NotificationFeatureRow(
                            icon: "calendar.badge.clock",
                            text: Loc.UserProfile.notificationFeature1,
                            animateContent: animateContent,
                            delay: 0.7
                        )

                        NotificationFeatureRow(
                            icon: "brain.head.profile",
                            text: Loc.UserProfile.notificationFeature2,
                            animateContent: animateContent,
                            delay: 0.9
                        )

                        NotificationFeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            text: Loc.UserProfile.notificationFeature3,
                            animateContent: animateContent,
                            delay: 1.1
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .background {
                AnimatedBackground()
                    .ignoresSafeArea()
            }
            .safeAreaBarIfAvailable {
                VStack(spacing: 12) {
                    if !hasRequestedPermission {
                        ActionButton(
                            Loc.UserProfile.enableNotifications,
                            style: .borderedProminent,
                            isLoading: isRequestingPermission
                        ) {
                            requestPermission()
                        }
                        .disabled(isRequestingPermission)
                    } else {
                        // Check if user already has premium access
                        if purchaseService.hasPremiumAccess {
                            NavigationLink(
                                destination: ReadyStepView(onContinue: onContinue),
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
                        } else {
                            NavigationLink(
                                destination: SubscriptionOfferStepView(onContinue: onContinue),
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
                    }
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .onAppear {
                hasRequestedPermission = notificationService.hasNotificationPermission
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func requestPermission() {
            isRequestingPermission = true
            Task {
                let granted = await notificationService.requestNotificationPermission()
                await MainActor.run {
                    isRequestingPermission = false
                    hasRequestedPermission = true
                    HapticService.shared.buttonTapped()
                    
                    if granted {
                        // Enable both notification options when permission is granted during onboarding
                        notificationService.enableAllNotificationsForOnboarding()
                        AnalyticsService.trackEvent(.notificationPermissionGranted)
                    }
                }
            }
        }
    }
    
    // MARK: - Notification Feature Row
    
    struct NotificationFeatureRow: View {
        @StateObject private var colorManager: ColorManager = .shared

        let icon: String
        let text: String
        let animateContent: Bool
        let delay: Double
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(colorManager.tintColor)
                    .frame(width: 40)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
                
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
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

