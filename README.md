# Flippin Purchase System

A complete in-app purchase system for iOS apps using StoreKit 2, featuring automatic transaction listening, purchase status tracking, and comprehensive testing tools.

## 🚀 Features

- **StoreKit 2 Integration**: Modern, secure in-app purchase handling
- **Automatic Transaction Listening**: Prevents loss of purchases
- **Purchase Status Tracking**: Real-time UI updates for purchased products
- **Test Purchase System**: Complete testing environment
- **Transaction History**: Full purchase history with transaction IDs
- **Purchase Restoration**: Support for restoring purchases
- **Analytics Integration**: Automatic event tracking
- **StoreKit Configuration Sync**: Automatic sync with App Store Connect

## 📱 Quick Start

### 1. Setup Project
```bash
# Check current status
./Flippin/Scripts/check_storekit_sync.sh
```

### 2. Configure in App Store Connect
1. Open [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create products with these IDs:
   - `com.dor.flippin.unlimited_cards` (Non-Consumable, $0.99)
   - `com.dor.flippin.premium_monthly` (Auto-Renewable, $4.99)
   - `com.dor.flippin.premium_yearly` (Auto-Renewable, $39.99)

### 3. Sync in Xcode
1. Open project in Xcode
2. **Product** → **StoreKit** → **Manage StoreKit Configuration**
3. Click **"Sync with App Store Connect"**
4. Sign in and sync

### 4. Test Purchases
1. Run the app
2. Go to **Settings** → **Purchase Testing**
3. Tap **"Start Test Purchase"**

## 🏗️ Architecture

### Core Components

#### PurchaseService
Main service managing all purchase operations:
```swift
class PurchaseService: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIds: Set<String> = []
    @Published var isListeningForUpdates = false
    
    func performTestPurchase() async -> PurchaseResult
    func purchaseProduct(_ productId: String) async -> PurchaseResult
    func isProductPurchased(_ productId: String) -> Bool
    func getPurchasedProducts() -> [String]
}
```

#### PurchaseTestView
Complete UI for testing purchases with real-time status updates.

#### StoreKit Configuration
Automatically synced configuration file for test products.

## 💻 Usage Examples

### Basic Purchase
```swift
let result = await PurchaseService.shared.performTestPurchase()
if result.success {
    print("Transaction ID: \(result.transactionId ?? "Unknown")")
}
```

### Check Purchase Status
```swift
let unlimitedCardsId = "com.dor.flippin.unlimited_cards"
if PurchaseService.shared.isProductPurchased(unlimitedCardsId) {
    // Show premium features
    cardLimit = .max
} else {
    // Show limited features
    cardLimit = 10
}
```

### Get All Purchased Products
```swift
let purchasedProducts = PurchaseService.shared.getPurchasedProducts()
print("Purchased: \(purchasedProducts)")
```

### Purchase Specific Product
```swift
let result = await PurchaseService.shared.purchaseProduct("com.dor.flippin.unlimited_cards")
if result.success {
    print("Purchase successful!")
}
```

## 🎨 UI Features

### Visual Indicators
- ✅ Green checkmark for purchased products
- 💰 Price hidden for purchased products
- 🛒 "Purchase" button replaced with "Already Purchased"

### Sections
- **Test Purchase**: Quick test purchase button
- **Last Transaction ID**: Copyable transaction identifier
- **Available Products**: Products with purchase status
- **Purchased Products**: List of all purchased products
- **Transaction History**: Complete purchase history
- **Restore Purchases**: Restore functionality

## 🔄 Automatic Updates

### Transaction Listening
The system automatically listens for transaction updates:
```swift
private func listenForTransactionUpdates() async {
    for await result in Transaction.updates {
        let transaction = try checkVerified(result)
        await addToPurchasedProducts(transaction.productID)
        await transaction.finish()
    }
}
```

### Real-time UI Updates
- Products automatically update status after purchase
- Transaction listener status shown in UI
- Purchase history updates automatically

## 🧪 Testing

### Test Scenarios
1. **Basic Test Purchase**: Tap "Start Test Purchase"
2. **Specific Product**: Purchase individual products
3. **Purchase Status**: Observe UI changes after purchase
4. **Transaction History**: View all transactions
5. **Purchase Restoration**: Test restore functionality

### Debug Tools
- **StoreKit Transaction Manager**: Built into Xcode
- **Sync Status Check**: `./Flippin/Scripts/check_storekit_sync.sh`
- **Console Logs**: Detailed logging with emojis
- **UI Status Indicators**: Visual feedback in app

## 📊 Analytics

Automatic event tracking:
- `purchase_completed` - Successful purchases
- `purchase_failed` - Failed purchases
- `purchase_restored` - Purchase restoration
- `purchase_test_opened` - Testing interface opened
- `transaction_updated` - Transaction updates
- `transaction_verification_failed` - Verification errors

## 🔧 Configuration

### StoreKit Configuration
```json
{
  "identifier": "FlippinTestConfiguration",
  "products": [
    {
      "productID": "com.dor.flippin.unlimited_cards",
      "type": "NonConsumable",
      "displayPrice": "0.99"
    }
  ],
  "subscriptionGroups": [
    {
      "id": "21482456",
      "subscriptions": [
        {
          "productID": "com.dor.flippin.premium_monthly",
          "displayPrice": "4.99"
        }
      ]
    }
  ]
}
```

### Sync Settings
- Automatic sync enabled
- 1-hour sync interval
- Real-time price updates
- Product metadata sync

## 🛡️ Security

- **Transaction Verification**: All transactions verified through StoreKit
- **Unique Transaction IDs**: Generated by Apple
- **Automatic Listening**: Prevents purchase loss
- **Purchase Restoration**: Official Apple restoration
- **Error Handling**: Comprehensive error management

## 📚 Documentation

- **[Purchase System](Flippin/Documentation/PurchaseSystem.md)**: Complete system documentation
- **[StoreKit Sync Setup](Flippin/Documentation/StoreKitSyncSetup.md)**: Sync configuration guide
- **[Purchase Status Demo](PURCHASE_STATUS_DEMO.md)**: UI demonstration
- **[Quick Sync Setup](QUICK_SYNC_SETUP.md)**: Fast setup guide

## 🚀 Getting Started

1. **Clone/Download** the project
2. **Run the check script**: `./Flippin/Scripts/check_storekit_sync.sh`
3. **Setup App Store Connect** products
4. **Sync in Xcode** with App Store Connect
5. **Test purchases** in the app

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter issues:
1. Check StoreKit Configuration settings
2. Verify products in App Store Connect
3. Check Xcode logs for diagnostics
4. Use StoreKit Transaction Manager
5. Review the documentation

---

**Built with ❤️ for iOS developers** 