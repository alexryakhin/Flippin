//
//  NotificationService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import UserNotifications
import SwiftUI

final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    @Published var isStudyRemindersEnabled = false
    @Published var isDifficultCardRemindersEnabled = false
    @Published var hasNotificationPermission = false
    @Published var studyReminderTime: TimeInterval = 0 // Seconds since midnight
    @Published var difficultCardReminderTime: TimeInterval = 0 // Seconds since midnight

    private let studyReminderIdentifier = "study_reminder"
    private let difficultCardReminderIdentifier = "difficult_card_reminder"
    private let defaultStudyReminderTime: TimeInterval = 20 * 3600 + 30 * 60 // 8:30 PM
    private let defaultDifficultCardReminderTime: TimeInterval = 16 * 3600 + 30 * 60 // 4:30 PM

    private override init() {
        super.init()
        loadNotificationSettings()
        checkNotificationPermission()
    }

    // MARK: - Public Methods

    /// Request notification permission and enable notifications if granted
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.hasNotificationPermission = granted
            }
            return granted
        } catch {
            print("❌ Failed to request notification permission: \(error)")
            return false
        }
    }

    /// Toggle study reminders
    func toggleStudyReminders() async {
        if !isStudyRemindersEnabled {
            // Turning on - request permission first
            let granted = await requestNotificationPermission()
            if granted {
                await MainActor.run {
                    isStudyRemindersEnabled = true
                }
                // Don't schedule immediately - will be scheduled when user leaves app
                AnalyticsService.trackEvent(.studyRemindersEnabled)
            }
        } else {
            await MainActor.run {
                // Turning off
                isStudyRemindersEnabled = false
            }
            cancelStudyReminder()
            AnalyticsService.trackEvent(.studyRemindersDisabled)
        }

        saveNotificationSettings()
    }

    /// Toggle difficult card reminders
    func toggleDifficultCardReminders() async {
        if !isDifficultCardRemindersEnabled {
            // Turning on - request permission first
            let granted = await requestNotificationPermission()
            if granted {
                await MainActor.run {
                    isDifficultCardRemindersEnabled = true
                }
                AnalyticsService.trackEvent(.difficultCardRemindersEnabled)
                // Don't schedule immediately - only when user leaves app with difficult cards
            }
        } else {
            await MainActor.run {
                // Turning off
                isDifficultCardRemindersEnabled = false
            }
            cancelDifficultCardReminder()
            AnalyticsService.trackEvent(.difficultCardRemindersDisabled)
        }

        saveNotificationSettings()
    }

    /// Schedule notifications when user leaves app
    func scheduleNotificationsWhenLeavingApp() {
        // Schedule study reminder for tomorrow if enabled
        if isStudyRemindersEnabled && hasNotificationPermission {
            scheduleStudyReminder()
        }
        
        // Schedule difficult card reminder if enabled and user has difficult cards
        if isDifficultCardRemindersEnabled && hasNotificationPermission {
            Task { @MainActor in
                let difficultCards = LearningAnalyticsService.shared.getDifficultCardsNeedingReview()
                
                if !difficultCards.isEmpty {
                    scheduleDifficultCardReminderForToday()
                    AnalyticsService.trackEvent(.difficultCardReminderScheduled, parameters: [
                        "difficult_cards_count": difficultCards.count
                    ])
                }
            }
        }
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Reschedule study reminder when app becomes active
    func rescheduleStudyReminderIfNeeded() {
        guard isStudyRemindersEnabled && hasNotificationPermission else { return }
        
        // Check if there's a pending study reminder to reschedule
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let hasStudyReminder = requests.contains { $0.identifier == self.studyReminderIdentifier }
            
            if hasStudyReminder {
                DispatchQueue.main.async {
                    // Cancel current study reminder
                    self.cancelStudyReminder()
                    
                    // Schedule new reminder for tomorrow
                    self.scheduleStudyReminder()
                    
                    print("🔄 Study reminder rescheduled for tomorrow")
                }
            }
        }
    }

    // MARK: - Private Methods

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasNotificationPermission = settings.authorizationStatus == .authorized
            }
        }
    }

    private func scheduleStudyReminder() {
        let content = UNMutableNotificationContent()
        content.title = Loc.Notifications.studyReminderTitle
        content.body = Loc.Notifications.studyReminderBody
        content.sound = .default

        // Convert time interval to hour and minute
        let hour = Int(studyReminderTime / 3600)
        let minute = Int((studyReminderTime.truncatingRemainder(dividingBy: 3600)) / 60)

        // Schedule for tomorrow at the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        dateComponents.day = calendar.component(.day, from: tomorrow)
        dateComponents.month = calendar.component(.month, from: tomorrow)
        dateComponents.year = calendar.component(.year, from: tomorrow)

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: studyReminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule study reminder: \(error)")
            } else {
                print("✅ Study reminder scheduled for tomorrow at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    private func scheduleDifficultCardReminder() {
        let content = UNMutableNotificationContent()
        content.title = Loc.Notifications.difficultCardReminderTitle
        content.body = Loc.Notifications.difficultCardReminderBody
        content.sound = .default

        // Convert time interval to hour and minute
        let hour = Int(difficultCardReminderTime / 3600)
        let minute = Int((difficultCardReminderTime.truncatingRemainder(dividingBy: 3600)) / 60)

        // Schedule daily at the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: difficultCardReminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule difficult card reminder: \(error)")
            } else {
                print("✅ Difficult card reminder scheduled for \(hour):\(String(format: "%02d", minute)) daily")
            }
        }
    }

    private func scheduleDifficultCardReminderForToday() {
        let content = UNMutableNotificationContent()
        content.title = Loc.Notifications.difficultCardReminderTitle
        content.body = Loc.Notifications.difficultCardReminderBody
        content.sound = .default

        // Convert time interval to hour and minute
        let hour = Int(difficultCardReminderTime / 3600)
        let minute = Int((difficultCardReminderTime.truncatingRemainder(dividingBy: 3600)) / 60)

        // Schedule for today at the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let calendar = Calendar.current
        let now = Date()

        // If it's already past the specified time today, schedule for tomorrow
        if let todayTime = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now),
           now > todayTime {
            dateComponents.day = calendar.component(.day, from: now) + 1
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(difficultCardReminderIdentifier)_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule difficult card reminder for today: \(error)")
            } else {
                print("✅ Difficult card reminder scheduled for today at \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    private func cancelStudyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [studyReminderIdentifier])
    }

    private func cancelDifficultCardReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [difficultCardReminderIdentifier])
    }

    private func loadNotificationSettings() {
        isStudyRemindersEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKey.studyRemindersEnabled)
        isDifficultCardRemindersEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKey.difficultCardRemindersEnabled)
        
        // Load times or use defaults
        let savedStudyTime = UserDefaults.standard.double(forKey: UserDefaultsKey.studyReminderTime)
        studyReminderTime = savedStudyTime > 0 ? savedStudyTime : defaultStudyReminderTime
        
        let savedDifficultTime = UserDefaults.standard.double(forKey: UserDefaultsKey.difficultCardReminderTime)
        difficultCardReminderTime = savedDifficultTime > 0 ? savedDifficultTime : defaultDifficultCardReminderTime
    }

    private func saveNotificationSettings() {
        UserDefaults.standard.set(isStudyRemindersEnabled, forKey: UserDefaultsKey.studyRemindersEnabled)
        UserDefaults.standard.set(isDifficultCardRemindersEnabled, forKey: UserDefaultsKey.difficultCardRemindersEnabled)
        UserDefaults.standard.set(studyReminderTime, forKey: UserDefaultsKey.studyReminderTime)
        UserDefaults.standard.set(difficultCardReminderTime, forKey: UserDefaultsKey.difficultCardReminderTime)
    }
    
    /// Update study reminder time and reschedule if enabled
    func updateStudyReminderTime(_ time: TimeInterval) {
        studyReminderTime = time
        saveNotificationSettings()
        
        // Reschedule if enabled
        if isStudyRemindersEnabled && hasNotificationPermission {
            cancelStudyReminder()
            scheduleStudyReminder()
        }
    }
    
    /// Update difficult card reminder time and reschedule if enabled
    func updateDifficultCardReminderTime(_ time: TimeInterval) {
        difficultCardReminderTime = time
        saveNotificationSettings()
        
        // Reschedule if enabled
        if isDifficultCardRemindersEnabled && hasNotificationPermission {
            cancelDifficultCardReminder()
            scheduleDifficultCardReminder()
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        completionHandler()
    }
}
