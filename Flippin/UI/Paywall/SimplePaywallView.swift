import SwiftUI
import StoreKit

struct SimplePaywallView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared
    
    private let currentCardCount: Int
    private let cardLimit: Int
    
    init(currentCardCount: Int, cardLimit: Int) {
        self.currentCardCount = currentCardCount
        self.cardLimit = cardLimit
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Unlock Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Take your language learning to the next level")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Progress indicator
                        VStack(spacing: 8) {
                            Text("You've used \(currentCardCount) of \(cardLimit) free cards")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: Double(currentCardCount), total: Double(cardLimit))
                                .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                        }
                        .padding(.horizontal, 32)
                    }
                    
                    // Features
                    VStack(spacing: 16) {
                        Text("Premium Features")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        FeatureRow(icon: "infinity", title: "Unlimited Cards", description: "Create as many flashcards as you want")
                        FeatureRow(icon: "folder.fill", title: "50+ Collections", description: "Access all preset vocabulary collections")
                        FeatureRow(icon: "sparkles", title: "Premium Backgrounds", description: "Beautiful animated backgrounds")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Analytics", description: "Track your learning progress")
                        FeatureRow(icon: "square.and.arrow.up", title: "Export & Backup", description: "Backup and share your cards")
                    }
                    
                    // StoreKit Subscription Store View
                    if #available(iOS 17.0, *) {
                        SubscriptionStoreView(groupID: "21731755")
                            .subscriptionStoreControlStyle(.prominentPicker)
                            .subscriptionStorePickerItemBackground(.ultraThinMaterial)
                            .subscriptionStoreControlBackground(.ultraThinMaterial)
                            .onInAppPurchaseCompletion { product, result in
                                switch result {
                                case .success(let purchaseResult):
                                    print("Purchase successful: \(purchaseResult)")
                                    dismiss()
                                case .failure(let error):
                                    print("Purchase failed: \(error)")
                                }
                            }
                    } else {
                        // Fallback for older iOS versions (shouldn't happen since app targets iOS 17+)
                        Text("Subscription Store requires iOS 17+")
                            .foregroundColor(.secondary)
                    }
                    
                    // Restore purchases
                    Button("Restore Purchases") {
                        Task {
                            await restorePurchases()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Cancel anytime • No commitment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Link("Terms", destination: URL(string: "https://example.com/terms")!)
                            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(24)
            }
            .background(WelcomeSheet.AnimatedBackground().ignoresSafeArea())
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await purchaseService.loadProducts()
            }
        }
    }
    
    private func handlePurchaseResult(product: Product, result: Result<Void, Error>) {
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
}

// MARK: - Preview
#Preview {
    SimplePaywallView(currentCardCount: 8, cardLimit: 10)
} 
