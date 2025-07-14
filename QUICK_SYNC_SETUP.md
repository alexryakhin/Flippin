# 🚀 Quick StoreKit Sync Setup

## 1. Check Current Status
```bash
./Flippin/Scripts/check_storekit_sync.sh
```

## 2. Setup in App Store Connect
1. Open [App Store Connect](https://appstoreconnect.apple.com/)
2. Select the **"Flippin"** app
3. **"Features"** → **"In-App Purchases"**
4. Create products:
   - `com.dor.flippin.unlimited_cards` (Non-Consumable, $0.99)
   - `com.dor.flippin.premium_monthly` (Auto-Renewable, $4.99)
   - `com.dor.flippin.premium_yearly` (Auto-Renewable, $39.99)

## 3. Sync in Xcode
1. Open project in Xcode
2. **Product** → **StoreKit** → **Manage StoreKit Configuration**
3. Click **"Sync with App Store Connect"**
4. Sign in with Apple Developer account
5. Select "Flippin" app
6. Click **"Sync"**

## 4. Enable in Scheme
1. **Edit Scheme...** → **Run** → **Options**
2. Enable **"StoreKit Configuration"**
3. Select `FlippinTestConfiguration`

## 5. Testing
1. Run the app
2. **Settings** → **Purchase Testing**
3. Check status "Transaction listener active" ✅
4. Tap **"Start Test Purchase"**

## ✅ Done!
Your purchase system is now synchronized with App Store Connect and ready for testing!

## 🔧 Troubleshooting
- **Products not loading**: Check sync in Xcode
- **Authentication errors**: Check Apple Developer account
- **Prices not updated**: Wait and retry sync 