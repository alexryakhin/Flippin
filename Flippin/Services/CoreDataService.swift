//
//  CoreDataService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/15/25.
//

import Foundation
import CoreData
import Combine
import CloudKit

public class CoreDataService: ObservableObject {

    public static let shared = CoreDataService()

    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

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
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()

    private init() {}
    
    /// Force a CloudKit sync check (only used for initial empty cards check)
    public func checkCloudKitSync() {
        // Trigger a sync check by saving context on background queue
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                try self?.saveContext()
                print("☁️ Triggered CloudKit sync check")
            } catch {
                print("❌ Failed to trigger CloudKit sync: \(error)")
                AnalyticsService.trackErrorEvent(.errorOccurred, errorMessage: error.localizedDescription, errorCode: "cloudkit_sync_failed")
            }
        }
    }

    public func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
}
