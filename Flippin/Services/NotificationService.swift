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

    private let studyReminderIdentifier = "study_reminder"
    private let difficultCardReminderIdentifier = "difficult_card_reminder"

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

        // Schedule for 8:30 PM tomorrow
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 30

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
                print("✅ Study reminder scheduled for tomorrow at 8:30 PM")
            }
        }
    }

    private func scheduleDifficultCardReminder() {
        let content = UNMutableNotificationContent()
        content.title = Loc.Notifications.difficultCardReminderTitle
        content.body = Loc.Notifications.difficultCardReminderBody
        content.sound = .default

        // Schedule for 4:30 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 16
        dateComponents.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: difficultCardReminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule difficult card reminder: \(error)")
            } else {
                print("✅ Difficult card reminder scheduled successfully")
            }
        }
    }

    private func scheduleDifficultCardReminderForToday() {
        let content = UNMutableNotificationContent()
        content.title = Loc.Notifications.difficultCardReminderTitle
        content.body = Loc.Notifications.difficultCardReminderBody
        content.sound = .default

        // Schedule for 4:30 PM today
        var dateComponents = DateComponents()
        dateComponents.hour = 16
        dateComponents.minute = 30

        let calendar = Calendar.current
        let now = Date()

        // If it's already past 4:30 PM today, schedule for tomorrow
        if let today430 = calendar.date(bySettingHour: 16, minute: 30, second: 0, of: now),
           now > today430 {
            dateComponents.day = calendar.component(.day, from: now) + 1
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(difficultCardReminderIdentifier)_\(Date().timeIntervalSince1970)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule difficult card reminder for today: \(error)")
            } else {
                print("✅ Difficult card reminder scheduled for today successfully")
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
    }

    private func saveNotificationSettings() {
        UserDefaults.standard.set(isStudyRemindersEnabled, forKey: UserDefaultsKey.studyRemindersEnabled)
        UserDefaults.standard.set(isDifficultCardRemindersEnabled, forKey: UserDefaultsKey.difficultCardRemindersEnabled)
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
