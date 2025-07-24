import Foundation
import StoreKit

struct PurchaseResult {
    let success: Bool
    let transactionId: String?
    let error: String?
    let productId: String
}

// MARK: - Purchase Service
@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var lastTransactionId: String?
    @Published var isListeningForUpdates = false
    @Published var purchasedProductIds: Set<String> = []
    @Published var hasPremiumAccess: Bool = false
    
    private var productIds = [
        "com.dor.flippin.premium_monthly",
        "com.dor.flippin.premium_yearly"
    ]
    
    // Cached purchase state for faster loading at app launch
    private var cachedPurchasedProductIds: Set<String> = []
    
    private init() {
        // Load cached purchase state immediately for faster access
        loadCachedPurchaseState()
        
        Task {
            await loadProducts()
            await listenForTransactionUpdates()
            await loadPurchasedProducts()
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
            print("📦 Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase Methods
    func purchaseProduct(_ productId: String) async -> PurchaseResult {
        guard let product = products.first(where: { $0.id == productId }) else {
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: "Product not found",
                productId: productId
            )
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let storeProduct = try await Product.products(for: [productId]).first
            guard let storeProduct = storeProduct else {
                return PurchaseResult(
                    success: false,
                    transactionId: nil,
                    error: "Product not available",
                    productId: productId
                )
            }
            
            let result = try await storeProduct.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                // Note: Transaction will be finished in the updates listener
                // We don't call transaction.finish() here to avoid double-finishing
                
                lastTransactionId = transaction.id.description
                
                // Track purchase analytics
                AnalyticsService.trackEvent(.purchaseCompleted, parameters: [
                    "product_id": productId,
                    "transaction_id": transaction.id.description,
                    "price": product.displayPrice
                ])
                
                // Haptic feedback for successful purchase
                HapticService.shared.purchaseSuccess()
                
                return PurchaseResult(
                    success: true,
                    transactionId: transaction.id.description,
                    error: nil,
                    productId: productId
                )
                
            case .userCancelled:
                return PurchaseResult(
                    success: false,
                    transactionId: nil,
                    error: "Purchase cancelled by user",
                    productId: productId
                )
                
            case .pending:
                return PurchaseResult(
                    success: false,
                    transactionId: nil,
                    error: "Purchase pending approval",
                    productId: productId
                )
                
            @unknown default:
                return PurchaseResult(
                    success: false,
                    transactionId: nil,
                    error: "Unknown purchase result",
                    productId: productId
                )
            }
            
        } catch {
            print("❌ Purchase failed: \(error)")
            AnalyticsService.trackErrorEvent(.purchaseFailed, errorMessage: error.localizedDescription)
            
            // Haptic feedback for failed purchase
            HapticService.shared.purchaseFailed()
            
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: error.localizedDescription,
                productId: productId
            )
        }
    }
    
    // MARK: - Test Purchase
    func performTestPurchase() async -> PurchaseResult {
        // Use the first available product for testing
        guard let firstProduct = products.first else {
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: "No products available for testing",
                productId: "test"
            )
        }
        
        print("🧪 Starting test purchase for: \(firstProduct.id)")
        
        // Wait a bit for the transaction to be processed by the updates listener
        let result = await purchaseProduct(firstProduct.id)
        
        if result.success {
            // Give the transaction updates listener time to process
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        return result
    }
    
    // MARK: - Transaction Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction History
    func getTransactionHistory() async -> [Transaction] {
        var transactions: [Transaction] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                transactions.append(transaction)
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        return transactions
    }
    
    // MARK: - Transaction Updates Listener
    private func listenForTransactionUpdates() async {
        print("🔔 Starting transaction updates listener...")
        isListeningForUpdates = true
        
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                
                // Update last transaction ID
                lastTransactionId = transaction.id.description
                
                // Add to purchased products
                await addToPurchasedProducts(transaction.productID)
                
                // Track transaction update
                AnalyticsService.trackEvent(.transactionUpdated, parameters: [
                    "transaction_id": transaction.id.description,
                    "product_id": transaction.productID,
                    "purchase_date": transaction.purchaseDate.description
                ])
                
                print("📋 Transaction update received: \(transaction.id.description)")
                print("🛍️ Product: \(transaction.productID)")
                print("✅ Added to purchased products")
                
                // Finish the transaction
                await transaction.finish()
                
            } catch {
                print("❌ Failed to verify transaction update: \(error)")
                AnalyticsService.trackErrorEvent(.transactionVerificationFailed, errorMessage: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Purchased Products Management
    private func loadPurchasedProducts() async {
        print("📦 Loading purchased products...")
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                await addToPurchasedProducts(transaction.productID)
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        // Save the final state after loading from StoreKit
        await MainActor.run {
            saveCachedPurchaseState()
        }
        
        print("✅ Loaded \(purchasedProductIds.count) purchased products")
    }
    
    private func addToPurchasedProducts(_ productId: String) async {
        await MainActor.run {
            purchasedProductIds.insert(productId)
            updatePremiumAccessStatus()
            saveCachedPurchaseState()
            print("✅ Added \(productId) to purchased products")
        }
    }
    
    func isProductPurchased(_ productId: String) -> Bool {
        return purchasedProductIds.contains(productId)
    }
    
    func getPurchasedProducts() -> [String] {
        return Array(purchasedProductIds)
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            await loadPurchasedProducts() // Reload purchased products after sync
            print("✅ Purchases restored successfully")
            return true
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            return false
        }
    }
    
    // MARK: - Cached Purchase State Management
    private func loadCachedPurchaseState() {
        if let cachedIds = UserDefaults.standard.array(forKey: UserDefaultsKey.cachedPurchasedProducts) as? [String] {
            cachedPurchasedProductIds = Set(cachedIds)
            purchasedProductIds = cachedPurchasedProductIds
            updatePremiumAccessStatus()
            print("📦 Loaded cached purchase state: \(cachedPurchasedProductIds)")
        }
    }
    
    private func saveCachedPurchaseState() {
        let idsArray = Array(purchasedProductIds)
        UserDefaults.standard.set(idsArray, forKey: UserDefaultsKey.cachedPurchasedProducts)
        print("💾 Saved cached purchase state: \(purchasedProductIds)")
    }
    
    // MARK: - Public Purchase Status Management
    func reloadPurchaseStatus() async {
        print("🔄 Reloading purchase status...")
        await loadPurchasedProducts()
        print("✅ Purchase status reloaded")
    }
    
    // MARK: - Premium Access Helper
    /// Updates the premium access status based on current purchased products
    private func updatePremiumAccessStatus() {
        hasPremiumAccess = isProductPurchased("com.dor.flippin.premium_monthly") ||
                          isProductPurchased("com.dor.flippin.premium_yearly")
    }
}

// MARK: - Purchase Errors
enum PurchaseError: Error, LocalizedError {
    case verificationFailed
    case productNotFound
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}
