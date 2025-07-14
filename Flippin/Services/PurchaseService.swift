import Foundation
import StoreKit

// MARK: - Purchase Models
struct Product: Identifiable {
    let id: String
    let displayName: String
    let description: String
    let price: Decimal
    let priceString: String
    let type: ProductType
    
    enum ProductType {
        case consumable
        case nonConsumable
        case autoRenewable
        case nonRenewable
    }
}

struct PurchaseResult {
    let success: Bool
    let transactionId: String?
    let error: String?
    let productId: String
}

// MARK: - Purchase Service
@MainActor
class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var lastTransactionId: String?
    @Published var isListeningForUpdates = false
    
    private var productIds = [
        "com.dor.flippin.premium_monthly",
        "com.dor.flippin.premium_yearly",
        "com.dor.flippin.unlimited_cards"
    ]
    
    private init() {
        Task {
            await loadProducts()
            await listenForTransactionUpdates()
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async {
        do {
            let storeProducts = try await SKProduct.products(for: productIds)
            products = storeProducts.map { storeProduct in
                Product(
                    id: storeProduct.id,
                    displayName: storeProduct.displayName,
                    description: storeProduct.description,
                    price: storeProduct.price,
                    priceString: storeProduct.displayPrice,
                    type: determineProductType(storeProduct)
                )
            }
            print("📦 Loaded \(products.count) products")
        } catch {
            print("❌ Failed to load products: \(error)")
        }
    }
    
    private func determineProductType(_ storeProduct: SKProduct) -> Product.ProductType {
        switch storeProduct.type {
        case .consumable:
            return .consumable
        case .nonConsumable:
            return .nonConsumable
        case .autoRenewable:
            return .autoRenewable
        case .nonRenewable:
            return .nonRenewable
        default:
            return .nonConsumable
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
            let storeProduct = try await SKProduct.products(for: [productId]).first
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
                    "price": product.priceString
                ])
                
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
                
                // Track transaction update
                AnalyticsService.trackEvent(.transactionUpdated, parameters: [
                    "transaction_id": transaction.id.description,
                    "product_id": transaction.productID,
                    "purchase_date": transaction.purchaseDate.description
                ])
                
                print("📋 Transaction update received: \(transaction.id.description)")
                print("🛍️ Product: \(transaction.productID)")
                
                // Finish the transaction
                await transaction.finish()
                
            } catch {
                print("❌ Failed to verify transaction update: \(error)")
                AnalyticsService.trackErrorEvent(.transactionVerificationFailed, errorMessage: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
            print("✅ Purchases restored successfully")
            return true
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            return false
        }
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

// MARK: - Analytics Events Extension
extension AnalyticsEvent {
    static let purchaseCompleted = AnalyticsEvent(rawValue: "purchase_completed")!
    static let purchaseFailed = AnalyticsEvent(rawValue: "purchase_failed")!
    static let purchaseRestored = AnalyticsEvent(rawValue: "purchase_restored")!
} 
