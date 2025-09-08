//
//  RemoteConfigService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigService: ObservableObject {
    static let shared = RemoteConfigService()

    @Published var isConfigured = false
    @Published var lastFetchTime: Date?

    private let remoteConfig = RemoteConfig.remoteConfig()
    private let settings = RemoteConfigSettings()

    // Remote Config Keys
    private enum ConfigKey: String {
        case speechifyAPIKey = "speechify_api_key"
        case speechifyEnabled = "speechify_enabled"
        case speechifyCharacterLimit = "speechify_character_limit"
    }

    private init() {
        setupRemoteConfig()
    }

    // MARK: - Setup

    private func setupRemoteConfig() {
        // Configure settings
        settings.minimumFetchInterval = 3600 // 1 hour minimum
        remoteConfig.configSettings = settings

        // Set default values
        let defaults: [String: NSObject] = [
            ConfigKey.speechifyAPIKey.rawValue: "" as NSObject,
            ConfigKey.speechifyEnabled.rawValue: false as NSObject,
            ConfigKey.speechifyCharacterLimit.rawValue: 50000 as NSObject
        ]
        remoteConfig.setDefaults(defaults)

        print("🔧 Remote Config initialized")
    }

    // MARK: - Public Methods

    /// Fetch latest configuration from Firebase
    func fetchConfig() async {
        do {
            let _ = try await remoteConfig.fetchAndActivate()
            await MainActor.run {
                isConfigured = true
                lastFetchTime = Date()
            }

            print("✅ Remote Config fetched successfully")
            print("📊 Speechify enabled: \(getSpeechifyEnabled())")
            print("🔑 API Key configured: \(!getSpeechifyAPIKey().isEmpty)")
        } catch {
            print("❌ Failed to fetch Remote Config: \(error)")
            await MainActor.run {
                isConfigured = false
            }
        }
    }

    /// Get Speechify API key from Remote Config
    func getSpeechifyAPIKey() -> String {
        return remoteConfig.configValue(forKey: ConfigKey.speechifyAPIKey.rawValue).stringValue
    }

    /// Check if Speechify is enabled
    func getSpeechifyEnabled() -> Bool {
        return remoteConfig.configValue(forKey: ConfigKey.speechifyEnabled.rawValue).boolValue
    }

    /// Get character limit from Remote Config
    func getSpeechifyCharacterLimit() -> Int {
        return remoteConfig.configValue(forKey: ConfigKey.speechifyCharacterLimit.rawValue).numberValue.intValue
    }



    /// Check if Remote Config is properly configured
    func isRemoteConfigReady() -> Bool {
        return isConfigured && getSpeechifyEnabled() && !getSpeechifyAPIKey().isEmpty
    }

    /// Force refresh configuration
    func forceRefresh() async {
        do {
            _ = try await remoteConfig.fetch()
            try await remoteConfig.activate()
            isConfigured = true
            lastFetchTime = Date()

            print("🔄 Remote Config force refreshed")
        } catch {
            print("❌ Failed to force refresh Remote Config: \(error)")
        }
    }
}
