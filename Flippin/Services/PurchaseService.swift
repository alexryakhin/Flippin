import Foundation
import RevenueCat
import StoreKit

struct PurchaseResult {
    let success: Bool
    let transactionId: String?
    let error: String?
    let productId: String
}

// MARK: - Purchase Service (RevenueCat)
final class PurchaseService: NSObject, ObservableObject {
    static let shared = PurchaseService()
    
    @Published var isPurchasing = false
    @Published var hasPremiumAccess: Bool = false
    @Published var offerings: Offering?
    @Published var customerInfo: CustomerInfo?
    
    // Product IDs (keep for compatibility)
    private let monthlyProductId = "com.dor.flippin.premium_monthly"
    private let yearlyProductId = "com.dor.flippin.premium_yearly"
    
    // Entitlement identifiers (must match your RevenueCat dashboard)
    private let monthlyEntitlementID = "premium_monthly"
    private let yearlyEntitlementID = "premium_yearly"
    
    // MARK: - Debug Properties
    #if DEBUG
    @Published var isDebugModeEnabled: Bool = false
    #endif
    
    // Computed property for products (for compatibility)
    var products: [StoreProduct] {
        offerings?.availablePackages.map { $0.storeProduct } ?? []
    }
    
    private override init() {
        super.init()

        // Load cached state for immediate access - this should happen first
        loadCachedPurchaseState()
        
        // Set up RevenueCat delegate
        Purchases.shared.delegate = self
        
        // Initial load - but don't wait for it to set hasPremiumAccess
        Task {
            await refreshCustomerInfo()
            await loadOfferings()
        }
    }
    
    // MARK: - Load Offerings
    @MainActor
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings.current
            print("📦 Loaded RevenueCat offerings: \(offerings.current?.availablePackages.count ?? 0) packages")
        } catch {
            print("❌ Failed to load offerings: \(error)")
            AnalyticsService.trackErrorEvent(.errorOccurred, errorMessage: error.localizedDescription, errorCode: "load_offerings_failed")
        }
    }
    
    // MARK: - Load Products (for compatibility)
    func loadProducts() async {
        await loadOfferings()
    }
    
    // MARK: - Purchase Methods
    func purchaseProduct(_ productId: String) async -> PurchaseResult {
        // Find the package with matching product ID
        guard let package = offerings?.availablePackages.first(where: { $0.storeProduct.productIdentifier == productId }) else {
            print("❌ Product not found: \(productId)")
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: "Product not found",
                productId: productId
            )
        }
        
        return await purchasePackage(package)
    }
    
    func purchasePackage(_ package: Package) async -> PurchaseResult {
        await MainActor.run {
            isPurchasing = true
        }
        defer {
            Task { @MainActor in
                isPurchasing = false
            }
        }
        
        do {
            let (transaction, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            
            if userCancelled {
                print("⚠️ User cancelled purchase")
                return PurchaseResult(
                    success: false,
                    transactionId: nil,
                    error: "Purchase cancelled by user",
                    productId: package.storeProduct.productIdentifier
                )
            }
            
            // Update premium access status
            await updatePremiumAccessStatus(from: customerInfo)
            
            // Immediately save the new state to cache for instant access
            await MainActor.run {
                saveCachedPurchaseState()
            }
            
            let transactionId = transaction?.transactionIdentifier ?? "unknown"
            
            // Track analytics
            AnalyticsService.trackEvent(.purchaseCompleted, parameters: [
                "product_id": package.storeProduct.productIdentifier,
                "transaction_id": transactionId,
                "price": package.storeProduct.localizedPriceString
            ])
            
            // Haptic feedback
            await HapticService.shared.purchaseSuccess()
            
            print("✅ Purchase successful: \(package.storeProduct.productIdentifier)")
            
            return PurchaseResult(
                success: true,
                transactionId: transactionId,
                error: nil,
                productId: package.storeProduct.productIdentifier
            )
            
        } catch let error as ErrorCode {
            print("❌ Purchase failed: \(error)")
            
            let errorMessage = error.localizedDescription
            AnalyticsService.trackErrorEvent(.purchaseFailed, errorMessage: errorMessage)
            
            // Haptic feedback for failed purchase
            await HapticService.shared.purchaseFailed()
            
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: errorMessage,
                productId: package.storeProduct.productIdentifier
            )
        } catch {
            print("❌ Unexpected purchase error: \(error)")
            
            // Haptic feedback for failed purchase
            await HapticService.shared.purchaseFailed()
            
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: error.localizedDescription,
                productId: package.storeProduct.productIdentifier
            )
        }
    }
    
    // MARK: - Test Purchase (for compatibility)
    func performTestPurchase() async -> PurchaseResult {
        guard let firstPackage = offerings?.availablePackages.first else {
            return PurchaseResult(
                success: false,
                transactionId: nil,
                error: "No products available for testing",
                productId: "test"
            )
        }
        
        print("🧪 Starting test purchase for: \(firstPackage.storeProduct.productIdentifier)")
        return await purchasePackage(firstPackage)
    }
    
    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await updatePremiumAccessStatus(from: customerInfo)
            print("✅ Purchases restored successfully")
            
            AnalyticsService.trackEvent(.purchasesRestored, parameters: [
                "has_premium": hasPremiumAccess
            ])
            
            return hasPremiumAccess
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            AnalyticsService.trackErrorEvent(.errorOccurred, errorMessage: error.localizedDescription, errorCode: "restore_failed")
            return false
        }
    }
    
    // MARK: - Refresh Customer Info
    @MainActor
    func refreshCustomerInfo() async {
        do {
            debugPrint("🔄 [PurchaseService] Fetching customer info from RevenueCat...")
            let customerInfo = try await Purchases.shared.customerInfo()
            debugPrint("✅ [PurchaseService] Customer info received")
            debugPrint("🔍 [PurchaseService] Original Request Date:", customerInfo.originalPurchaseDate?.description ?? "nil")
            debugPrint("🔍 [PurchaseService] All Purchased Product IDs:", customerInfo.allPurchasedProductIdentifiers)
            self.customerInfo = customerInfo
            await updatePremiumAccessStatus(from: customerInfo)
        } catch {
            print("❌ Failed to refresh customer info: \(error)")
        }
    }
    
    // MARK: - Reload Purchase Status (for compatibility)
    func reloadPurchaseStatus() async {
        print("🔄 Reloading purchase status...")
        await refreshCustomerInfo()
        print("✅ Purchase status reloaded")
    }
    
    // MARK: - Premium Access Management
    @MainActor
    private func updatePremiumAccessStatus(from customerInfo: CustomerInfo) {
        #if DEBUG
        if isDebugModeEnabled {
            hasPremiumAccess = true
            saveCachedPurchaseState()
            print("🔐 Premium access: true (debug mode)")
            return
        }
        #endif
        
        // Debug logging for entitlements
        debugPrint("🔍 [PurchaseService] Checking premium access...")
        debugPrint("🔍 [PurchaseService] Looking for entitlements:", monthlyEntitlementID, "or", yearlyEntitlementID)
        debugPrint("🔍 [PurchaseService] All entitlements:", customerInfo.entitlements.all.keys)
        debugPrint("🔍 [PurchaseService] Active subscriptions:", customerInfo.activeSubscriptions)
        
        let monthlyEntitlement = customerInfo.entitlements[monthlyEntitlementID]
        let yearlyEntitlement = customerInfo.entitlements[yearlyEntitlementID]
        
        if let monthlyEntitlement = monthlyEntitlement {
            debugPrint("🔍 [PurchaseService] Monthly entitlement found!")
            debugPrint("🔍 [PurchaseService]   - isActive:", monthlyEntitlement.isActive)
            debugPrint("🔍 [PurchaseService]   - willRenew:", monthlyEntitlement.willRenew)
            debugPrint("🔍 [PurchaseService]   - productIdentifier:", monthlyEntitlement.productIdentifier)
        }
        
        if let yearlyEntitlement = yearlyEntitlement {
            debugPrint("🔍 [PurchaseService] Yearly entitlement found!")
            debugPrint("🔍 [PurchaseService]   - isActive:", yearlyEntitlement.isActive)
            debugPrint("🔍 [PurchaseService]   - willRenew:", yearlyEntitlement.willRenew)
            debugPrint("🔍 [PurchaseService]   - productIdentifier:", yearlyEntitlement.productIdentifier)
        }
        
        if monthlyEntitlement == nil && yearlyEntitlement == nil {
            debugPrint("⚠️ [PurchaseService] Neither monthly nor yearly entitlements found in customerInfo!")
            debugPrint("⚠️ [PurchaseService] This usually means:")
            debugPrint("⚠️ [PurchaseService]   1. The entitlements are not configured in RevenueCat dashboard")
            debugPrint("⚠️ [PurchaseService]   2. Or the products are not linked to the entitlements")
        }
        
        let hasAccess = (monthlyEntitlement?.isActive == true) || (yearlyEntitlement?.isActive == true)
        hasPremiumAccess = hasAccess
        self.customerInfo = customerInfo
        saveCachedPurchaseState()
        
        print("🔐 Premium access: \(hasAccess)")
        
        if hasAccess {
            let activeProducts = customerInfo.activeSubscriptions
            print("📦 Active subscriptions: \(activeProducts)")
        }
    }
    
    // MARK: - Product Purchase Status (for compatibility)
    func isProductPurchased(_ productId: String) -> Bool {
        guard let customerInfo = customerInfo else { return false }
        return customerInfo.activeSubscriptions.contains(productId)
    }
    
    func getPurchasedProducts() -> [String] {
        // Try to get from current customerInfo first
        if let customerInfo = customerInfo {
            return Array(customerInfo.activeSubscriptions)
        }
        
        // Fallback to cached subscriptions if customerInfo is not available (offline)
        if let cachedSubscriptions = UserDefaults.standard.object(forKey: "cached_active_subscriptions") as? [String] {
            print("📦 Using cached subscriptions for offline access: \(cachedSubscriptions)")
            return cachedSubscriptions
        }
        
        return []
    }
    
    // MARK: - Transaction History (for compatibility)
    func getTransactionHistory() async -> [StoreTransaction] {
        // RevenueCat handles this internally, return empty array for compatibility
        // You can access transaction history through customerInfo.nonSubscriptionTransactions if needed
        return []
    }
    
    // MARK: - Cached Purchase State Management
    private func loadCachedPurchaseState() {
        if let hasPremium = UserDefaults.standard.object(forKey: UserDefaultsKey.cachedPurchasedProducts) as? Bool {
            hasPremiumAccess = hasPremium
            print("📦 Loaded cached purchase state: premium = \(hasPremium)")
            
            // Also load cached subscription info for better offline experience
            if let cachedSubscriptions = UserDefaults.standard.object(forKey: "cached_active_subscriptions") as? [String] {
                print("📦 Loaded cached subscriptions: \(cachedSubscriptions)")
            }
        } else {
            print("📦 No cached purchase state found")
        }
    }
    
    private func saveCachedPurchaseState() {
        UserDefaults.standard.set(hasPremiumAccess, forKey: UserDefaultsKey.cachedPurchasedProducts)
        print("💾 Saved cached purchase state: premium = \(hasPremiumAccess)")
        
        // Also cache the active subscriptions for better offline experience
        if let customerInfo = customerInfo {
            let activeSubscriptions = Array(customerInfo.activeSubscriptions)
            UserDefaults.standard.set(activeSubscriptions, forKey: "cached_active_subscriptions")
            print("💾 Saved cached subscriptions: \(activeSubscriptions)")
        }
    }
    
    // MARK: - Get Specific Packages
    func getMonthlyPackage() -> Package? {
        return offerings?.availablePackages.first { package in
            package.storeProduct.productIdentifier == monthlyProductId
        }
    }
    
    func getYearlyPackage() -> Package? {
        return offerings?.availablePackages.first { package in
            package.storeProduct.productIdentifier == yearlyProductId
        }
    }
    
    // MARK: - Trial Information
    func hasTrialPeriod(for productId: String) -> Bool {
        guard let package = offerings?.availablePackages.first(where: { 
            $0.storeProduct.productIdentifier == productId 
        }) else { return false }
        
        return package.storeProduct.introductoryDiscount != nil
    }
    
    func getTrialDuration(for productId: String) -> String? {
        guard let package = offerings?.availablePackages.first(where: { 
            $0.storeProduct.productIdentifier == productId 
        }),
        let introDiscount = package.storeProduct.introductoryDiscount else { return nil }
        switch introDiscount.subscriptionPeriod.unit {
        case .day:
            return "\(introDiscount.subscriptionPeriod.value) day\(introDiscount.subscriptionPeriod.value == 1 ? "" : "s")"
        case .week:
            return "\(introDiscount.subscriptionPeriod.value) week\(introDiscount.subscriptionPeriod.value == 1 ? "" : "s")"
        case .month:
            return "\(introDiscount.subscriptionPeriod.value) month\(introDiscount.subscriptionPeriod.value == 1 ? "" : "s")"
        case .year:
            return "\(introDiscount.subscriptionPeriod.value) year\(introDiscount.subscriptionPeriod.value == 1 ? "" : "s")"
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Debug Methods
    #if DEBUG
    /// Toggle debug mode to enable premium access locally
    func toggleDebugMode() {
        isDebugModeEnabled.toggle()
        Task { @MainActor in
            if let customerInfo = customerInfo {
                await updatePremiumAccessStatus(from: customerInfo)
            } else {
                hasPremiumAccess = isDebugModeEnabled
                saveCachedPurchaseState()
            }
        }
        print("🔧 Debug mode \(isDebugModeEnabled ? "enabled" : "disabled")")
    }
    
    /// Enable debug mode
    func enableDebugMode() {
        isDebugModeEnabled = true
        Task { @MainActor in
            if let customerInfo = customerInfo {
                await updatePremiumAccessStatus(from: customerInfo)
            } else {
                hasPremiumAccess = true
                saveCachedPurchaseState()
            }
        }
        print("🔧 Debug mode enabled")
    }
    
    /// Disable debug mode
    func disableDebugMode() {
        isDebugModeEnabled = false
        Task { @MainActor in
            if let customerInfo = customerInfo {
                await updatePremiumAccessStatus(from: customerInfo)
            } else {
                hasPremiumAccess = false
                saveCachedPurchaseState()
            }
        }
        print("🔧 Debug mode disabled")
    }
    
    /// Sync StoreKit 2 transactions with RevenueCat (useful in simulator)
    func syncStoreKitTransactions() async {
        debugPrint("🔄 [PurchaseService] Manually syncing StoreKit 2 transactions...")
        
        // Check for unfinished transactions
        for await transaction in Transaction.unfinished {
            debugPrint("🔍 [PurchaseService] Found unfinished transaction:", transaction.unsafePayloadValue.productID)

            if let verification = try? transaction.payloadData {
                debugPrint("🔍 [PurchaseService] Transaction data:", verification.count, "bytes")
            }
        }
        
        // Check for all transactions
        for await transaction in Transaction.all {
            debugPrint("🔍 [PurchaseService] All transactions - Product:", transaction.unsafePayloadValue.productID, "Date:", transaction.unsafePayloadValue.purchaseDate)
        }
        
        // Force refresh after checking transactions
        await refreshCustomerInfo()
        debugPrint("✅ [PurchaseService] Transaction sync complete")
    }
    #endif
}

// MARK: - PurchasesDelegate
extension PurchaseService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        debugPrint("📬 [PurchaseService] Received customer info update from RevenueCat delegate")
        debugPrint("🔍 [PurchaseService] Update source: Push notification or background sync")
        Task { @MainActor in
            await updatePremiumAccessStatus(from: customerInfo)
        }
    }
}

// MARK: - Purchase Errors (for compatibility)
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
