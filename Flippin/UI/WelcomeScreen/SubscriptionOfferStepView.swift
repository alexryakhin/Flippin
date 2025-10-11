//
//  SubscriptionOfferStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI
import StoreKit

extension WelcomeSheet {
    struct SubscriptionOfferStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared
        @State private var animateContent = false
        
        let onContinue: () -> Void
        
        var body: some View {
            ZStack {
                AnimatedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 20)
                        
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow, .orange],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .scaleEffect(animateContent ? 1 : 0.5)
                                    .opacity(animateContent ? 1 : 0)
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                                    .scaleEffect(animateContent ? 1 : 0.8)
                                    .opacity(animateContent ? 1 : 0)
                            }
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                            
                            VStack(spacing: 16) {
                                Text(Loc.UserProfile.trialTitle)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .offset(y: animateContent ? 0 : 20)
                                    .opacity(animateContent ? 1 : 0)
                                
                                Text(Loc.UserProfile.trialSubtitle)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .offset(y: animateContent ? 0 : 20)
                                    .opacity(animateContent ? 1 : 0)
                            }
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(Array(features.enumerated()), id: \.element.title) { index, feature in
                                TrialFeatureRow(
                                    icon: feature.icon,
                                    title: feature.title,
                                    animateContent: animateContent,
                                    delay: 0.7 + Double(index) * 0.1
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        SubscriptionStoreView(groupID: "21731755")
                            .subscriptionStoreControlStyle(.prominentPicker)
                            .subscriptionStoreButtonLabel(.action)
                            .onInAppPurchaseCompletion { product, result in
                                handlePurchaseResult(product: product, result: result)
                            }
                            .scaleEffect(animateContent ? 1 : 0.95)
                            .opacity(animateContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(1.3), value: animateContent)
                        
                        Button {
                            Task {
                                await restorePurchases()
                            }
                        } label: {
                            Text(Loc.PremiumFeatures.restorePurchases)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        
                        VStack(spacing: 8) {
                            Text(Loc.PremiumFeatures.cancelAnytime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 16) {
                                Link(
                                    Loc.AboutApp.termsOfService,
                                    destination: URL(string: "https://www.flippin.app/terms-of-use")!
                                )
                                
                                Link(
                                    Loc.AboutApp.privacyPolicy,
                                    destination: URL(string: "https://www.flippin.app/privacy-policy")!
                                )
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                
                VStack {
                    Spacer()
                    
                    NavigationLink(
                        destination: ReadyStepView(onContinue: onContinue),
                        label: {
                            Text(Loc.UserProfile.skipTrial)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticService.shared.buttonTapped()
                    })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
            }
            .navigationBarBackButtonHidden(false)
            .onAppear {
                AnalyticsService.trackEvent(.paywallOpened)
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
                Task {
                    await purchaseService.loadProducts()
                }
            }
        }
        
        private func handlePurchaseResult(product: Product, result: Result<Product.PurchaseResult, Error>) {
            switch result {
            case .success:
                HapticService.shared.success()
                AnalyticsService.trackEvent(.subscriptionPurchased)
            case .failure(let error):
                print("Purchase failed: \(error.localizedDescription)")
            }
        }
        
        private func restorePurchases() async {
            let success = await purchaseService.restorePurchases()
            if success {
                HapticService.shared.success()
            }
        }
        
        private var features: [FeatureItem] {
            [
                FeatureItem(icon: "sparkles", title: "AI Collection Generator"),
                FeatureItem(icon: "brain.head.profile", title: "AI Learning Coach"),
                FeatureItem(icon: "infinity", title: Loc.CardLimits.unlimitedCards),
                FeatureItem(icon: "waveform", title: "Premium Voices"),
                FeatureItem(icon: "folder.fill", title: Loc.PremiumFeatures.collections)
            ]
        }
    }
    
    // MARK: - Feature Item Model
    
    struct FeatureItem {
        let icon: String
        let title: String
    }
    
    // MARK: - Trial Feature Row
    
    struct TrialFeatureRow: View {
        let icon: String
        let title: String
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
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
            }
            .padding(20)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
        }
    }
}

