# Notification System

## Overview

The Notification System provides intelligent study reminders and difficult card notifications to help users maintain consistent learning habits and focus on challenging content.

## Features

### Study Reminders
- **Daily Reminder**: Sends a notification at 8:30 PM the following day to remind users to study
- **Smart Scheduling**: Scheduled when user leaves app, for the following day at 8:30 PM
- **Smart Rescheduling**: If user opens app before notification fires, it's rescheduled for the next day
- **User Control**: Toggle on/off in Settings
- **Permission Request**: Requests notification permission when user toggles the setting on

### Difficult Card Reminders
- **Smart Scheduling**: Scheduled when user leaves app with difficult cards
- **Daily Timing**: Sends notification at 4:30 PM if scheduled
- **Conditional**: Only triggers if user has cards with difficulty level 4-5
- **User Control**: Toggle on/off in Settings

## Implementation

### NotificationService

Main service for managing notifications:

```swift
@MainActor
final class NotificationService: ObservableObject, UNUserNotificationCenterDelegate {
    @Published var isStudyRemindersEnabled = false
    @Published var isDifficultCardRemindersEnabled = false
    @Published var hasNotificationPermission = false
    
    // Request permission and enable notifications
    func requestNotificationPermission() async -> Bool
    
    // Toggle study reminders
    func toggleStudyReminders() async
    
    // Toggle difficult card reminders
    func toggleDifficultCardReminders() async
    
    // Schedule difficult card reminder when user leaves app
    func scheduleDifficultCardReminderIfNeeded()
}
```

### Permission Handling

```swift
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
```

### Study Reminder Scheduling

```swift
private func scheduleStudyReminder() {
    let content = UNMutableNotificationContent()
    content.title = LocalizationKeys.Notifications.studyReminderTitle.localized
    content.body = LocalizationKeys.Notifications.studyReminderBody.localized
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
    
    UNUserNotificationCenter.current().add(request)
}

// Reschedule when app becomes active
func rescheduleStudyReminderIfNeeded() {
    guard isStudyRemindersEnabled && hasNotificationPermission else { return }
    
    // Cancel current study reminder
    cancelStudyReminder()
    
    // Schedule new reminder for tomorrow
    scheduleStudyReminder()
}
```

### Notification Scheduling When Leaving App

```swift
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
```

## Integration Points

### App Lifecycle

Notifications are integrated with app lifecycle events:

```swift
// In FlippinApp.swift
.onChange(of: scenePhase) { _, newPhase in
    switch newPhase {
    case .background:
        AnalyticsService.trackEvent(.appBackgrounded)
        notificationService.scheduleDifficultCardReminderIfNeeded()
    case .active:
        AnalyticsService.trackEvent(.appForegrounded)
        notificationService.rescheduleStudyReminderIfNeeded()
    case .inactive:
        break
    @unknown default:
        break
    }
}
```

### Settings Integration

Notification controls are added to Settings:

```swift
// In SettingsView.swift
private var notificationsSection: some View {
    CustomSectionView(
        header: LocalizationKeys.Settings.notifications.localized
    ) {
        FormWithDivider {
            // Study Reminders Toggle
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationKeys.Settings.studyReminders.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(LocalizationKeys.Settings.studyRemindersDescription.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { notificationService.isStudyRemindersEnabled },
                    set: { _ in
                        Task {
                            await notificationService.toggleStudyReminders()
                        }
                    }
                ))
                .labelsHidden()
            }
            
            // Difficult Card Reminders Toggle
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationKeys.Settings.difficultCardReminders.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(LocalizationKeys.Settings.difficultCardRemindersDescription.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { notificationService.isDifficultCardRemindersEnabled },
                    set: { _ in
                        Task {
                            await notificationService.toggleDifficultCardReminders()
                        }
                    }
                ))
                .labelsHidden()
            }
        }
    }
}
```

## Localization

### English
```strings
"notifications" = "Notifications";
"studyReminders" = "Study Reminders";
"studyRemindersDescription" = "Get reminded to study at 8:30 PM daily";
"difficultCardReminders" = "Difficult Card Reminders";
"difficultCardRemindersDescription" = "Get reminded about difficult cards at 4:30 PM daily";
"studyReminderTitle" = "Time to Study!";
"studyReminderBody" = "Keep your learning streak going. Open Flippin to practice your flashcards.";
"difficultCardReminderTitle" = "Practice Difficult Cards";
"difficultCardReminderBody" = "You have some challenging cards that need attention. Time to review them!";
```

### Spanish
```strings
"notifications" = "Notificaciones";
"studyReminders" = "Recordatorios de Estudio";
"studyRemindersDescription" = "Recibe recordatorios para estudiar a las 8:30 PM diariamente";
"difficultCardReminders" = "Recordatorios de Tarjetas Difíciles";
"difficultCardRemindersDescription" = "Recibe recordatorios sobre tarjetas difíciles a las 4:30 PM diariamente";
"studyReminderTitle" = "¡Hora de Estudiar!";
"studyReminderBody" = "Mantén tu racha de aprendizaje. Abre Flippin para practicar tus tarjetas.";
"difficultCardReminderTitle" = "Practica Tarjetas Difíciles";
"difficultCardReminderBody" = "Tienes algunas tarjetas desafiantes que necesitan atención. ¡Hora de repasarlas!";
```

### French
```strings
"notifications" = "Notifications";
"studyReminders" = "Rappels d'Étude";
"studyRemindersDescription" = "Recevez des rappels pour étudier à 20h30 quotidiennement";
"difficultCardReminders" = "Rappels de Cartes Difficiles";
"difficultCardRemindersDescription" = "Recevez des rappels sur les cartes difficiles à 16h30 quotidiennement";
"studyReminderTitle" = "Heure d'Étudier !";
"studyReminderBody" = "Maintenez votre série d'apprentissage. Ouvrez Flippin pour pratiquer vos cartes.";
"difficultCardReminderTitle" = "Pratiquez les Cartes Difficiles";
"difficultCardReminderBody" = "Vous avez des cartes difficiles qui nécessitent attention. Il est temps de les réviser !";
```

## Analytics Integration

### Events Tracked

```swift
// Notification events added to AnalyticsEvent enum
case studyRemindersEnabled = "study_reminders_enabled"
case studyRemindersDisabled = "study_reminders_disabled"
case difficultCardRemindersEnabled = "difficult_card_reminders_enabled"
case difficultCardRemindersDisabled = "difficult_card_reminders_disabled"
case difficultCardReminderScheduled = "difficult_card_reminder_scheduled"
```

### Event Tracking

```swift
// Track when notifications are enabled/disabled
AnalyticsService.trackEvent(.studyRemindersEnabled)
AnalyticsService.trackEvent(.difficultCardRemindersEnabled)

// Track when difficult card reminders are scheduled
AnalyticsService.trackEvent(.difficultCardReminderScheduled, parameters: [
    "difficult_cards_count": difficultCards.count
])
```

## User Experience

### Permission Flow
1. User toggles notification setting to ON
2. System requests notification permission immediately
3. If granted, notifications are scheduled and enabled
4. If denied, setting remains off and no notifications are scheduled

### Haptic Feedback
- Button taps provide haptic feedback when toggling notifications
- Uses `HapticService.shared.buttonTapped()`

### Notification Display
- Notifications show even when app is in foreground
- Uses `UNUserNotificationCenterDelegate` to handle display

## Technical Considerations

### Background Processing
- Notifications are scheduled using `UNCalendarNotificationTrigger`
- Both study and difficult card reminders are scheduled when user leaves the app
- Study reminders are scheduled for the following day at 8:30 PM
- Difficult card reminders are scheduled for 4:30 PM if user has difficult cards
- Study reminders are rescheduled when app becomes active (if user opens app before 8:30 PM)

### State Management
- Notification settings are persisted in UserDefaults
- Service state is observable for UI updates
- Permission status is tracked and updated

### Error Handling
- Graceful handling of permission denial
- Error logging for notification scheduling failures
- Fallback behavior when notifications fail

## Future Enhancements

### Potential Features
- Customizable notification times
- Different notification frequencies
- Smart scheduling based on user behavior
- Notification categories and preferences
- Rich notifications with quick actions
- Notification history and management
