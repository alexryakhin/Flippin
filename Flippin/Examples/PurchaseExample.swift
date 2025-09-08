import Foundation
import StoreKit

// MARK: - Purchase Example Usage
final class PurchaseExample {

    // MARK: - Example 1: Simple Test Purchase
    static func performSimpleTestPurchase() async {
        print("🧪 Starting simple test purchase...")
        
        let purchaseService = PurchaseService.shared
        let result = await purchaseService.performTestPurchase()
        
        if result.success {
            print("✅ Test purchase successful!")
            print("📋 Transaction ID: \(result.transactionId ?? "Unknown")")
            print("🛍️ Product ID: \(result.productId)")
        } else {
            print("❌ Test purchase failed: \(result.error ?? "Unknown error")")
        }
    }
    
    // MARK: - Example 2: Purchase Specific Product
    static func purchaseSpecificProduct(productId: String) async {
        print("🛒 Purchasing product: \(productId)")
        
        let purchaseService = PurchaseService.shared
        let result = await purchaseService.purchaseProduct(productId)
        
        if result.success {
            print("✅ Purchase successful!")
            print("📋 Transaction ID: \(result.transactionId ?? "Unknown")")
            
            // Store transaction ID for later use
            UserDefaults.standard.set(result.transactionId, forKey: "last_transaction_id")
        } else {
            print("❌ Purchase failed: \(result.error ?? "Unknown error")")
        }
    }
    
    // MARK: - Example 3: Get Transaction History
    static func getTransactionHistory() async {
        print("📜 Getting transaction history...")
        
        let purchaseService = PurchaseService.shared
        let transactions = await purchaseService.getTransactionHistory()
        
        print("📊 Found \(transactions.count) transactions:")
        
        for (index, transaction) in transactions.enumerated() {
            print("  \(index + 1). ID: \(transaction.id.description)")
            print("     Product: \(transaction.productID)")
            print("     Date: \(transaction.purchaseDate)")
            print("     ---")
        }
    }
    
    // MARK: - Example 4: Restore Purchases
    static func restorePurchases() async {
        print("🔄 Restoring purchases...")
        
        let purchaseService = PurchaseService.shared
        let success = await purchaseService.restorePurchases()
        
        if success {
            print("✅ Purchases restored successfully")
        } else {
            print("❌ Failed to restore purchases")
        }
    }
    
    // MARK: - Example 5: Complete Purchase Flow
    static func completePurchaseFlow() async {
        print("🚀 Starting complete purchase flow...")
        
        // Step 1: Load products
        let purchaseService = PurchaseService.shared
        await purchaseService.loadProducts()

        let products = purchaseService.products
        print("📦 Loaded \(products.count) products")

        // Step 2: Perform test purchase
        let result = await purchaseService.performTestPurchase()
        
        if result.success {
            print("✅ Purchase completed successfully!")
            print("📋 Transaction ID: \(result.transactionId ?? "Unknown")")
            
            // Step 3: Get transaction history
            let transactions = await purchaseService.getTransactionHistory()
            print("📊 Total transactions: \(transactions.count)")
            
            // Step 4: Store transaction ID
            if let transactionId = result.transactionId {
                UserDefaults.standard.set(transactionId, forKey: "last_transaction_id")
                print("💾 Transaction ID saved to UserDefaults")
            }
            
        } else {
            print("❌ Purchase failed: \(result.error ?? "Unknown error")")
        }
    }
}

// MARK: - Usage Examples
extension PurchaseExample {
    
    /// Example of how to use the purchase system in your app
    static func usageExamples() {
        // Example 1: Simple test purchase
        Task {
            await performSimpleTestPurchase()
        }
        
        // Example 2: Purchase specific product
        Task {
            await purchaseSpecificProduct(productId: "com.dor.flippin.unlimited_cards")
        }
        
        // Example 3: Get transaction history
        Task {
            await getTransactionHistory()
        }
        
        // Example 4: Restore purchases
        Task {
            await restorePurchases()
        }
        
        // Example 5: Complete flow
        Task {
            await completePurchaseFlow()
        }
    }
}

// MARK: - Transaction ID Helper
extension PurchaseExample {
    
    /// Get the last transaction ID from UserDefaults
    static func getLastTransactionId() -> String? {
        return UserDefaults.standard.string(forKey: "last_transaction_id")
    }
    
    /// Clear the stored transaction ID
    static func clearLastTransactionId() {
        UserDefaults.standard.removeObject(forKey: "last_transaction_id")
    }
    
    /// Check if user has made any purchases
    static func hasAnyPurchases() async -> Bool {
        let purchaseService = PurchaseService.shared
        let transactions = await purchaseService.getTransactionHistory()
        return !transactions.isEmpty
    }
    
    /// Check if specific product is purchased
    @MainActor static func isProductPurchased(_ productId: String) -> Bool {
        return PurchaseService.shared.isProductPurchased(productId)
    }
    
    /// Get all purchased product IDs
    @MainActor static func getPurchasedProducts() -> [String] {
        return PurchaseService.shared.getPurchasedProducts()
    }
    
    /// Example of checking purchase status
    @MainActor static func checkPurchaseStatus() {
        let unlimitedCardsId = "com.dor.flippin.unlimited_cards"
        
        if isProductPurchased(unlimitedCardsId) {
            print("✅ Unlimited Cards is purchased")
        } else {
            print("❌ Unlimited Cards is not purchased")
        }
        
        let purchasedProducts = getPurchasedProducts()
        print("📦 Purchased products: \(purchasedProducts)")
    }
} 
