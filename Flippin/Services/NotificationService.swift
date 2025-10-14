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
            debugPrint("❌ Failed to request notification permission: \(error)")
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
                scheduleStudyReminder()
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
                // Schedule immediately if there are difficult cards
                let difficultCards = await LearningAnalyticsService.shared.getDifficultCardsNeedingReview()
                if !difficultCards.isEmpty {
                    scheduleDifficultCardReminder()
                }
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
        // Only reschedule difficult card reminder when leaving app (to check current difficult cards)
        // Study reminder is already scheduled with repeats: true, so no need to reschedule
        if isDifficultCardRemindersEnabled && hasNotificationPermission {
            Task { @MainActor in
                let difficultCards = LearningAnalyticsService.shared.getDifficultCardsNeedingReview()
                
                if !difficultCards.isEmpty {
                    // Only schedule if not already scheduled
                    let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                    let hasDifficultCardReminder = requests.contains { $0.identifier == self.difficultCardReminderIdentifier }
                    if !hasDifficultCardReminder {
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            scheduleDifficultCardReminder()
                            AnalyticsService.trackEvent(.difficultCardReminderScheduled, parameters: [
                                "difficult_cards_count": difficultCards.count
                            ])
                        }
                    }
                } else {
                    // Cancel if no difficult cards
                    cancelDifficultCardReminder()
                }
            }
        }
    }

    /// Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
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

        // Schedule daily at the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: studyReminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                debugPrint("❌ Failed to schedule study reminder: \(error)")
            } else {
                debugPrint("✅ Study reminder scheduled daily at \(hour):\(String(format: "%02d", minute))")
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
                debugPrint("❌ Failed to schedule difficult card reminder: \(error)")
            } else {
                debugPrint("✅ Difficult card reminder scheduled for \(hour):\(String(format: "%02d", minute)) daily")
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
