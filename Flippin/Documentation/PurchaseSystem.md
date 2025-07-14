# Flippin Purchase System

## Overview

The purchase system in the Flippin app uses StoreKit 2 to handle in-app purchases. The system supports test purchases and provides complete transaction information, including transaction identifiers.

## Components

### 1. PurchaseService
Main service for managing purchases:
- Loading products from App Store
- Executing purchases
- Automatic listening for transaction updates
- Tracking purchased products
- Getting transaction history
- Restoring purchases

### 2. PurchaseTestView
UI for testing purchases:
- Button for performing test purchases
- Displaying the last transaction ID
- Viewing available products with purchase status
- List of purchased products
- Transaction history

### 3. StoreKit Configuration
Configuration file for test products:
- `com.dor.flippin.unlimited_cards` - Non-consumable product ($0.99)
- `com.dor.flippin.premium_monthly` - Monthly subscription ($1.99)
- `com.dor.flippin.premium_yearly` - Yearly subscription ($19.99)

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

// Purchase specific product
Task {
    let result = await PurchaseService.shared.purchaseProduct("com.dor.flippin.unlimited_cards")
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

## Setup for Testing

### 1. StoreKit Configuration
The `StoreKitConfiguration.storekit` file contains test product configuration. To use:

1. Open the project in Xcode
2. Select the scheme (scheme) for launch
3. In scheme settings, enable "StoreKit Configuration"
4. Select the `FlippinTestConfiguration` file

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
    
    // 4. Save transaction ID
    UserDefaults.standard.set(transactionId, forKey: "last_transaction_id")
    
    // 5. Get transaction history
    let transactions = await PurchaseService.shared.getTransactionHistory()
    print("Total transactions: \(transactions.count)")
} else {
    print("Purchase error: \(result.error ?? "Unknown error")")
}
```

### Checking Purchases
```swift
// Check if user has any purchases
let hasPurchases = await PurchaseExample.hasAnyPurchases()
if hasPurchases {
    print("User has purchases")
}

// Check specific product
let unlimitedCardsId = "com.dor.flippin.unlimited_cards"
if PurchaseExample.isProductPurchased(unlimitedCardsId) {
    print("Unlimited Cards is purchased")
} else {
    print("Unlimited Cards is not purchased")
}

// Get all purchased products
let purchasedProducts = PurchaseExample.getPurchasedProducts()
print("Purchased products: \(purchasedProducts)")

// Get last transaction ID
if let lastTransactionId = PurchaseExample.getLastTransactionId() {
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
- `purchase_restored` - Purchase restoration
- `purchase_test_opened` - Opening purchase testing

## Security

- All transactions are verified through StoreKit
- Transaction ID is generated by Apple and is unique
- Automatic listening for transaction updates prevents loss of purchases
- Support for purchase restoration
- Handling of all possible purchase states

## Support

If you encounter problems:
1. Check StoreKit Configuration settings
2. Make sure products are configured in App Store Connect
3. Check Xcode logs for diagnostics
4. Use StoreKit Transaction Manager for debugging 
