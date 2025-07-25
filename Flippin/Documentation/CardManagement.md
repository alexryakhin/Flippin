# Card Management System

## Overview

The card management system is the core of the Flippin app, handling all card-related operations including creation, modification, deletion, and organization. It integrates with Core Data for persistence, implements card limits for free users, and provides comprehensive analytics tracking.

## Architecture

### 1. CardsProvider
Main service for managing card operations:
- **Singleton Pattern**: `CardsProvider.shared`
- **ObservableObject**: SwiftUI integration
- **Core Data Integration**: Persistent storage
- **Limit Management**: Free user restrictions

### 2. CardItem Model
Core data model for flashcards:
- **Bilingual Content**: Front and back text
- **Language Support**: Language pair tracking
- **Metadata**: Timestamps, favorites, notes
- **Tag Relationships**: Many-to-many with tags

## Card Limit System

### Free User Limits
```swift
private let freeUserCardLimit = 25

var cardLimit: Int {
    if PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_monthly") ||
       PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_yearly") {
        return .max
    } else {
        return freeUserCardLimit
    }
}
```

### Limit Checking
```swift
var hasUnlimitedCards: Bool {
    return cardLimit == .max
}

var wouldExceedLimit: Bool {
    return !hasUnlimitedCards && cards.count >= cardLimit
}

var remainingCards: Int {
    if hasUnlimitedCards {
        return .max
    } else {
        return max(0, cardLimit - cards.count)
    }
}
```

## Core Operations

### Adding Cards
```swift
func addCard(frontText: String, backText: String, notes: String, tags: [String] = []) throws {
    // Check if adding this card would exceed the limit
    if wouldExceedLimit {
        throw CardLimitError.limitExceeded(
            currentCount: cards.count,
            limit: cardLimit,
            remainingCards: remainingCards
        )
    }

    let card = CardItem(
        frontText: frontText,
        backText: backText,
        frontLanguage: languageManager.targetLanguage,
        backLanguage: languageManager.userLanguage,
        notes: notes
    )

    // Add tags using TagManager
    for tagName in tags {
        if let tag = tagManager.findOrCreateTag(withName: tagName) {
            card.addToTags(tag)
        }
    }
    
    saveContext()
    fetchCards()

    // Haptic feedback for card addition
    HapticService.shared.cardAdded()
    
    // Analytics tracking for card creation
    AnalyticsService.trackCardEvent(
        .cardAdded,
        cardLanguage: card.frontLanguage?.rawValue,
        hasTags: !card.tagNames.isEmpty,
        tagCount: card.tagNames.count
    )
}
```

### Adding Preset Cards
```swift
func addPresetCards(_ cards: [PresetCard]) throws {
    // Check if adding these cards would exceed the limit
    if !hasUnlimitedCards && (self.cards.count + cards.count) > cardLimit {
        throw CardLimitError.limitExceeded(
            currentCount: self.cards.count,
            limit: cardLimit,
            remainingCards: remainingCards
        )
    }
    
    let items = convertPresetCardsToCardItems(cards)
    saveContext()
    fetchCards()
}
```

### Deleting Cards
```swift
func deleteCard(_ card: CardItem) {
    coreDataService.context.delete(card)
    if let index = cards.firstIndex(of: card) {
        cards.remove(at: index)
    }
    saveContext()
    
    // Haptic feedback for card deletion
    HapticService.shared.cardDeleted()
}

func deleteAllCards() {
    for card in cards {
        coreDataService.context.delete(card)
    }
    saveContext()
    cards.removeAll()
    objectWillChange.send()
}
```

### Toggling Favorites
```swift
func toggleFavorite(_ card: CardItem) {
    card.isFavorite.toggle()
    saveContext()
    
    // Haptic feedback for favorite toggle
    HapticService.shared.favoriteToggled(isFavorite: card.isFavorite)
    
    // Analytics tracking for favorite toggle
    let event: AnalyticsEvent = card.isFavorite ? .cardFavorited : .cardUnfavorited
    AnalyticsService.trackFavoriteEvent(
        event,
        cardLanguage: card.frontLanguage?.rawValue,
        hasTags: !card.tagNames.isEmpty
    )
}
```

## Data Fetching

### Fetching Cards
```swift
func fetchCards() {
    do {
        let request = CardItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CardItem.timestamp, ascending: true)]
        let fetchedCards = try coreDataService.context.fetch(request)
        cards = fetchedCards
        print("📱 Fetched \(fetchedCards.count) cards from Core Data")
    } catch {
        errorPublisher.send(error)
    }
}
```

### CloudKit Sync Check
```swift
private func checkForCloudKitData() {
    // Only check once if cards are empty at startup
    if cards.isEmpty {
        print("🔄 No cards found at startup, checking CloudKit sync...")
        coreDataService.checkCloudKitSync()
        
        // Try fetching again after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.fetchCards()
        }
    }
}
```

## Preset Card Conversion

### Converting Preset Cards
```swift
private func convertPresetCardsToCardItems(_ presetCards: [PresetCard]) -> [CardItem] {
    return presetCards.map { card in
        let item = CardItem(
            frontText: card.frontText,
            backText: card.backText,
            frontLanguage: languageManager.targetLanguage,
            backLanguage: languageManager.userLanguage,
            notes: card.notes
        )
        
        for tagName in card.tags {
            if let tag = tagManager.findOrCreateTag(withName: tagName) {
                item.addToTags(tag)
            }
        }

        return item
    }
}
```

## Error Handling

### CardLimitError
```swift
enum CardLimitError: Error, LocalizedError {
    case limitExceeded(currentCount: Int, limit: Int, remainingCards: Int)
    
    var errorDescription: String? {
        switch self {
        case .limitExceeded(let currentCount, let limit, let remainingCards):
            return "Card limit exceeded. You have \(currentCount) cards out of \(limit) allowed. \(remainingCards) cards remaining."
        }
    }
}
```

### Error Publishing
```swift
let errorPublisher = PassthroughSubject<Error, Never>()

func saveContext() {
    do {
        try coreDataService.saveContext()
        objectWillChange.send()
    } catch {
        errorPublisher.send(error)
    }
}
```

## Analytics Integration

### Card Events Tracking
```swift
// Card added
AnalyticsService.trackCardEvent(
    .cardAdded,
    cardLanguage: card.frontLanguage?.rawValue,
    hasTags: !card.tagNames.isEmpty,
    tagCount: card.tagNames.count
)

// Card favorited/unfavorited
let event: AnalyticsEvent = card.isFavorite ? .cardFavorited : .cardUnfavorited
AnalyticsService.trackFavoriteEvent(
    event,
    cardLanguage: card.frontLanguage?.rawValue,
    hasTags: !card.tagNames.isEmpty
)
```

## Integration with Other Services

### LanguageManager Integration
```swift
private let languageManager = LanguageManager.shared

// Use current language settings for new cards
let card = CardItem(
    frontText: frontText,
    backText: backText,
    frontLanguage: languageManager.targetLanguage,
    backLanguage: languageManager.userLanguage,
    notes: notes
)
```

### TagManager Integration
```swift
private let tagManager = TagManager.shared

// Add tags to cards
for tagName in tags {
    if let tag = tagManager.findOrCreateTag(withName: tagName) {
        card.addToTags(tag)
    }
}
```

### PurchaseService Integration
```swift
// Check premium status for limits
var cardLimit: Int {
    if PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_monthly") ||
       PurchaseService.shared.isProductPurchased("com.dor.flippin.premium_yearly") {
        return .max
    } else {
        return freeUserCardLimit
    }
}
```

## UI Integration

### Card Display
```swift
// In ContentView
var filteredItems: [CardItem] {
    var filtered = cardsProvider.cards
    
    // Apply language filter first
    filtered = languageManager.filterCards(filtered)
    
    // Then apply tag filter
    if let selectedFilterTag = tagManager.selectedFilterTag {
        filtered = tagManager.filterCards(filtered, by: selectedFilterTag)
    }
    filtered = tagManager.filterCardsByFavorite(filtered)
    return filtered
}
```

### Card Limit Indicator
```swift
// Show remaining cards for free users
HStack {
    VStack(alignment: .leading, spacing: 4) {
        Text(LocalizationKeys.cardsUsedOfLimit.localized(
            with: cardsProvider.cards.count, 
            cardsProvider.cardLimit
        ))
        .font(.subheadline)
        .foregroundStyle(.secondary)

        ProgressView(
            value: Double(cardsProvider.cards.count), 
            total: Double(cardsProvider.cardLimit)
        )
        .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
        .frame(height: 4)
    }
    
    Spacer()
    
    Button(LocalizationKeys.upgrade.localized) {
        showPaywall = true
    }
    .font(.caption)
    .buttonStyle(.borderedProminent)
    .clipShape(Capsule())
}
```

## Performance Optimizations

### Efficient Fetching
- **Sorting**: Cards sorted by timestamp for consistent order
- **Batch Operations**: Efficient bulk operations
- **Memory Management**: Proper object lifecycle management

### UI Updates
- **ObservableObject**: Automatic UI updates
- **Error Publishing**: Centralized error handling
- **State Management**: Proper state synchronization

## Best Practices

### Data Consistency
- Always save context after modifications
- Use proper error handling
- Implement rollback mechanisms
- Validate data before saving

### Performance
- Use batch operations for bulk changes
- Implement proper fetch request optimization
- Monitor memory usage
- Use background contexts for heavy operations

### User Experience
- Provide immediate feedback for actions
- Use haptic feedback for interactions
- Show clear error messages
- Implement proper loading states

## Future Enhancements

- **Card Import/Export**: Import cards from external sources
- **Card Statistics**: Detailed usage statistics
- **Bulk Operations**: Enhanced bulk editing capabilities
- **Card Sharing**: Share cards with other users 
