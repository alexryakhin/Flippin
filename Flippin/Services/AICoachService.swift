//
//  AICoachService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

final class AICoachService: ObservableObject {
    static let shared = AICoachService()
    
    @Published var lastInsight: CoachInsight?
    @Published var lastInsightDate: Date?
    
    private init() {
        loadLastInsight()
    }
    
    // MARK: - Public Methods
    
    /// Save a new coach insight with timestamp
    func saveInsight(_ insight: CoachInsight) {
        lastInsight = insight
        lastInsightDate = Date()
        
        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(insight) {
            UserDefaults.standard.set(data, forKey: UserDefaultsKey.lastCoachInsight)
        }
        UserDefaults.standard.set(lastInsightDate, forKey: UserDefaultsKey.lastCoachInsightDate)
        
        debugPrint("✅ Saved coach insight: \(insight.title)")
    }
    
    /// Check if insights should be refreshed (once per day)
    var shouldRefreshInsights: Bool {
        guard let lastDate = lastInsightDate else { return true }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Check if it's a new day since last insight
        return !calendar.isDate(lastDate, inSameDayAs: today)
    }
    
    /// Check if insights can be manually refreshed (cooldown period)
    var canManuallyRefresh: Bool {
        guard let lastDate = lastInsightDate else { return true }
        
        // Allow manual refresh after 1 hour
        return Date().timeIntervalSince(lastDate) > 3600
    }
    
    /// Get time until next automatic refresh is available
    var timeUntilNextRefresh: String {
        guard let lastDate = lastInsightDate else { return "Available now" }
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: lastDate) ?? Date()
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: Date(), to: startOfTomorrow) ?? "Tomorrow"
    }
    
    /// Clear stored insights (for testing or user preference)
    func clearInsights() {
        lastInsight = nil
        lastInsightDate = nil
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.lastCoachInsight)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.lastCoachInsightDate)
        
        debugPrint("🗑️ Cleared coach insights")
    }
    
    // MARK: - Private Methods
    
    private func loadLastInsight() {
        // Load last insight date
        if let date = UserDefaults.standard.object(forKey: UserDefaultsKey.lastCoachInsightDate) as? Date {
            lastInsightDate = date
        }
        
        // Load last insight data
        if let data = UserDefaults.standard.data(forKey: UserDefaultsKey.lastCoachInsight),
           let insight = try? JSONDecoder().decode(CoachInsight.self, from: data) {
            lastInsight = insight
            debugPrint("📖 Loaded coach insight: \(insight.title)")
        }
    }
}
