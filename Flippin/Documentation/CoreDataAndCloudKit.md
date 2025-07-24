# Core Data & CloudKit Sync System

## Overview

The Core Data and CloudKit sync system provides persistent storage and seamless data synchronization across devices for the Flippin app. It ensures data integrity, offline functionality, and automatic conflict resolution.

## Architecture

### 1. Core Data Stack
- **NSPersistentCloudKitContainer**: Main container with CloudKit integration
- **NSManagedObjectContext**: Main context for data operations
- **NSPersistentStoreDescription**: CloudKit configuration
- **Automatic merging**: Changes from parent contexts

### 2. CloudKit Integration
- **Container ID**: `iCloud.com.dor.flippin`
- **Automatic sync**: Background synchronization
- **Conflict resolution**: Property-based merging
- **History tracking**: Persistent history for sync

## Data Models

### CardItem Entity
```swift
@objc(CardItem)
public final class CardItem: NSManagedObject, Identifiable {
    @NSManaged public var timestamp: Date?
    @NSManaged public var frontText: String?
    @NSManaged public var backText: String?
    @NSManaged public var frontLanguageRaw: String?
    @NSManaged public var backLanguageRaw: String?
    @NSManaged public var notes: String?
    @NSManaged public var id: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var tags: NSSet?
}
```

### Tag Entity
```swift
@objc(Tag)
public final class Tag: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var cards: NSSet?
}
```

## Core Data Service

### Initialization
```swift
public class CoreDataService: ObservableObject {
    public static let shared = CoreDataService()
    
    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
```

### Container Configuration
```swift
private lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let container = NSPersistentCloudKitContainer(name: "FlippinCoreDataModel")
    
    // Configure CloudKit
    guard let description = container.persistentStoreDescriptions.first else {
        fatalError("Failed to retrieve a persistent store description.")
    }
    
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = true
    
    // Configure CloudKit container
    let cloudKitOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.com.dor.flippin"
    )
    description.cloudKitContainerOptions = cloudKitOptions
    
    return container
}()
```

## Sync Management

### Automatic Sync
The system automatically handles CloudKit synchronization:

1. **Background Sync**: CloudKit syncs changes in the background
2. **Conflict Resolution**: Uses `NSMergeByPropertyObjectTrumpMergePolicy`
3. **Change Notifications**: Automatic UI updates when data changes
4. **History Tracking**: Maintains sync history for reliability

### Manual Sync Check
```swift
/// Force a CloudKit sync check (only used for initial empty cards check)
func checkCloudKitSync() {
    print("🔄 Forcing CloudKit sync check...")
    persistentContainer.viewContext.refreshAllObjects()
}
```

### Context Management
```swift
// Main context configuration
container.viewContext.automaticallyMergesChangesFromParent = true
container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
```

## Data Operations

### Saving Context
```swift
func saveContext() {
    do {
        try context.save()
        print("✅ Core Data context saved successfully")
    } catch {
        print("❌ Failed to save Core Data context: \(error)")
        // Handle error appropriately
    }
}
```

### Fetching Data
```swift
// Fetch cards with sorting
let request = CardItem.fetchRequest()
request.sortDescriptors = [NSSortDescriptor(keyPath: \CardItem.timestamp, ascending: true)]
let cards = try context.fetch(request)

// Fetch tags with sorting
let tagRequest = Tag.fetchRequest()
tagRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
let tags = try context.fetch(tagRequest)
```

### Creating Objects
```swift
// Create new card
let card = CardItem(context: CoreDataService.shared.context)
card.id = UUID().uuidString
card.timestamp = Date()
card.frontText = "Hello"
card.backText = "Hola"
card.frontLanguage = .english
card.backLanguage = .spanish

// Create new tag
let tag = Tag(context: CoreDataService.shared.context)
tag.id = UUID().uuidString
tag.name = "basics"
```

## CloudKit Sync Features

### Automatic Merging
- **Parent Context**: Changes automatically merge from parent contexts
- **Background Sync**: CloudKit syncs in background without blocking UI
- **Conflict Resolution**: Property-based merging prevents data loss
- **Change Notifications**: UI updates automatically when data changes

### Sync Status Monitoring
```swift
// Monitor sync status
persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

// Listen for remote changes
NotificationCenter.default.addObserver(
    forName: .NSPersistentCloudKitContainerEventChanged,
    object: persistentContainer,
    queue: .main
) { notification in
    // Handle sync events
    print("🔄 CloudKit sync event: \(notification)")
}
```

### Error Handling
```swift
container.loadPersistentStores { _, error in
    if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
    }
}
```

## Performance Optimizations

### Batch Operations
```swift
// Batch delete
let deleteRequest = NSBatchDeleteRequest(fetchRequest: CardItem.fetchRequest())
try context.execute(deleteRequest)

// Batch update
let updateRequest = NSBatchUpdateRequest(entityName: "CardItem")
updateRequest.propertiesToUpdate = ["isFavorite": false]
try context.execute(updateRequest)
```

### Memory Management
- **Automatic merging**: Reduces memory usage
- **Lazy loading**: Objects loaded only when needed
- **Context refresh**: Clears memory when appropriate

## Migration & Schema Changes

### Automatic Migration
```swift
description.shouldMigrateStoreAutomatically = true
description.shouldInferMappingModelAutomatically = true
```

### Schema Versioning
- **Core Data Model**: `FlippinCoreDataModel.xcdatamodeld`
- **Version Management**: Automatic version detection
- **Migration Paths**: Automatic migration between versions

## Troubleshooting

### Common Issues

#### Sync Not Working
1. Check iCloud account status
2. Verify CloudKit container configuration
3. Check network connectivity
4. Review CloudKit dashboard

#### Data Conflicts
1. Check merge policy configuration
2. Review conflict resolution strategy
3. Monitor sync events in logs

#### Performance Issues
1. Use batch operations for large datasets
2. Implement proper fetch request optimization
3. Monitor memory usage

### Debug Logging
```swift
// Enable Core Data logging
UserDefaults.standard.set(true, forKey: "com.apple.CoreData.Logging.stderr")

// Enable CloudKit logging
UserDefaults.standard.set(true, forKey: "com.apple.CoreData.CloudKitLogging")
```

## Best Practices

### Data Consistency
- Always save context after modifications
- Use proper error handling
- Implement rollback mechanisms
- Monitor sync status

### Performance
- Use batch operations for bulk changes
- Implement proper fetch request optimization
- Monitor memory usage
- Use background contexts for heavy operations

### Error Handling
- Implement comprehensive error handling
- Provide user-friendly error messages
- Log errors for debugging
- Implement retry mechanisms

## Integration with Other Services

### CardsProvider Integration
```swift
private let coreDataService = CoreDataService.shared

func fetchCards() {
    do {
        let request = CardItem.fetchRequest()
        let cards = try coreDataService.context.fetch(request)
        // Process cards
    } catch {
        errorPublisher.send(error)
    }
}
```

### TagManager Integration
```swift
private let coreDataService = CoreDataService.shared

func updateAvailableTags() {
    let request = Tag.fetchRequest()
    do {
        let tags = try coreDataService.context.fetch(request)
        availableTags = tags.sorted()
    } catch {
        print("Error fetching tags: \(error)")
    }
}
```

## Future Enhancements

- **Backup & Restore**: Enhanced backup capabilities 
