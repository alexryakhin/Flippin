# Card Limit Implementation Guide

## Overview

This document explains how the card limit system has been implemented in the Flippin app, including the recommended limits, implementation details, and UI updates.

## Recommended Card Limits

### Free Users: 10 cards
- Allows users to experience the app's core functionality
- Provides enough cards to understand the value proposition
- Encourages upgrades without being too restrictive

### Premium Users: Unlimited cards
- Any user with one of these purchases gets unlimited cards:
  - `com.dor.flippin.unlimited_cards` (Non-Consumable, $0.99)
  - `com.dor.flippin.premium_monthly` (Auto-Renewable, $1.99)
  - `com.dor.flippin.premium_yearly` (Auto-Renewable, $19.99)

## Implementation Details

### 1. CardsProvider Updates

The `CardsProvider` class now includes:

```swift
// Card limit configuration
private let freeUserCardLimit = 10

// Computed properties for limit checking
var cardLimit: Int
var hasUnlimitedCards: Bool
var wouldExceedLimit: Bool
var remainingCards: Int

// Updated methods with limit checking
func addCard(_ card: CardItem, tags: [String] = []) throws
func addCards(_ cards: [CardItem], tags: [String] = []) throws
```

### 2. Error Handling

New `CardLimitError` enum for handling limit exceeded scenarios:

```swift
enum CardLimitError: LocalizedError {
    case limitExceeded(currentCount: Int, limit: Int, remainingCards: Int)
}
```

### 3. UI Updates

#### Add Card Sheet
- Shows remaining cards count in save button: "Save (5 left)"
- Displays alert when limit is exceeded
- Prevents card creation when limit is reached

#### Main Content View
- Card limit indicator for free users showing progress bar
- Upgrade button that opens settings
- Only visible for free users

#### Preset Collections
- Handles limit checking when importing collections
- Shows appropriate error messages

## How to Check Purchase Status

### In Code:
```swift
let cardsProvider = CardsProvider.shared

// Check if user has unlimited cards
if cardsProvider.hasUnlimitedCards {
    // User can add unlimited cards
} else {
    // User is limited to 10 cards
    let remaining = cardsProvider.remainingCards
    print("User has \(remaining) cards remaining")
}

// Check if adding a card would exceed limit
if cardsProvider.wouldExceedLimit {
    // Show upgrade prompt
}
```

### Purchase Status Check:
```swift
let purchaseService = PurchaseService.shared

// Check specific product
if purchaseService.isProductPurchased("com.dor.flippin.unlimited_cards") {
    print("User has unlimited cards")
}

// Check any premium product
let hasAnyPremium = purchaseService.isProductPurchased("com.dor.flippin.unlimited_cards") ||
                   purchaseService.isProductPurchased("com.dor.flippin.premium_monthly") ||
                   purchaseService.isProductPurchased("com.dor.flippin.premium_yearly")
```

## UI Flow

### 1. Free User Experience
1. User sees card limit indicator: "5 of 10 cards"
2. Progress bar shows usage
3. Upgrade button available
4. When adding cards, save button shows: "Save (3 left)"
5. If limit exceeded, alert appears with upgrade option

### 2. Premium User Experience
1. No card limit indicator visible
2. Save button shows just "Save"
3. No limit checking when adding cards
4. Unlimited card creation

### 3. Upgrade Flow
1. User taps "Upgrade" button
2. Alert appears with upgrade options
3. User taps "View Options"
4. Settings screen opens with purchase testing section
5. User can test and make purchases

## Testing the Implementation

### 1. Test as Free User
1. Delete any existing purchases in StoreKit Transaction Manager
2. Try adding more than 10 cards
3. Verify limit indicator appears
4. Verify upgrade prompts work

### 2. Test as Premium User
1. Make a test purchase in Purchase Testing
2. Verify limit indicator disappears
3. Verify unlimited card creation works

### 3. Test Limit Enforcement
1. Add exactly 10 cards as free user
2. Try to add an 11th card
3. Verify error message appears
4. Try importing a preset collection that would exceed limit

## Localization

New localization keys added:
- `cardLimitExceeded` = "Card Limit Reached"
- `upgradeToPremium` = "Upgrade to Premium"
- `cardsRemaining` = "Cards Remaining"
- `unlimitedCards` = "Unlimited Cards"
- `ok` = "OK"

## Analytics Integration

The existing analytics system continues to work:
- Card creation events are tracked
- Purchase events are tracked
- Error events are tracked when limits are exceeded

## Future Enhancements

### Potential Improvements:
1. **Tiered Limits**: Different limits for different subscription tiers
2. **Grace Period**: Allow temporary over-limit usage
3. **Smart Suggestions**: Suggest deleting unused cards when limit reached
4. **Usage Analytics**: Track how users interact with limits
5. **A/B Testing**: Test different limit amounts

### Configuration Options:
- Make the free user limit configurable
- Add different limits for different user segments
- Implement time-based limits (e.g., 10 cards per month)

## Troubleshooting

### Common Issues:

1. **Limit not enforced**: Check that `PurchaseService.shared.isProductPurchased()` is working
2. **UI not updating**: Ensure `CardsProvider` is properly observed in views
3. **Error messages not showing**: Check that `CardLimitError` is properly caught
4. **Purchase status not updating**: Verify transaction listener is active

### Debug Commands:
```swift
// Check current status
print("Card limit: \(cardsProvider.cardLimit)")
print("Current cards: \(cardsProvider.cards.count)")
print("Has unlimited: \(cardsProvider.hasUnlimitedCards)")
print("Would exceed: \(cardsProvider.wouldExceedLimit)")

// Check purchase status
print("Purchased products: \(purchaseService.getPurchasedProducts())")
```

## Conclusion

The card limit system provides a clear freemium model that:
- Allows users to experience the app's value
- Encourages premium upgrades
- Maintains a good user experience
- Integrates seamlessly with existing purchase system

The implementation is robust, user-friendly, and ready for production use. 