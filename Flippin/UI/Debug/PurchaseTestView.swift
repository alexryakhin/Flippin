import SwiftUI
import RevenueCat

#if DEBUG
struct PurchaseTestView: View {
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var customerInfo: CustomerInfo?

    var body: some View {
        List {
            Section("Test Purchase") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Perform a test purchase using RevenueCat")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: purchaseService.hasPremiumAccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(purchaseService.hasPremiumAccess ? .green : .red)
                        Text(purchaseService.hasPremiumAccess ? "Premium Access Active" : "No Premium Access")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ActionButton(
                        "Start Test Purchase",
                        systemImage: "cart.badge.plus",
                        style: .borderedProminent,
                        isLoading: purchaseService.isPurchasing
                    ) {
                        HapticService.shared.buttonTapped()
                        AnalyticsService.trackEvent(.purchaseTestOpened)
                        performTestPurchase()
                    }
                    .disabled(purchaseService.isPurchasing || purchaseService.products.isEmpty)
                }
                .padding(.vertical, 8)
            }
            
            Section("Available Packages") {
                if let offering = purchaseService.offerings {
                    ForEach(offering.availablePackages, id: \.identifier) { package in
                        PackageRowView(
                            package: package,
                            isPurchased: purchaseService.isProductPurchased(package.storeProduct.productIdentifier)
                        ) {
                            await purchaseSpecificPackage(package)
                        }
                    }
                } else {
                    Text("No packages available")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Purchased Products") {
                let purchasedProducts = purchaseService.getPurchasedProducts()
                if purchasedProducts.isEmpty {
                    Text("No products purchased yet")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(purchasedProducts, id: \.self) { productId in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(productId)
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            Section("Customer Info") {
                Button("Load Customer Info") {
                    Task {
                        await loadCustomerInfo()
                    }
                }

                if let info = customerInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("User ID:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(info.originalAppUserId)
                                .font(.system(.caption, design: .monospaced))
                                .textSelection(.enabled)
                        }
                        
                        HStack {
                            Text("Active Subscriptions:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(info.activeSubscriptions.count)")
                                .font(.caption)
                        }
                        
                        if let entitlement = info.entitlements["premium"] {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Premium Entitlement:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(entitlement.isActive ? "Active" : "Inactive")
                                        .font(.caption)
                                        .foregroundColor(entitlement.isActive ? .green : .red)
                                }
                                
                                if let expirationDate = entitlement.expirationDate {
                                    Text("Expires: \(expirationDate.formatted())")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Restore Purchases") {
                Button("Restore Purchases") {
                    Task {
                        let success = await purchaseService.restorePurchases()
                        showAlert(
                            title: success ? "Success" : "No Purchases Found",
                            message: success ? "Your purchases have been restored!" : "No purchases found to restore"
                        )
                    }
                }
            }
            
            Section("Debug Actions") {
                Button("Reload Offerings") {
                    Task {
                        await purchaseService.loadOfferings()
                        showAlert(title: "Reloaded", message: "Offerings have been reloaded from RevenueCat")
                    }
                }
                
                Button("Refresh Customer Info") {
                    Task {
                        await purchaseService.refreshCustomerInfo()
                        await loadCustomerInfo()
                        showAlert(title: "Refreshed", message: "Customer info has been refreshed")
                    }
                }
            }
        }
        .groupedBackground()
        .navigationTitle("Purchase Testing")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            Task {
                await purchaseService.loadOfferings()
                await loadCustomerInfo()
            }
        }
    }
    
    private func performTestPurchase() {
        Task {
            let result = await purchaseService.performTestPurchase()
            showAlert(
                title: result.success ? "Success" : "Failed",
                message: result.success ? 
                    "Test purchase completed! Product: \(result.productId)" :
                    "Test purchase failed: \(result.error ?? "Unknown error")"
            )
            
            if result.success {
                await loadCustomerInfo()
            }
        }
    }
    
    private func purchaseSpecificPackage(_ package: Package) async {
        let result = await purchaseService.purchasePackage(package)
        showAlert(
            title: result.success ? "Success" : "Failed",
            message: result.success ? 
                "Purchase completed! Product: \(result.productId)" :
                "Purchase failed: \(result.error ?? "Unknown error")"
        )
        
        if result.success {
            await loadCustomerInfo()
        }
    }
    
    private func loadCustomerInfo() async {
        await purchaseService.refreshCustomerInfo()
        customerInfo = purchaseService.customerInfo
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct PackageRowView: View {
    let package: Package
    let isPurchased: Bool
    let onPurchase: () async -> Void
    
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                            .font(.headline)
                        
                        if isPurchased {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(package.storeProduct.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if isPurchased {
                        Text("Purchased")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            if !isPurchased {
                ActionButton(
                    "Purchase",
                    systemImage: "cart",
                    style: .borderedProminent,
                    isLoading: isPurchasing
                ) {
                    Task {
                        isPurchasing = true
                        await onPurchase()
                        isPurchasing = false
                    }
                }
                .disabled(isPurchasing)
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Already Purchased")
                        .foregroundColor(.green)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
