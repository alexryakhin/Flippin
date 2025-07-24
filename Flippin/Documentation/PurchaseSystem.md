# Flippin Purchase System

## Overview

The purchase system in the Flippin app uses StoreKit 2 to handle subscription-based in-app purchases. The system provides premium access through monthly and yearly subscriptions, with automatic transaction management and caching for optimal performance.

## Components

### 1. PurchaseService
Main service for managing purchases:
- Loading subscription products from App Store
- Executing subscription purchases
- Automatic listening for transaction updates
- Caching purchased product state for fast access
- Premium access status management
- Purchase restoration

### 2. PurchaseTestView
UI for testing purchases:
- Button for performing test purchases
- Displaying the last transaction ID
- Viewing available products with purchase status
- List of purchased products
- Transaction history
- Transaction listener status

### 3. Paywall.ContentView
Main paywall interface:
- Subscription options display
- Built-in StoreKit subscription management
- Feature highlights
- Restore purchases functionality

### 4. StoreKit Configuration
Configuration file for test products:
- `com.dor.flippin.premium_monthly` - Monthly subscription ($3.99)
- `com.dor.flippin.premium_yearly` - Yearly subscription ($29.99)
- Subscription group ID: `21731755`

## Product Configuration

### Subscription Products
```json
{
  "subscriptionGroups": [
    {
      "id": "21731755",
      "name": "Premium",
      "subscriptions": [
        {
          "productID": "com.dor.flippin.premium_monthly",
          "displayPrice": "3.99",
          "recurringSubscriptionPeriod": "P1M",
          "familyShareable": true
        },
        {
          "productID": "com.dor.flippin.premium_yearly", 
          "displayPrice": "29.99",
          "recurringSubscriptionPeriod": "P1Y",
          "familyShareable": true
        }
      ]
    }
  ]
}
```

### Premium Features
- **Unlimited Cards**: Remove card creation limits
- **All Collections**: Access to all preset vocabulary collections
- **Premium Backgrounds**: Beautiful animated backgrounds
- **Language Switching**: Change between different language pairs anytime

## How to Perform a Test Purchase

### Method 1: Through UI
1. Open the Flippin app
2. Go to Settings
3. Find the "Purchase Testing" section
4. Tap "Open Purchase Test"
5. Tap "Start Test Purchase"
6. Confirm the purchase in the StoreKit dialog
7. Get the transaction ID in the results

### Method 2: Programmatically
```swift
// Simple test purchase
Task {
    let result = await PurchaseService.shared.performTestPurchase()
    if result.success {
        print("Transaction ID: \(result.transactionId ?? "Unknown")")
    }
}

// Purchase specific subscription
Task {
    let result = await PurchaseService.shared.purchaseProduct("com.dor.flippin.premium_monthly")
    if result.success {
        print("Transaction ID: \(result.transactionId ?? "Unknown")")
    }
}
```

## Transaction Updates Listening

The system automatically starts listening for transaction updates when `PurchaseService` is initialized. This is critically important for preventing loss of purchases.

### Automatic Listening
```swift
// When PurchaseService is initialized, it automatically starts:
private func listenForTransactionUpdates() async {
    for await result in Transaction.updates {
        let transaction = try checkVerified(result)
        // Process transaction
        await addToPurchasedProducts(transaction.productID)
        await transaction.finish()
    }
}
```

### Checking Listener Status
```swift
let purchaseService = PurchaseService.shared
if purchaseService.isListeningForUpdates {
    print("✅ Transaction listener is active")
} else {
    print("⚠️ Transaction listener is not active")
}
```

## Cached Purchase State

The system uses cached purchase state for faster access at app launch:

### Caching Implementation
```swift
// Load cached state immediately
private func loadCachedPurchaseState() {
    if let cachedIds = UserDefaults.standard.array(forKey: UserDefaultsKey.cachedPurchasedProducts) as? [String] {
        cachedPurchasedProductIds = Set(cachedIds)
        purchasedProductIds = cachedPurchasedProductIds
        updatePremiumAccessStatus()
    }
}

// Save state after updates
private func saveCachedPurchaseState() {
    let idsArray = Array(purchasedProductIds)
    UserDefaults.standard.set(idsArray, forKey: UserDefaultsKey.cachedPurchasedProducts)
}
```

## Getting Transaction ID

### From Purchase Result
```swift
let result = await PurchaseService.shared.performTestPurchase()
if result.success {
    let transactionId = result.transactionId
    print("Transaction ID: \(transactionId ?? "Unknown")")
}
```

### From Transaction History
```swift
let transactions = await PurchaseService.shared.getTransactionHistory()
for transaction in transactions {
    print("Transaction ID: \(transaction.id.description)")
    print("Product: \(transaction.productID)")
    print("Date: \(transaction.purchaseDate)")
}
```

### From UI
After a successful purchase, the transaction ID is displayed in the "Last Transaction ID" section and can be copied to clipboard.

## Premium Access Management

### Checking Premium Status
```swift
let purchaseService = PurchaseService.shared
if purchaseService.hasPremiumAccess {
    print("✅ User has premium access")
} else {
    print("❌ User does not have premium access")
}
```

### Premium Access Logic
```swift
private func updatePremiumAccessStatus() {
    hasPremiumAccess = isProductPurchased("com.dor.flippin.premium_monthly") ||
                      isProductPurchased("com.dor.flippin.premium_yearly")
}
```

## Setup for Testing

### 1. StoreKit Configuration
The `Flippin.storekit` file contains test product configuration. To use:

1. Open the project in Xcode
2. Select the scheme for launch
3. In scheme settings, enable "StoreKit Configuration"
4. Select the `Flippin.storekit` file

### 2. Test Accounts
For testing in simulator:
- Use built-in StoreKit test accounts
- Or create a test account in App Store Connect

### 3. Debug Mode
In Xcode enable:
- StoreKit Testing
- StoreKit Configuration
- StoreKit Transaction Manager

## Usage Examples

### Complete Purchase Flow
```swift
// 1. Load products
await PurchaseService.shared.loadProducts()

// 2. Perform purchase
let result = await PurchaseService.shared.performTestPurchase()

// 3. Handle result
if result.success {
    let transactionId = result.transactionId
    print("Purchase successful! Transaction ID: \(transactionId ?? "Unknown")")
    
    // 4. Check premium access
    if PurchaseService.shared.hasPremiumAccess {
        print("✅ Premium access granted")
    }
    
    // 5. Get transaction history
    let transactions = await PurchaseService.shared.getTransactionHistory()
    print("Total transactions: \(transactions.count)")
} else {
    print("Purchase error: \(result.error ?? "Unknown error")")
}
```

### Checking Purchases
```swift
// Check if user has premium access
if PurchaseService.shared.hasPremiumAccess {
    print("User has premium access")
}

// Check specific subscription
let monthlyId = "com.dor.flippin.premium_monthly"
if PurchaseService.shared.isProductPurchased(monthlyId) {
    print("Monthly subscription is active")
} else {
    print("Monthly subscription is not active")
}

// Get all purchased products
let purchasedProducts = PurchaseService.shared.getPurchasedProducts()
print("Purchased products: \(purchasedProducts)")

// Get last transaction ID
if let lastTransactionId = PurchaseService.shared.lastTransactionId {
    print("Last Transaction ID: \(lastTransactionId)")
}
```

## Error Handling

### Common Errors
- `Product not found` - Product not found in App Store
- `Purchase cancelled by user` - User cancelled the purchase
- `Purchase pending approval` - Purchase pending approval
- `Transaction verification failed` - Transaction verification error

### Error Handling
```swift
let result = await PurchaseService.shared.performTestPurchase()
if !result.success {
    switch result.error {
    case "Product not found":
        print("Product not found")
    case "Purchase cancelled by user":
        print("User cancelled purchase")
    default:
        print("Error: \(result.error ?? "Unknown")")
    }
}
```

## Analytics

The system automatically tracks purchase events:
- `purchase_completed` - Successful purchase
- `purchase_failed` - Failed purchase
- `transaction_updated` - Transaction update received
- `purchase_test_opened` - Opening purchase testing

### Analytics Parameters
```swift
AnalyticsService.trackEvent(.purchaseCompleted, parameters: [
    "product_id": productId,
    "transaction_id": transaction.id.description,
    "price": product.displayPrice
])
```

## Security

- All transactions are verified through StoreKit
- Transaction ID is generated by Apple and is unique
- Automatic listening for transaction updates prevents loss of purchases
- Support for purchase restoration
- Handling of all possible purchase states
- Cached state for faster access while maintaining security

## Performance Optimizations

### Cached State Loading
- Purchase state is cached in UserDefaults for instant access
- Cached state is loaded immediately on app launch
- StoreKit verification happens in background
- Premium access status is updated automatically

### Transaction Management
- Transactions are finished automatically in the updates listener
- No double-finishing of transactions
- Proper error handling for verification failures
- Background processing of transaction updates

## Support

If you encounter problems:
1. Check StoreKit Configuration settings
2. Make sure products are configured in App Store Connect
3. Check Xcode logs for diagnostics
4. Use StoreKit Transaction Manager for debugging
5. Verify subscription group configuration
6. Check cached purchase state in UserDefaults

## Future Enhancements

- **Introductory Offers**: Free trial periods for new subscribers
- **Promotional Offers**: Special pricing for existing users
- **Family Sharing**: Enhanced family sharing features
- **Subscription Management**: In-app subscription management
- **Receipt Validation**: Server-side receipt validation 
