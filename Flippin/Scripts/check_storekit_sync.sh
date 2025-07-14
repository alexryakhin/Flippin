#!/bin/bash

# StoreKit Configuration Sync Check Script
# Checks the sync status of StoreKit Configuration

echo "🔍 Checking StoreKit Configuration sync status..."

# Check for configuration file
CONFIG_FILE="Flippin/Configuration/StoreKitConfiguration.storekit"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ StoreKit Configuration file not found: $CONFIG_FILE"
    exit 1
fi

echo "✅ StoreKit Configuration file found"

# Check sync settings
if grep -q '"_syncEnabled" : true' "$CONFIG_FILE"; then
    echo "✅ Sync is enabled"
else
    echo "⚠️  Sync is not enabled"
fi

if grep -q '"_syncMode" : "automatic"' "$CONFIG_FILE"; then
    echo "✅ Automatic sync mode is enabled"
else
    echo "⚠️  Automatic sync mode is not enabled"
fi

# Check for products
PRODUCT_COUNT=$(grep -c '"productID"' "$CONFIG_FILE")
echo "📦 Found $PRODUCT_COUNT products in configuration"

# Check specific products
REQUIRED_PRODUCTS=(
    "com.dor.flippin.unlimited_cards"
    "com.dor.flippin.premium_monthly"
    "com.dor.flippin.premium_yearly"
)

echo "🔍 Checking required products:"
for product in "${REQUIRED_PRODUCTS[@]}"; do
    if grep -q "$product" "$CONFIG_FILE"; then
        echo "✅ $product - found"
    else
        echo "❌ $product - missing"
    fi
done

# Check prices
echo "💰 Checking prices:"
if grep -q '"displayPrice"' "$CONFIG_FILE"; then
    echo "✅ Prices are configured"
else
    echo "⚠️  Prices are not configured"
fi

# Check subscriptions
echo "📅 Checking subscriptions:"
if grep -q '"subscriptionGroups"' "$CONFIG_FILE"; then
    echo "✅ Subscription groups are configured"
else
    echo "⚠️  Subscription groups are not configured"
fi

echo ""
echo "📋 Summary:"
echo "- Configuration file: ✅"
echo "- Products found: $PRODUCT_COUNT"
echo "- Sync enabled: $(grep -q '_syncEnabled.*true' "$CONFIG_FILE" && echo "✅" || echo "❌")"
echo "- Automatic sync: $(grep -q '_syncMode.*automatic' "$CONFIG_FILE" && echo "✅" || echo "❌")"

echo ""
echo "💡 Next steps:"
echo "1. Open Xcode"
echo "2. Go to Product → StoreKit → Manage StoreKit Configuration"
echo "3. Click 'Sync with App Store Connect'"
echo "4. Sign in with your Apple Developer account"
echo "5. Select your app and sync"

echo ""
echo "🔧 For manual sync in Xcode:"
echo "Product → StoreKit → Manage StoreKit Configuration → Sync Now" 