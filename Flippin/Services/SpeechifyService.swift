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

struct SpeechifyVoice: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    let gender: String
    let locale: String
    let type: String
    let avatarImage: String?
    let previewAudio: String?
    let tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case gender
        case locale
        case type
        case avatarImage = "avatar_image"
        case previewAudio = "preview_audio"
        case tags
    }
    
    // Computed properties for compatibility
    var name: String { displayName }
    var language: String { locale }
    var languageCode: String { locale }
    var voiceType: String { type }
    var sampleURL: String? { previewAudio }
}

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

@MainActor
final class SpeechifyService: NSObject, ObservableObject {
    static let shared = SpeechifyService()
    
    @Published var availableVoices: [SpeechifyVoice] = []
    @Published var selectedVoiceId: String = ""
    @Published var charactersUsed: Int = 0
    @Published var charactersLimit: Int = 50000
    @Published var listeningTimeMinutes: Double = 0.0
    @Published var isLoadingVoices: Bool = false
    @Published var isPlaying: Bool = false
    
    private let coreDataService = CoreDataService.shared
    
    private let baseURL = "https://api.sws.speechify.com" // Speechify API base URL
    private let cache = NSCache<NSString, NSData>()
    private let cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    private var player: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    private var playStartTime: Date?
    
    private override init() {
        super.init()
        loadSettings()
        setupCache()
        loadUsageFromCoreData()
    }
    
    // MARK: - Public Methods
    
    /// Load available voices from Speechify API
    func loadVoices() async {
        guard availableVoices.isEmpty else { return }
        
        isLoadingVoices = true
        defer { isLoadingVoices = false }
        
        do {
            let voices = try await fetchVoices()
            availableVoices = voices
            
            // Set default voice if none selected
            if selectedVoiceId.isEmpty && !voices.isEmpty {
                selectedVoiceId = voices.first?.id ?? ""
                saveSettings()
            }
            
            print("🎤 Loaded \(voices.count) Speechify voices")
        } catch {
            print("❌ Failed to load Speechify voices: \(error)")
        }
    }
    
    /// Play text using Speechify TTS
    func playText(_ text: String, language: Language) async throws {
        guard !text.isEmpty else { return }
        guard !isPlaying else { throw SpeechifyError.alreadyPlaying }
        guard hasEnoughCharacters(for: text) else { throw SpeechifyError.characterLimitExceeded }
        
        isPlaying = true
        defer { isPlaying = false }
        
        do {
            let audioData = try await synthesizeSpeech(text: text, language: language)
            try await playAudio(audioData)
            
            print("🎤 Speechify TTS played: \(text.count) characters")
        } catch {
            print("❌ Speechify TTS failed: \(error)")
            throw error
        }
    }
    
    /// Get current usage statistics and sync with CoreData
    func fetchUsage() async {
        do {
            let usage = try await fetchUsageFromAPI()
            charactersUsed = usage.charactersUsed
            charactersLimit = usage.charactersLimit
            saveUsageToCoreData()
        } catch {
            print("❌ Failed to fetch usage: \(error)")
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
    
    /// Get voices for a specific language
    func getVoices(for language: Language) -> [SpeechifyVoice] {
        let languageCode = getLanguageCode(for: language)
        return availableVoices.filter { $0.languageCode == languageCode }
    }
    
    // MARK: - Private Methods
    
    private func fetchVoices() async throws -> [SpeechifyVoice] {
        guard let apiKey = getAPIKey() else {
            throw SpeechifyError.apiKeyNotConfigured
        }
        
        let url = URL(string: "\(baseURL)/v1/voices")!
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SpeechifyError.apiError("Failed to fetch voices")
        }
        
        let voices = try JSONDecoder().decode([SpeechifyVoice].self, from: data)
        return voices
    }
    
    private func synthesizeSpeech(text: String, language: Language) async throws -> Data {
        guard let apiKey = getAPIKey() else {
            throw SpeechifyError.apiKeyNotConfigured
        }
        
        let url = URL(string: "\(baseURL)/v1/audio/speech")!
        var request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ttsRequest = SpeechifyTTSRequest(
            input: text,
            voiceId: selectedVoiceId,
            audioFormat: "wav",
            language: language.rawValue,
            model: "simba-multilingual"
        )
        
        request.httpBody = try JSONEncoder().encode(ttsRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SpeechifyError.apiError("Failed to synthesize speech")
        }
        
        let ttsResponse = try JSONDecoder().decode(SpeechifyTTSResponse.self, from: data)
        
        // Update character usage with actual billable count from API
        charactersUsed += ttsResponse.billableCharactersCount
        saveUsageToCoreData()
        
        // Decode base64 audio data
        guard let audioData = Data(base64Encoded: ttsResponse.audioData) else {
            throw SpeechifyError.apiError("Failed to decode audio data")
        }
        
        return audioData
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
    
    private func playAudio(_ audioData: Data) async throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
        try session.setActive(true)
        #endif
        
        player = try AVAudioPlayer(data: audioData)
        player?.delegate = self
        player?.prepareToPlay()
        
        // Start tracking listening time
        playStartTime = Date()
        player?.play()
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
        
        print("📱 Loaded Speechify usage from Core Data - Characters: \(charactersUsed), Listening: \(listeningTimeMinutes) minutes")
    }
    
    private func saveUsageToCoreData() {
        let currentUsage = getCurrentMonthUsage()
        currentUsage.charactersUsed = Int32(charactersUsed)
        currentUsage.charactersLimit = Int32(charactersLimit)
        currentUsage.listeningTimeMinutes = listeningTimeMinutes
        
        do {
            try coreDataService.saveContext()
            print("💾 Saved Speechify usage to Core Data")
            
            // Force CloudKit sync check
            DispatchQueue.global(qos: .background).async {
                self.coreDataService.checkCloudKitSync()
            }
        } catch {
            print("❌ Failed to save Speechify usage: \(error)")
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
                print("⚠️ Found \(results.count) SpeechifyUsage records for \(monthString) \(year), merging...")
                
                let oldestRecord = results.last!
                var totalCharactersUsed: Int32 = 0
                var totalListeningTime: Double = 0.0
                
                for record in results {
                    totalCharactersUsed += record.charactersUsed
                    totalListeningTime += record.listeningTimeMinutes
                    
                    // Delete duplicate records (keep the oldest one)
                    if record != oldestRecord {
                        coreDataService.context.delete(record)
                        print("🗑️ Deleting duplicate record: \(record.id ?? "unknown")")
                    }
                }
                
                // Update the oldest record with merged totals
                oldestRecord.charactersUsed = totalCharactersUsed
                oldestRecord.listeningTimeMinutes = totalListeningTime
                
                try coreDataService.saveContext()
                print("✅ Merged \(results.count) records into one for \(monthString) \(year)")
                
                return oldestRecord
            } else if let existingUsage = results.first {
                return existingUsage
            }
        } catch {
            print("❌ Failed to fetch Speechify usage: \(error)")
        }
        
        // Create new usage record for current month
        let newUsage = SpeechifyUsage(context: coreDataService.context)
        newUsage.id = UUID().uuidString
        newUsage.month = monthString
        newUsage.year = Int32(year)
        newUsage.charactersUsed = 0
        newUsage.charactersLimit = Int32(charactersLimit)
        newUsage.listeningTimeMinutes = 0.0
        newUsage.resetDate = now
        
        do {
            try coreDataService.saveContext()
            print("✅ Created new Speechify usage record for \(monthString) \(year)")
        } catch {
            print("❌ Failed to create Speechify usage record: \(error)")
        }
        
        return newUsage
    }
    
    private func resetMonthlyUsage() {
        let currentUsage = getCurrentMonthUsage()
        currentUsage.resetUsage()
        charactersUsed = 0
        listeningTimeMinutes = 0.0
        
        do {
            try coreDataService.saveContext()
            print("🔄 Reset Speechify usage for current month")
        } catch {
            print("❌ Failed to reset Speechify usage: \(error)")
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
        print("🔍 Debug - Current Speechify Usage:")
        print("   ID: \(currentUsage.id ?? "nil")")
        print("   Month: \(currentUsage.month ?? "nil")")
        print("   Year: \(currentUsage.year)")
        print("   Characters Used: \(currentUsage.charactersUsed)")
        print("   Characters Limit: \(currentUsage.charactersLimit)")
        print("   Listening Time: \(currentUsage.listeningTimeMinutes) minutes")
        print("   Reset Date: \(currentUsage.resetDate?.description ?? "nil")")
        print("   Published Values - Characters: \(charactersUsed), Listening: \(listeningTimeMinutes)")
    }
    
    /// Refresh usage data from CoreData (useful for checking sync)
    func refreshUsageFromCoreData() {
        loadUsageFromCoreData()
        print("🔄 Refreshed Speechify usage from Core Data")
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
                print("🧹 Cleaning up \(results.count) duplicate records for \(monthString) \(year)")
                
                let oldestRecord = results.last!
                var totalCharactersUsed: Int32 = 0
                var totalListeningTime: Double = 0.0
                
                for record in results {
                    totalCharactersUsed += record.charactersUsed
                    totalListeningTime += record.listeningTimeMinutes
                    
                    if record != oldestRecord {
                        coreDataService.context.delete(record)
                        print("🗑️ Deleted duplicate: \(record.id ?? "unknown")")
                    }
                }
                
                oldestRecord.charactersUsed = totalCharactersUsed
                oldestRecord.listeningTimeMinutes = totalListeningTime
                
                try coreDataService.saveContext()
                print("✅ Cleanup complete - merged into one record")
                
                // Refresh the published values
                loadUsageFromCoreData()
            } else {
                print("✅ No duplicate records found")
            }
        } catch {
            print("❌ Failed to cleanup duplicates: \(error)")
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
                    print("❌ Failed to fetch usage history: \(error)")
                }
            }
        }
        
        return history.sorted { $0.monthYear < $1.monthYear }
    }
}

// MARK: - AVAudioPlayerDelegate

extension SpeechifyService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            isPlaying = false
            updateListeningTime()
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            isPlaying = false
        }
        print("❌ Audio player error: \(error?.localizedDescription ?? "Unknown error")")
    }
    
    private func updateListeningTime() {
        guard let startTime = playStartTime else { return }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        let minutes = duration / 60.0
        
        listeningTimeMinutes += minutes
        saveUsageToCoreData()
        
        print("🎧 Added \(String(format: "%.2f", minutes)) minutes to listening time")
        playStartTime = nil
        
        // Debug: Print current usage for verification
        print("📊 Current usage - Characters: \(charactersUsed), Listening Time: \(String(format: "%.2f", listeningTimeMinutes)) minutes")
    }
}

// MARK: - Speechify Errors

enum SpeechifyError: Error, LocalizedError {
    case apiKeyNotConfigured
    case alreadyPlaying
    case characterLimitExceeded
    case apiError(String)
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "Speechify API key not configured"
        case .alreadyPlaying:
            return "Speechify TTS is already playing"
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
