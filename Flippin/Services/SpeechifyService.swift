//
//  SpeechifyService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import AVFoundation
import CoreData

// MARK: - Speechify Models

struct SpeechifyTTSRequest: Codable {
    let input: String
    let voiceId: String
    let audioFormat: String
    let language: String?
    let model: String?
    
    enum CodingKeys: String, CodingKey {
        case input
        case voiceId = "voice_id"
        case audioFormat = "audio_format"
        case language
        case model
    }
}

struct SpeechifyTTSResponse: Codable {
    let audioData: String
    let audioFormat: String
    let billableCharactersCount: Int
    
    enum CodingKeys: String, CodingKey {
        case audioData = "audio_data"
        case audioFormat = "audio_format"
        case billableCharactersCount = "billable_characters_count"
    }
}

struct SpeechifyUsageResponse: Codable {
    let charactersUsed: Int
    let charactersLimit: Int
    let resetDate: String
    
    enum CodingKeys: String, CodingKey {
        case charactersUsed = "characters_used"
        case charactersLimit = "characters_limit"
        case resetDate = "reset_date"
    }
}

// MARK: - Speechify Service

final class SpeechifyService: NSObject, ObservableObject {
    static let shared = SpeechifyService()
    
    @Published var availableVoices: [SpeechifyVoice] = []
    @Published var selectedVoiceId: String = "nick"
    @Published var charactersUsed: Int = 0
    @Published var charactersLimit: Int = 50000
    @Published var listeningTimeMinutes: Double = 0.0
    private let coreDataService = CoreDataService.shared
    
    private let baseURL = "https://api.sws.speechify.com" // Speechify API base URL
    private let cache = NSCache<NSString, NSData>()
    private let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    
    private override init() {
        super.init()
        loadSettings()
        setupCache()
        loadUsageFromCoreData()
    }
    
    // MARK: - Public Methods
    
    /// Load available voices from Speechify json file
    func loadVoices() {
        guard availableVoices.isEmpty else { return }
        
        do {
            let voices = try getAvailableVoices()
            availableVoices = voices
            
            // Set default voice if none selected
            if selectedVoiceId.isEmpty && !voices.isEmpty {
                selectedVoiceId = voices.first?.id ?? ""
                saveSettings()
            }
            
            debugPrint("🎤 Loaded \(voices.count) Speechify voices")
        } catch {
            debugPrint("❌ Failed to load Speechify voices: \(error)")
        }
    }
    
    /// Synthesize text using Speechify TTS and return audio data
    func synthesizeText(_ text: String, language: Language) async throws -> Data {
        debugPrint("🎤 [SpeechifyService] synthesizeText() started - Thread: \(Thread.isMainThread ? "Main" : "Background")")
        debugPrint("🎤 [SpeechifyService] Text: '\(text.prefix(50))...', Language: \(language.rawValue)")
        
        guard !text.isEmpty else { 
            debugPrint("🎤 [SpeechifyService] Empty text error")
            throw SpeechifyError.emptyText 
        }
        guard hasEnoughCharacters(for: text) else { 
            debugPrint("🎤 [SpeechifyService] Character limit exceeded")
            throw SpeechifyError.characterLimitExceeded 
        }

        do {
            debugPrint("🎤 [SpeechifyService] Calling synthesizeSpeech()...")
            let audioData = try await synthesizeSpeech(text: text, language: language)
            debugPrint("🎤 [SpeechifyService] synthesizeSpeech() completed, got \(audioData.count) bytes")
            debugPrint("🎤 [SpeechifyService] Speechify TTS synthesized: \(text.count) characters")
            return audioData
        } catch {
            debugPrint("❌ [SpeechifyService] Speechify TTS failed: \(error)")
            throw error
        }
    }
    
    /// Check if we have enough characters without making an API call
    func canSynthesizeText(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        return hasEnoughCharacters(for: text)
    }
    
    /// Get current usage statistics and sync with CoreData
    func fetchUsage() async {
        do {
            let usage = try await fetchUsageFromAPI()
            charactersUsed = usage.charactersUsed
            charactersLimit = usage.charactersLimit
            saveUsageToCoreData()
        } catch {
            debugPrint("❌ Failed to fetch usage: \(error)")
        }
    }
    
    /// Check if user has enough characters remaining
    func hasEnoughCharacters(for text: String) -> Bool {
        return (charactersUsed + text.count) <= charactersLimit
    }
    
    /// Get remaining characters
    var remainingCharacters: Int {
        return max(0, charactersLimit - charactersUsed)
    }
    
    /// Get usage percentage
    var usagePercentage: Double {
        return Double(charactersUsed) / Double(charactersLimit) * 100
    }
    
    /// Select a voice
    func selectVoice(_ voiceId: String) {
        selectedVoiceId = voiceId
        saveSettings()
    }
    
    /// Get selected voice
    var selectedVoice: SpeechifyVoice? {
        return availableVoices.first { $0.id == selectedVoiceId }
    }
    
    #if DEBUG
    /// Debug method to test API response parsing
    func debugTestAPIResponse(_ text: String, language: Language) async throws {
        debugPrint("🔍 [SpeechifyService] DEBUG: Testing API response parsing...")
        
        guard let apiKey = getAPIKey() else {
            throw SpeechifyError.apiKeyNotConfigured
        }
        
        let url = URL(string: "\(baseURL)/v1/audio/speech")!
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10.0 // Short timeout for debugging
        
        let ttsRequest = SpeechifyTTSRequest(
            input: text,
            voiceId: selectedVoiceId,
            audioFormat: "mp3",
            language: language.speechifyCode,
            model: "simba-multilingual"
        )
        
        request.httpBody = try JSONEncoder().encode(ttsRequest)
        
        debugPrint("🔍 [SpeechifyService] DEBUG: Making API request...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        debugPrint("🔍 [SpeechifyService] DEBUG: Got response with \(data.count) bytes")
        debugPrint("🔍 [SpeechifyService] DEBUG: Response preview: \(String(data: data.prefix(200), encoding: .utf8) ?? "Invalid UTF-8")")
        
        if let httpResponse = response as? HTTPURLResponse {
            debugPrint("🔍 [SpeechifyService] DEBUG: HTTP status: \(httpResponse.statusCode)")
        }
    }
    #endif
    
    // MARK: - Private Methods
    
    func getAvailableVoices() throws -> [SpeechifyVoice] {
        return try Bundle.main.decode("speechify-voices.json")
    }

    private func synthesizeSpeech(text: String, language: Language) async throws -> Data {
        debugPrint("🎤 [SpeechifyService] synthesizeSpeech() started - Thread: \(Thread.isMainThread ? "Main" : "Background")")
        
        guard let apiKey = getAPIKey() else {
            debugPrint("🎤 [SpeechifyService] API key not configured")
            throw SpeechifyError.apiKeyNotConfigured
        }
        
        debugPrint("🎤 [SpeechifyService] API key found, creating request...")
        let url = URL(string: "\(baseURL)/v1/audio/speech")!
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0 // 30 second timeout
        
        let ttsRequest = SpeechifyTTSRequest(
            input: text,
            voiceId: selectedVoiceId,
            audioFormat: "mp3",
            language: language.rawValue,
            model: "simba-multilingual"
        )
        
        debugPrint("🎤 [SpeechifyService] Encoding request body...")
        request.httpBody = try JSONEncoder().encode(ttsRequest)
        
        debugPrint("🎤 [SpeechifyService] Making API request to Speechify...")
        
        // Add timeout protection to prevent UI freezing
        let (data, response) = try await withThrowingTaskGroup(of: (Data, URLResponse).self) { group in
            group.addTask {
                try await URLSession.shared.data(for: request)
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: 15_000_000_000) // 15 second timeout
                throw SpeechifyError.apiError("Request timeout after 15 seconds")
            }
            
            guard let result = try await group.next() else {
                throw SpeechifyError.apiError("No response received")
            }
            
            group.cancelAll()
            return result
        }
        debugPrint("🎤 [SpeechifyService] API request completed, got \(data.count) bytes")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            debugPrint("🎤 [SpeechifyService] API request failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw SpeechifyError.apiError("Failed to synthesize speech")
        }
        
        debugPrint("🎤 [SpeechifyService] Decoding response...")
        debugPrint("🎤 [SpeechifyService] Response data size: \(data.count) bytes")
        
        let ttsResponse: SpeechifyTTSResponse
        do {
            ttsResponse = try JSONDecoder().decode(SpeechifyTTSResponse.self, from: data)
        } catch {
            debugPrint("🎤 [SpeechifyService] JSON decode failed: \(error)")
            debugPrint("🎤 [SpeechifyService] Response preview: \(String(data: data.prefix(200), encoding: .utf8) ?? "Invalid UTF-8")")
            throw SpeechifyError.apiError("Failed to decode API response: \(error.localizedDescription)")
        }
        
        // Update character usage with actual billable count from API
        await MainActor.run {
            charactersUsed += ttsResponse.billableCharactersCount
        }
        saveUsageToCoreData()
        
        // Decode base64 audio data
        guard let audioData = Data(base64Encoded: ttsResponse.audioData) else {
            debugPrint("🎤 [SpeechifyService] Base64 decode failed for audio data")
            debugPrint("🎤 [SpeechifyService] Audio data string length: \(ttsResponse.audioData.count)")
            debugPrint("🎤 [SpeechifyService] Audio data preview: \(ttsResponse.audioData.prefix(100))")
            throw SpeechifyError.apiError("Failed to decode base64 audio data")
        }
        
        debugPrint("🎤 [SpeechifyService] Audio format: \(ttsResponse.audioFormat), Size: \(audioData.count) bytes")
        
        // Try to validate the audio data
        do {
            let testPlayer = try AVAudioPlayer(data: audioData)
            debugPrint("🎤 [SpeechifyService] Audio data validation successful")
            return audioData
        } catch {
            debugPrint("🎤 [SpeechifyService] Audio data validation failed: \(error)")
            // Try to convert the audio format if possible
            return try await convertAudioFormat(audioData, from: ttsResponse.audioFormat)
        }
    }
    
    private func fetchUsageFromAPI() async throws -> SpeechifyUsageResponse {
        guard let apiKey = getAPIKey() else {
            throw SpeechifyError.apiKeyNotConfigured
        }
        
        let url = URL(string: "\(baseURL)/usage")!
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SpeechifyError.apiError("Failed to fetch usage")
        }
        
        let usage = try JSONDecoder().decode(SpeechifyUsageResponse.self, from: data)
        return usage
    }
    
    /// Converts audio data to a format compatible with AVAudioPlayer
    private func convertAudioFormat(_ audioData: Data, from format: String) async throws -> Data {
        debugPrint("🎤 [SpeechifyService] Attempting to convert audio from \(format) to compatible format")
        
        // For now, we'll try to save the audio to a temporary file and re-read it
        // This sometimes helps with format issues
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_audio_\(UUID().uuidString).\(format)")
        
        do {
            // Write to temporary file
            try audioData.write(to: tempURL)
            
            // Try to read it back with AVAudioPlayer
            let convertedPlayer = try AVAudioPlayer(contentsOf: tempURL)
            debugPrint("🎤 [SpeechifyService] Audio conversion successful")
            
            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)
            
            return audioData // Return original data if file-based player works
        } catch {
            debugPrint("🎤 [SpeechifyService] Audio conversion failed: \(error)")
            
            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)
            
            // If conversion fails, throw the original error
            throw SpeechifyError.apiError("Audio format not supported: \(format)")
        }
    }
    
    
    private func setupCache() {
        cache.countLimit = 100 // Maximum 100 cached audio files
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    private func getLanguageCode(for language: Language) -> String {
        switch language {
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-BR"
        case .dutch: return "nl-NL"
        case .swedish: return "sv-SE"
        case .chinese: return "zh-CN"
        case .japanese: return "ja-JP"
        case .korean: return "ko-KR"
        case .vietnamese: return "vi-VN"
        case .russian: return "ru-RU"
        case .arabic: return "ar-SA"
        case .hindi: return "hi-IN"
        case .croatian: return "hr-HR"
        case .ukranian: return "uk-UA"
        }
    }
    
    // MARK: - Secure API Key Storage
    
    private func getAPIKey() -> String? {
        // Get API key from Firebase Remote Config
        if RemoteConfigService.shared.isRemoteConfigReady() {
            let remoteKey = RemoteConfigService.shared.getSpeechifyAPIKey()
            if !remoteKey.isEmpty {
                return remoteKey
            }
        }
        
        return nil
    }
    
    // MARK: - Settings Persistence
    
    private func loadSettings() {
        selectedVoiceId = UserDefaults.standard.string(forKey: UserDefaultsKey.speechifySelectedVoice) ?? ""
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(selectedVoiceId, forKey: UserDefaultsKey.speechifySelectedVoice)
    }
    
    // MARK: - Core Data Usage Management
    
    private func loadUsageFromCoreData() {
        let currentUsage = getCurrentMonthUsage()
        charactersUsed = Int(currentUsage.charactersUsed)
        charactersLimit = Int(currentUsage.charactersLimit)
        listeningTimeMinutes = currentUsage.listeningTimeMinutes
        
        debugPrint("📱 Loaded Speechify usage from Core Data - Characters: \(charactersUsed), Listening: \(listeningTimeMinutes) minutes")
    }
    
    private func saveUsageToCoreData() {
        // Check if we're already in a save context to prevent recursive saves
        guard !coreDataService.context.hasChanges else {
            debugPrint("⚠️ Core Data context already has changes, skipping save to prevent recursion")
            return
        }
        
        let currentUsage = getCurrentMonthUsage()
        currentUsage.charactersUsed = Int32(charactersUsed)
        currentUsage.charactersLimit = Int32(charactersLimit)
        currentUsage.listeningTimeMinutes = listeningTimeMinutes
        
        // Validate the object before saving
        guard currentUsage.id != nil && currentUsage.month != nil && currentUsage.resetDate != nil else {
            debugPrint("❌ Cannot save SpeechifyUsage - required properties are nil")
            return
        }
        
        do {
            try coreDataService.saveContext()
            debugPrint("💾 Saved Speechify usage to Core Data")
            
            // Force CloudKit sync check
            DispatchQueue.global(qos: .background).async {
                self.coreDataService.checkCloudKitSync()
            }
        } catch {
            debugPrint("❌ Failed to save Speechify usage: \(error)")
            // Don't throw the error to prevent app crashes
        }
    }
    
    private func getCurrentMonthUsage() -> SpeechifyUsage {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        let monthString = calendar.monthSymbols[month - 1]
        
        // Try to fetch existing usage for current month
        let fetchRequest = SpeechifyUsage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "month == %@ AND year == %d", monthString, year)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "resetDate", ascending: false)]
        
        do {
            let results = try coreDataService.context.fetch(fetchRequest)
            
            // If we have multiple records for the same month, merge them and keep the oldest one
            if results.count > 1 {
                debugPrint("⚠️ Found \(results.count) SpeechifyUsage records for \(monthString) \(year), merging...")
                
                let oldestRecord = results.last!
                var totalCharactersUsed: Int32 = 0
                var totalListeningTime: Double = 0.0
                
                for record in results {
                    totalCharactersUsed += record.charactersUsed
                    totalListeningTime += record.listeningTimeMinutes
                    
                    // Delete duplicate records (keep the oldest one)
                    if record != oldestRecord {
                        coreDataService.context.delete(record)
                        debugPrint("🗑️ Deleting duplicate record: \(record.id ?? "unknown")")
                    }
                }
                
                // Update the oldest record with merged totals
                oldestRecord.charactersUsed = totalCharactersUsed
                oldestRecord.listeningTimeMinutes = totalListeningTime
                
                try coreDataService.saveContext()
                debugPrint("✅ Merged \(results.count) records into one for \(monthString) \(year)")
                
                return oldestRecord
            } else if let existingUsage = results.first {
                return existingUsage
            }
        } catch {
            debugPrint("❌ Failed to fetch Speechify usage: \(error)")
        }
        
        // Create new usage record for current month - ensure all required properties are set
        let newUsage = SpeechifyUsage(context: coreDataService.context)
        newUsage.id = UUID().uuidString
        newUsage.month = monthString
        newUsage.year = Int32(year)
        newUsage.charactersUsed = 0
        newUsage.charactersLimit = Int32(charactersLimit)
        newUsage.listeningTimeMinutes = 0.0
        newUsage.resetDate = now
        
        // Validate the object before saving
        guard newUsage.id != nil && newUsage.month != nil && newUsage.resetDate != nil else {
            debugPrint("❌ Failed to create SpeechifyUsage - required properties are nil")
            // Return a fallback usage object
            return createFallbackUsageRecord(month: monthString, year: Int32(year))
        }
        
        do {
            try coreDataService.saveContext()
            debugPrint("✅ Created new Speechify usage record for \(monthString) \(year)")
        } catch {
            debugPrint("❌ Failed to create Speechify usage record: \(error)")
            // Return fallback if save fails
            return createFallbackUsageRecord(month: monthString, year: Int32(year))
        }
        
        return newUsage
    }
    
    private func createFallbackUsageRecord(month: String, year: Int32) -> SpeechifyUsage {
        // Create a fallback record that doesn't get saved to Core Data
        let fallback = SpeechifyUsage(context: coreDataService.context)
        fallback.id = "fallback-\(UUID().uuidString)"
        fallback.month = month
        fallback.year = year
        fallback.charactersUsed = 0
        fallback.charactersLimit = Int32(charactersLimit)
        fallback.listeningTimeMinutes = 0.0
        fallback.resetDate = Date()
        
        debugPrint("⚠️ Created fallback SpeechifyUsage record for \(month) \(year)")
        return fallback
    }
    
    private func resetMonthlyUsage() {
        let currentUsage = getCurrentMonthUsage()
        currentUsage.resetUsage()
        charactersUsed = 0
        listeningTimeMinutes = 0.0
        
        do {
            try coreDataService.saveContext()
            debugPrint("🔄 Reset Speechify usage for current month")
        } catch {
            debugPrint("❌ Failed to reset Speechify usage: \(error)")
        }
    }
    
    /// Force CloudKit sync for Speechify usage
    func forceCloudKitSync() {
        DispatchQueue.global(qos: .background).async {
            self.coreDataService.checkCloudKitSync()
        }
    }
    
    /// Debug: Print current usage data for troubleshooting
    func debugCurrentUsage() {
        let currentUsage = getCurrentMonthUsage()
        debugPrint("🔍 Debug - Current Speechify Usage:")
        debugPrint("   ID: \(currentUsage.id ?? "nil")")
        debugPrint("   Month: \(currentUsage.month ?? "nil")")
        debugPrint("   Year: \(currentUsage.year)")
        debugPrint("   Characters Used: \(currentUsage.charactersUsed)")
        debugPrint("   Characters Limit: \(currentUsage.charactersLimit)")
        debugPrint("   Listening Time: \(currentUsage.listeningTimeMinutes) minutes")
        debugPrint("   Reset Date: \(currentUsage.resetDate?.description ?? "nil")")
        debugPrint("   Published Values - Characters: \(charactersUsed), Listening: \(listeningTimeMinutes)")
    }
    
    /// Refresh usage data from CoreData (useful for checking sync)
    func refreshUsageFromCoreData() {
        loadUsageFromCoreData()
        debugPrint("🔄 Refreshed Speechify usage from Core Data")
    }
    
    /// Clean up duplicate records (run this once to fix existing duplicates)
    func cleanupDuplicateRecords() {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        let monthString = calendar.monthSymbols[month - 1]
        
        let fetchRequest = SpeechifyUsage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "month == %@ AND year == %d", monthString, year)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "resetDate", ascending: false)]
        
        do {
            let results = try coreDataService.context.fetch(fetchRequest)
            
            if results.count > 1 {
                debugPrint("🧹 Cleaning up \(results.count) duplicate records for \(monthString) \(year)")
                
                let oldestRecord = results.last!
                var totalCharactersUsed: Int32 = 0
                var totalListeningTime: Double = 0.0
                
                for record in results {
                    totalCharactersUsed += record.charactersUsed
                    totalListeningTime += record.listeningTimeMinutes
                    
                    if record != oldestRecord {
                        coreDataService.context.delete(record)
                        debugPrint("🗑️ Deleted duplicate: \(record.id ?? "unknown")")
                    }
                }
                
                oldestRecord.charactersUsed = totalCharactersUsed
                oldestRecord.listeningTimeMinutes = totalListeningTime
                
                try coreDataService.saveContext()
                debugPrint("✅ Cleanup complete - merged into one record")
                
                // Refresh the published values
                loadUsageFromCoreData()
            } else {
                debugPrint("✅ No duplicate records found")
            }
        } catch {
            debugPrint("❌ Failed to cleanup duplicates: \(error)")
        }
    }
    
    /// Get usage history for analytics
    func getUsageHistory(months: Int = 6) -> [SpeechifyUsage] {
        let calendar = Calendar.current
        let now = Date()
        
        var history: [SpeechifyUsage] = []
        
        for i in 0..<months {
            if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                let monthString = calendar.monthSymbols[month - 1]
                
                let fetchRequest = SpeechifyUsage.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "month == %@ AND year == %d", monthString, year)
                fetchRequest.fetchLimit = 1
                
                do {
                    let results = try coreDataService.context.fetch(fetchRequest)
                    if let usage = results.first {
                        history.append(usage)
                    }
                } catch {
                    debugPrint("❌ Failed to fetch usage history: \(error)")
                }
            }
        }
        
        return history.sorted { $0.monthYear < $1.monthYear }
    }
}


// MARK: - Speechify Errors

enum SpeechifyError: Error, LocalizedError {
    case apiKeyNotConfigured
    case emptyText
    case characterLimitExceeded
    case apiError(String)
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "Speechify API key not configured"
        case .emptyText:
            return "Text cannot be empty"
        case .characterLimitExceeded:
            return "Character limit exceeded for this month"
        case .apiError(let message):
            return "Speechify API error: \(message)"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response from Speechify API"
        }
    }
}
