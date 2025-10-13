//
//  SubscriptionOfferStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI
import RevenueCat

extension WelcomeSheet {
    struct SubscriptionOfferStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var purchaseService = PurchaseService.shared
        @State private var animateContent = false
        @State private var selectedPackage: Package?
        @State private var showingRestoreAlert = false
        @State private var restoreMessage = ""

        let onContinue: () -> Void
        
        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with crown icon
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
                                .foregroundStyle(.white)
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
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }
                    .padding(.top, 20)

                    // Features list
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

                    // Subscription packages
                    if let offering = purchaseService.offerings {
                        VStack(spacing: 12) {
                            ForEach(offering.availablePackages, id: \.identifier) { package in
                                Paywall.PackageSelectionView(
                                    package: package,
                                    isSelected: selectedPackage?.identifier == package.identifier,
                                    tintColor: colorManager.tintColor
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPackage = package
                                        HapticService.shared.buttonTapped()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .scaleEffect(animateContent ? 1 : 0.95)
                        .opacity(animateContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(1.3), value: animateContent)
                    }
                }
                .padding(.vertical, 12)
                .multilineTextAlignment(.center)
            }
            .background {
                AnimatedBackground()
                    .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                VStack(spacing: 12) {
                    var price: String? {
                        guard let selectedPackage else { return nil }
                        switch selectedPackage.storeProduct.subscriptionPeriod?.unit {
                        case .day:
                            return selectedPackage.storeProduct.localizedPricePerDay
                        case .week:
                            return selectedPackage.storeProduct.localizedPricePerWeek
                        case .month:
                            return selectedPackage.storeProduct.localizedPricePerMonth
                        case .year:
                            return selectedPackage.storeProduct.localizedPricePerYear
                        case nil:
                            return nil
                        }
                    }
                    if let price, let unit = selectedPackage?.storeProduct.subscriptionPeriod?.unit {
                        Text(String(format: Loc.Paywall.planAutoRenews, price, "\(unit)"))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Subscribe button
                    ActionButton(
                        Loc.Paywall.subscribe,
                        style: .borderedProminent,
                        isLoading: purchaseService.isPurchasing
                    ) {
                        purchaseSelectedPackage()
                    }
                    .disabled(selectedPackage == nil || purchaseService.isPurchasing)

                    // Restore button
                    ActionButton(
                        Loc.Paywall.restoreSubscription,
                        style: .bordered
                    ) {
                        restorePurchases()
                    }
                }
                .padding(vertical: 12, horizontal: 16)
                .background(.ultraThinMaterial)
            }
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(
                        Loc.Paywall.skip,
                        destination: ReadyStepView(onContinue: onContinue)
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        HapticService.shared.buttonTapped()
                    })
                }
            }
            .alert(Loc.Paywall.restoreSubscription, isPresented: $showingRestoreAlert) {
                Button(Loc.Paywall.ok, role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
            .task {
                await purchaseService.loadOfferings()
                // Pre-select the first package (usually yearly)
                if let offering = purchaseService.offerings {
                    selectedPackage = offering.availablePackages.first
                }
            }
            .onAppear {
                AnalyticsService.trackEvent(.paywallOpened)
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
        }
        
        private func purchaseSelectedPackage() {
            guard let package = selectedPackage else { return }
            
            Task {
                let result = await purchaseService.purchasePackage(package)
                if result.success {
                    HapticService.shared.success()
                    AnalyticsService.trackEvent(.subscriptionPurchased)
                    // Don't dismiss, let user continue through onboarding
                } else if let error = result.error {
                    // Show error if needed
                    print("Purchase error: \(error)")
                }
            }
        }
        
        private func restorePurchases() {
            Task {
                let success = await purchaseService.restorePurchases()
                await MainActor.run {
                    if success {
                        HapticService.shared.success()
                        restoreMessage = Loc.Paywall.restoreSuccessMessage
                        showingRestoreAlert = true
                    } else {
                        restoreMessage = Loc.Paywall.restoreFailureMessage
                        showingRestoreAlert = true
                    }
                }
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
        @StateObject private var colorManager: ColorManager = .shared

        let icon: String
        let title: String
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
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
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

