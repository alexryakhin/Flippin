# StoreKit Configuration Sync Setup

## Overview
StoreKit Configuration synchronization allows you to automatically get up-to-date product data from App Store Connect directly in Xcode for testing.

## Step-by-Step Setup

### 1. Preparation in App Store Connect

#### 1.1 Creating Products
1. Sign in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select the "Flippin" app
3. Go to **"Features"** → **"In-App Purchases"**
4. Create the following products:

**Non-consumable product:**
- Product ID: `com.dor.flippin.unlimited_cards`
- Type: Non-Consumable
- Reference Name: Unlimited Cards
- Price: $0.99

**Subscriptions:**
- Product ID: `com.dor.flippin.premium_monthly`
- Type: Auto-Renewable Subscription
- Reference Name: Premium Monthly
- Price: $1.99

- Product ID: `com.dor.flippin.premium_yearly`
- Type: Auto-Renewable Subscription
- Reference Name: Premium Yearly
- Price: $19.99

#### 1.2 Subscription Setup
1. Create a **Subscription Group** named "Premium"
2. Add both subscription products to this group
3. Configure **Family Sharing** for subscriptions

### 2. Setup in Xcode

#### 2.1 Enabling StoreKit Configuration
1. Open the `Flippin.xcodeproj` project
2. Select the scheme (scheme) for launch
3. Click **"Edit Scheme..."**
4. In the **"Run"** → **"Options"** section
5. Enable **"StoreKit Configuration"**
6. Select the `FlippinTestConfiguration` file

#### 2.2 Setting up Synchronization
1. In Xcode, select **"Product"** → **"StoreKit"** → **"Manage StoreKit Configuration"**
2. In the opened window, click **"Sync with App Store Connect"**
3. Sign in with your Apple Developer account
4. Select the "Flippin" app
5. Click **"Sync"**

### 3. Automatic Synchronization

#### 3.1 Setting up Automatic Sync
1. In the **"Manage StoreKit Configuration"** window
2. Enable **"Automatic Sync"**
3. Set the sync interval (recommended: 1 hour)

#### 3.2 Checking Synchronization
After synchronization, the configuration file should contain:
- Up-to-date prices from App Store Connect
- Correct Product IDs
- Subscription settings
- Localization

### 4. Testing Synchronization

#### 4.1 Checking Products
```swift
// In code, check that products are loaded
let products = await PurchaseService.shared.products
print("Loaded \(products.count) products from App Store Connect")
```

#### 4.2 Testing Purchases
1. Run the app in simulator
2. Go to **Settings** → **Purchase Testing**
3. Tap **"Start Test Purchase"**
4. Make sure real products are being used

### 5. Troubleshooting

#### 5.1 Sync Issues
- **Authentication error**: Check Apple Developer account
- **Products not found**: Make sure products are created in App Store Connect
- **Prices not updated**: Wait a few minutes and retry synchronization

#### 5.2 Status Check
```swift
// Check sync status
if purchaseService.products.isEmpty {
    print("⚠️ Products not loaded - check sync status")
} else {
    print("✅ Products loaded successfully")
}
```

### 6. Manual Synchronization

#### 6.1 Forced Synchronization
1. In Xcode: **Product** → **StoreKit** → **Manage StoreKit Configuration**
2. Click **"Sync Now"**
3. Wait for synchronization to complete

#### 6.2 Configuration Update
After synchronization, the configuration file will automatically update with:
- Up-to-date prices
- Correct Product IDs
- Subscription settings
- Localization

### 7. Monitoring Synchronization

#### 7.1 Sync Logs
In Xcode console you'll see:
```
🔔 Starting transaction updates listener...
📦 Loaded 3 products from App Store Connect
✅ Sync completed successfully
```

#### 7.2 UI Check
In the app in the **Purchase Testing** section:
- Status "Transaction listener active" should be green
- Products should display with up-to-date prices
- Test purchases should work correctly

## Important Notes

### For Development:
- Use **Sandbox** environment for testing
- Create test accounts in App Store Connect
- Test in simulator and on real devices

### For Production:
- Make sure all products have passed Apple review
- Set prices for all target regions
- Test purchases in TestFlight

### Security:
- Never commit real product data to git
- Use `.gitignore` for confidential data
- Regularly update configuration

## Debug Commands

### Checking Synchronization
```bash
# In Xcode terminal
xcrun simctl spawn booted log show --predicate 'process == "StoreKit"' --last 1h
```

### Resetting Configuration
```bash
# Remove StoreKit cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*/StoreKit
``` 
