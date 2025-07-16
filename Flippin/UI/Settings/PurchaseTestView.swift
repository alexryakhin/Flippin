import SwiftUI
import StoreKit

typealias SKTransaction = StoreKit.Transaction

struct PurchaseTestView: View {
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var transactionHistory: [SKTransaction] = []

    var body: some View {
        List {
            Section("Test Purchase") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Perform a test purchase to get transaction ID")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: purchaseService.isListeningForUpdates ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(purchaseService.isListeningForUpdates ? .green : .orange)
                        Text(purchaseService.isListeningForUpdates ? "Transaction listener active" : "Transaction listener not active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: performTestPurchase) {
                        HStack {
                            if purchaseService.isPurchasing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "cart.badge.plus")
                            }
                            Text("Start Test Purchase")
                        }
                    }
                    .disabled(purchaseService.isPurchasing || purchaseService.products.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 8)
            }
            
            if let lastTransactionId = purchaseService.lastTransactionId {
                Section("Last Transaction ID") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Transaction ID:")
                            .font(.headline)
                        Text(lastTransactionId)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                        
                        Button("Copy to Clipboard") {
                            UIPasteboard.general.string = lastTransactionId
                            showAlert(title: "Copied!", message: "Transaction ID copied to clipboard")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Available Products") {
                if purchaseService.products.isEmpty {
                    Text("No products available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(purchaseService.products) { product in
                        ProductRowView(
                            product: product,
                            isPurchased: purchaseService.isProductPurchased(product.id)
                        ) {
                            await purchaseSpecificProduct(product.id)
                        }
                    }
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
            
            Section("Transaction History") {
                Button("Load Transaction History") {
                    Task {
                        await loadTransactionHistory()
                    }
                }

                if !transactionHistory.isEmpty {
                    ForEach(transactionHistory, id: \.id) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
            
            Section("Restore Purchases") {
                Button("Restore Purchases") {
                    Task {
                        let success = await purchaseService.restorePurchases()
                        showAlert(
                            title: success ? "Success" : "Failed",
                            message: success ? "Purchases restored successfully" : "Failed to restore purchases"
                        )
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Purchase Testing")
        .navigationBarTitleDisplayMode(.inline)
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
    
    private func performTestPurchase() {
        Task {
            let result = await purchaseService.performTestPurchase()
            showAlert(
                title: result.success ? "Success" : "Failed",
                message: result.success ? 
                    "Test purchase completed! Transaction ID: \(result.transactionId ?? "Unknown")" :
                    "Test purchase failed: \(result.error ?? "Unknown error")"
            )
            
            // Force UI update after purchase
            if result.success {
                // Small delay to ensure transaction is processed
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
        }
    }
    
    private func purchaseSpecificProduct(_ productId: String) async {
        let result = await purchaseService.purchaseProduct(productId)
        showAlert(
            title: result.success ? "Success" : "Failed",
            message: result.success ? 
                "Purchase completed! Transaction ID: \(result.transactionId ?? "Unknown")" :
                "Purchase failed: \(result.error ?? "Unknown error")"
        )
    }
    
    private func loadTransactionHistory() async {
        transactionHistory = await purchaseService.getTransactionHistory()
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ProductRowView: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () async -> Void
    
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(product.displayName)
                            .font(.headline)
                        
                        if isPurchased {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    
                    Text(product.description)
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
                        Text(product.displayPrice)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            if !isPurchased {
                Button {
                    Task {
                        isPurchasing = true
                        await onPurchase()
                        isPurchasing = false
                    }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "cart")
                        }
                        Text("Purchase")
                    }
                }
                .disabled(isPurchasing)
                .buttonStyle(.borderedProminent)
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

struct TransactionRowView: View {
    let transaction: SKTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Transaction ID: \(transaction.id.description)")
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
            
            Text("Product: \(transaction.productID)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Date: \(transaction.purchaseDate.formatted())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        PurchaseTestView()
    }
} 
