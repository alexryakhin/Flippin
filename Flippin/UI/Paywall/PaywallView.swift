import SwiftUI
import StoreKit

enum Paywall {
    struct ContentView: View {
        @Environment(\.dismiss) var dismiss
        @StateObject private var purchaseService = PurchaseService.shared
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var cardsProvider = CardsProvider.shared
        @State private var isAnimating = false

        var body: some View {
            SubscriptionStoreView(groupID: "21731755") {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Image(.iconRounded)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 144, height: 144)

                        Text(Loc.PremiumFeatures.unlockPremium)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .scaleEffect(isAnimating ? 1.0 : 0.95)
                            .animation(.easeOut(duration: 0.6), value: isAnimating)

                        Text(Loc.PremiumFeatures.masterLanguageLearning)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
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
                            .foregroundColor(.secondary)

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
                    .padding(.top, 60)

                    // Features with glassmorphism cards
                    VStack(spacing: 12) {
                        Text(Loc.PremiumFeatures.whatYouGetWithPremium)
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        ForEach(features, id: \.title) { feature in
                            FeatureRow(
                                icon: feature.icon,
                                title: feature.title,
                                description: feature.description
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color(.systemGray5), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .scaleEffect(isAnimating ? 1.0 : 0.98)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(features.firstIndex(where: { $0.title == feature.title }) ?? 0) * 0.1), value: isAnimating)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            }
            .subscriptionStoreControlStyle(.prominentPicker)
            .subscriptionStoreButtonLabel(.action)
            .storeButton(.visible, for: .restorePurchases)
            .storeButton(.visible, for: .policies)
            .subscriptionStorePolicyDestination(
                url: URL(string: "https://www.flippin.app/terms-of-use")!,
                for: .termsOfService
            )
            .subscriptionStorePolicyDestination(
                url: URL(string: "https://www.flippin.app/privacy-policy")!,
                for: .privacyPolicy
            )
            .onInAppPurchaseCompletion { product, result in
                handlePurchaseResult(product: product, result: result)
            }
            .background(
                WelcomeSheet.AnimatedBackground()
                    .ignoresSafeArea()
            )
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .onAppear {
                AnalyticsService.trackEvent(.paywallOpened)
                isAnimating = true
                Task {
                    await purchaseService.loadProducts()
                }
            }
        }

        private func handlePurchaseResult(product: Product, result: Result<Product.PurchaseResult, Error>) {
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                print("Purchase failed: \(error.localizedDescription)")
            }
        }

        private func restorePurchases() async {
            let success = await purchaseService.restorePurchases()
            if success {
                dismiss()
            }
        }

        // Feature data
        private var features: [FeatureModel] {
            [
                FeatureModel(
                    icon: "sparkles",
                    title: "AI Collection Generator",
                    description: "Create custom flashcard collections with AI"
                ),
                FeatureModel(
                    icon: "brain.head.profile",
                    title: "AI Learning Coach",
                    description: "Get personalized insights and recommendations"
                ),
                FeatureModel(
                    icon: "infinity",
                    title: Loc.CardLimits.unlimitedCards,
                    description: Loc.PremiumFeatures.unlimitedCardsDescription
                ),
                FeatureModel(
                    icon: "waveform",
                    title: "Speechify Premium Voices",
                    description: "Thousands of high-quality voices to personalize your cards"
                ),
                FeatureModel(
                    icon: "folder.fill",
                    title: Loc.PremiumFeatures.collections,
                    description: Loc.PremiumFeatures.collectionsDescription
                ),
                FeatureModel(
                    icon: "sparkles",
                    title: Loc.PremiumFeatures.premiumBackgrounds,
                    description: Loc.PremiumFeatures.premiumBackgroundsDescription
                ),
                FeatureModel(
                    icon: "globe",
                    title: Loc.PremiumFeatures.multipleLanguagesTitle,
                    description: Loc.PremiumFeatures.multipleLanguagesDescription
                ),
                FeatureModel(
                    icon: "chart.line.uptrend.xyaxis",
                    title: Loc.Paywall.advancedAnalyticsTitle,
                    description: Loc.Paywall.advancedAnalyticsMessage
                )
            ]
        }
    }

    // MARK: - Feature Model
    struct FeatureModel: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
    }

    // MARK: - Feature Row
    struct FeatureRow: View {
        let icon: String
        let title: String
        let description: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 40, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.leading)

                Spacer()
            }
        }
    }
}

#Preview {
    Paywall.ContentView()
}
