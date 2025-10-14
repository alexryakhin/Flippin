import SwiftUI
import RevenueCat

enum Paywall {
    struct ContentView: View {
        @Environment(\.dismiss) var dismiss
        @StateObject private var purchaseService = PurchaseService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var cardsProvider = CardsProvider.shared
        @State private var selectedPackage: Package?
        @State private var showingRestoreAlert = false
        @State private var restoreMessage = ""
        @State private var safariURL: URL?

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        AppIcon.current.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 128, height: 128)

                        Text(Loc.Paywall.unlockPremium)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(Loc.Paywall.masterLanguageLearning)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Progress indicator with gradient
                        VStack(spacing: 10) {
                            Text(
                                Loc.PremiumFeatures.usedCardsOfLimit(
                                    cardsProvider.cards.count,
                                    cardsProvider.cardLimit
                                )
                            )
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)

                            ProgressView(value: Double(cardsProvider.cards.count), total: Double(cardsProvider.cardLimit))
                                .progressViewStyle(.linear)
                                .tint(LinearGradient(
                                    gradient: Gradient(colors: [colorManager.tintColor, colorManager.tintColor.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 8)
                    }

                    // Features with glassmorphism cards
                    VStack(spacing: 12) {
                        Text(Loc.Paywall.whatYouGetWithPremium)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        ForEach(PremiumFeature.paywallFeatures, id: \.self) { feature in
                            FeatureRow(feature: feature)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color(.systemGray5), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                    }

                    // Terms of Service & Privacy Policy
                    HStack(spacing: 4) {
                        Button(Loc.AboutApp.termsOfService) {
                            safariURL = URL(string: PrivateConstants.termsOfServiceURL)
                        }
                        Text(Loc.Paywall.andPreposition)
                            .foregroundStyle(.secondary)
                        Button(Loc.AboutApp.privacyPolicy) {
                            safariURL = URL(string: PrivateConstants.privacyPolicyURL)
                        }
                    }
                    .font(.caption)

                    // Subscription packages
                    if let offering = purchaseService.offerings {
                        VStack(spacing: 12) {
                            ForEach(offering.availablePackages, id: \.identifier) { package in
                                PackageSelectionView(
                                    package: package,
                                    isSelected: selectedPackage?.identifier == package.identifier,
                                    tintColor: colorManager.tintColor
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedPackage = package
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(vertical: 12, horizontal: 16)
                .multilineTextAlignment(.center)
            }
            .background {
                WelcomeSheet.AnimatedBackground()
                    .ignoresSafeArea()
            }
            .safeAreaBarIfAvailable(edge: .top, alignment: .trailing) {
                HeaderButton(icon: "xmark") {
                    AnalyticsService.trackEvent(.paywallClosed)
                    dismiss()
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .safeAreaBarIfAvailable {
                // Text "Plan auto-renews for \(price)/\(period) until cancelled."
                // Two buttons - Subscribe and Restore Subscription
                VStack(spacing: 12) {
                    if let product = selectedPackage?.storeProduct, let price = product.localizedPrice {
                        Text(Loc.Paywall.planAutoRenews(price, product.localizedPeriod))
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
                .materialBackgroundIfNoGlassAvailable()
            }
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .safari(url: $safariURL)
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
            }
        }
        
        private func purchaseSelectedPackage() {
            guard let package = selectedPackage else { return }
            
            Task {
                let result = await purchaseService.purchasePackage(package)
                if result.success {
                    dismiss()
                } else if let error = result.error {
                    // Show error if needed
                    debugPrint("Purchase error: \(error)")
                }
            }
        }
        
        private func restorePurchases() {
            Task {
                let success = await purchaseService.restorePurchases()
                await MainActor.run {
                    if success {
                        restoreMessage = Loc.Paywall.restoreSuccessMessage
                        showingRestoreAlert = true
                        // Dismiss after showing alert
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } else {
                        restoreMessage = Loc.Paywall.restoreFailureMessage
                        showingRestoreAlert = true
                    }
                }
            }
        }
    }

    // MARK: - Feature Row
    struct FeatureRow: View {
        @StateObject private var colorManager = ColorManager.shared

        let feature: PremiumFeature

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(colorManager.tintColor)
                    .frame(width: 40, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(feature.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)

                Spacer()
            }
        }
    }
    
    // MARK: - Package Selection View
    struct PackageSelectionView: View {
        let package: Package
        let isSelected: Bool
        let tintColor: Color
        
        private var isYearly: Bool {
            package.storeProduct.subscriptionPeriod?.unit == .year
        }
        
        private var displayTitle: String {
            if isYearly {
                return Loc.Paywall.annual
            } else {
                return Loc.Paywall.monthly
            }
        }
        
        private var displayPricePerMonth: String? {
            guard let price = package.storeProduct.localizedPricePerMonth else { return nil }
            return "\(price)\(Loc.Paywall.perMonth)"
        }
        
        var body: some View {
            HStack(spacing: 16) {
                // Left side - Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    if let displayPricePerMonth {
                        Text(displayPricePerMonth)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    if isYearly {
                        TagView(
                            title: Loc.Paywall.bestValue,
                            isSelected: true,
                            size: .small
                        )
                    }
                }
                
                Spacer()
                
                // Right side - Price and selection
                VStack(alignment: .trailing, spacing: 4) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    if let subscriptionPeriod = package.storeProduct.subscriptionPeriod {
                        Text(formatSubscriptionPeriod(subscriptionPeriod))
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Selection indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? tintColor : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(tintColor)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? tintColor : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(color: isSelected ? tintColor.opacity(0.2) : .clear, radius: 10, x: 0, y: 5)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        
        private func formatSubscriptionPeriod(_ period: SubscriptionPeriod) -> String {
            let value = period.value
            let unit = period.unit
            
            switch unit {
            case .day:
                return value == 1 ? Loc.Paywall.daily : Loc.Plurals.subscriptionDays(value)
            case .week:
                return value == 1 ? Loc.Paywall.weekly : Loc.Plurals.subscriptionWeeks(value)
            case .month:
                return value == 1 ? Loc.Paywall.monthlyPeriod : Loc.Plurals.subscriptionMonths(value)
            case .year:
                return value == 1 ? Loc.Paywall.yearly : Loc.Plurals.subscriptionYears(value)
            @unknown default:
                return ""
            }
        }
    }
}

#Preview {
    Paywall.ContentView()
}
