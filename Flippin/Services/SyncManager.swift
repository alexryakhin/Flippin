//
//  SyncManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import SwiftUI

@MainActor
final class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    @Published private(set) var syncState: SyncState = .idle
    @Published private(set) var lastSyncTime: Date?
    @Published private(set) var pendingOperations: Int = 0
    
    private var syncTimer: Timer?
    private var autoHideTimer: Timer?
    
    private init() {
        // Start periodic sync check
        startPeriodicSyncCheck()
    }
    
    // MARK: - Public Methods
    
    func startSync() {
        syncState = .syncing
        pendingOperations += 1
        
        // Auto-hide synced state after 2 seconds
        autoHideTimer?.invalidate()
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            Task { @MainActor in
                if self.syncState == .synced {
                    self.syncState = .idle
                }
            }
        }
    }
    
    func syncCompleted() {
        pendingOperations = max(0, pendingOperations - 1)
        
        if pendingOperations == 0 {
            syncState = .synced
            lastSyncTime = Date()
        }
    }
    
    func syncFailed() {
        pendingOperations = max(0, pendingOperations - 1)
        syncState = .error
        
        // Auto-hide error state after 3 seconds
        autoHideTimer?.invalidate()
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            Task { @MainActor in
                if self.syncState == .error {
                    self.syncState = .idle
                }
            }
        }
    }
    
    func resetSyncState() {
        syncState = .idle
        pendingOperations = 0
        autoHideTimer?.invalidate()
    }
    
    // MARK: - Private Methods
    
    private func startPeriodicSyncCheck() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task { @MainActor in
                // Check if there are any pending operations that might need attention
                if self.pendingOperations > 0 && self.syncState == .idle {
                    self.syncState = .syncing
                }
            }
        }
    }
    
    deinit {
        syncTimer?.invalidate()
        autoHideTimer?.invalidate()
    }
}

// MARK: - Convenience Extensions

extension SyncManager {
    func performSyncOperation<T>(_ operation: () async throws -> T) async throws -> T {
        startSync()
        
        do {
            let result = try await operation()
            syncCompleted()
            return result
        } catch {
            syncFailed()
            throw error
        }
    }
    
    func performSyncOperation<T>(_ operation: () throws -> T) throws -> T {
        startSync()
        
        do {
            let result = try operation()
            syncCompleted()
            return result
        } catch {
            syncFailed()
            throw error
        }
    }
} 