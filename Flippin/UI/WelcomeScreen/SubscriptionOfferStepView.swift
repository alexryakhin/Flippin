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
        @State private var showsBottomButton: Bool = true

        let onContinue: () -> Void
        
        var body: some View {
            ZStack {
                AnimatedBackground()
                    .ignoresSafeArea()

                SubscriptionStoreView(groupID: "21731755") {
                    VStack(spacing: 16) {
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
                                Text(Loc.Paywall.trialTitle)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .offset(y: animateContent ? 0 : 20)
                                    .opacity(animateContent ? 1 : 0)

                                Text(Loc.Paywall.trialSubtitle)
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
                    }
                }
                .subscriptionStoreControlStyle(.prominentPicker)
                .subscriptionStoreButtonLabel(.action)
                .storeButton(.hidden, for: .cancellation)
                .storeButton(.visible, for: .restorePurchases)
                .storeButton(.visible, for: .policies)
            .subscriptionStorePolicyDestination(
                url: URL(string: PrivateConstants.termsOfServiceURL)!,
                for: .termsOfService
            )
            .subscriptionStorePolicyDestination(
                url: URL(string: PrivateConstants.privacyPolicyURL)!,
                for: .privacyPolicy
            )
                .onInAppPurchaseCompletion { product, result in
                    handlePurchaseResult(product: product, result: result)
                }
                .scaleEffect(animateContent ? 1 : 0.95)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5).delay(1.3), value: animateContent)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(
                        "Skip",
                        destination: ReadyStepView(onContinue: onContinue)
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticService.shared.buttonTapped()
                    })
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
                FeatureItem(icon: "sparkles", title: Loc.PremiumFeatures.aiCollectionGenerator),
                FeatureItem(icon: "brain.head.profile", title: Loc.PremiumFeatures.aiLearningCoach),
                FeatureItem(icon: "infinity", title: Loc.PremiumFeatures.unlimitedCardsTitle),
                FeatureItem(icon: "waveform", title: Loc.PremiumFeatures.premiumVoices),
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

