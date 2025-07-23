import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared
    
    @State private var isPurchasing = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    private let currentCardCount: Int
    private let cardLimit: Int
    
    init(currentCardCount: Int, cardLimit: Int) {
        self.currentCardCount = currentCardCount
        self.cardLimit = cardLimit
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                featuresSection
                subscriptionSection
                footerSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(WelcomeSheet.AnimatedBackground().ignoresSafeArea())
        .navigationBarHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            Task {
                await purchaseService.loadProducts()
            }
        }
    }
    
    // MARK: - Header Section
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Main title
            VStack(spacing: 12) {
                Text("Unlock Premium")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Take your language learning to the next level")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            // Card limit indicator
            VStack(spacing: 8) {
                Text("You've used \(currentCardCount) of \(cardLimit) free cards")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                ProgressView(value: Double(currentCardCount), total: Double(cardLimit))
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(height: 6)
            }
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Features Section
    @ViewBuilder
    private var featuresSection: some View {
        VStack(spacing: 20) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "infinity",
                    title: "Unlimited Cards",
                    description: "Create as many flashcards as you want"
                )
                
                FeatureRow(
                    icon: "folder.fill",
                    title: "50+ Collections",
                    description: "Access all preset vocabulary collections"
                )
                
                FeatureRow(
                    icon: "sparkles",
                    title: "Premium Backgrounds",
                    description: "Beautiful animated backgrounds"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Progress Analytics",
                    description: "Track your learning progress"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Export & Backup",
                    description: "Backup and share your cards"
                )
            }
        }
    }
    
    // MARK: - Subscription Section with Native StoreKit Views
    @ViewBuilder
    private var subscriptionSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Plan")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Native StoreKit Subscription Store View
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
                            alertTitle = "Purchase Failed"
                            alertMessage = error.localizedDescription
                            showingAlert = true
                        }
                    }
            } else {
                // Fallback for older iOS versions (shouldn't happen since app targets iOS 17+)
                Text("Subscription Store requires iOS 17+")
                    .foregroundColor(.white)
            }
            
            Button("Restore Purchases") {
                Task {
                    await restorePurchases()
                }
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Footer Section
    @ViewBuilder
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("Cancel anytime • No commitment")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Actions
    private func handlePurchaseResult(product: Product, result: Result<Void, Error>) {
        switch result {
        case .success:
            dismiss()
        case .failure(let error):
            alertTitle = "Purchase Failed"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
    
    private func restorePurchases() async {
        let success = await purchaseService.restorePurchases()
        
        if success {
            dismiss()
        } else {
            alertTitle = "Restore Failed"
            alertMessage = "No purchases found to restore"
            showingAlert = true
        }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    @StateObject private var colorManager = ColorManager.shared

    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(colorManager.tintColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview
#Preview {
    PaywallView(currentCardCount: 8, cardLimit: 10)
} 
