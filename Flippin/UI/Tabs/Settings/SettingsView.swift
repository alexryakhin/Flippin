//
//  SettingsView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import Flow

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager =  ColorManager.shared
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var profileService = UserProfileService.shared
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    @State private var newTagText = ""
    @State private var premiumFeature: PremiumFeature?
    @State private var showingVoicePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                languagesSection
                themeSection
                cardDisplaySection
                notificationsSection
                ttsDashboardSection
                cardManagementSection
                tagsManagementSection
                subscriptionManagementSection
            }
            .padding(16)
            .if(isPad) { view in
                view.frame(maxWidth: 550, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .scrollClipDisabled()
        .navigation(
            title: Loc.NavigationTitles.settings,
            trailingContent: {
                HeaderButton(
                    Loc.AboutApp.about,
                    size: .large,
                    style: .borderedProminent
                ) {
                    navigationManager.navigate(to: .about)
                }
            }
        )
        .premiumAlert(feature: $premiumFeature)
        .onAppear {
            AnalyticsService.trackEvent(.settingsScreenOpened)
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .background {
            AnimatedBackground(style: colorManager.backgroundStyle)
        }
    }
    
    // MARK: - Languages Section
    private var languagesSection: some View {
        CustomSectionView(
            header: Loc.Settings.languages
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(Loc.PresetCollections.myLanguageSettings)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        HeaderButtonMenu(languageManager.userLanguage.displayName) {
                            Picker(
                                Loc.PresetCollections.myLanguageSettings,
                                selection: $languageManager.userLanguageRaw
                            ) {
                                ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                    } else {
                        HeaderButton(
                            languageManager.userLanguage.displayName,
                            icon: "crown.fill"
                        ) {
                            premiumFeature = .languageChange
                        }
                    }
                }

                HStack(spacing: 2) {
                    Text(Loc.PresetCollections.targetLanguage)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()
                    if purchaseService.hasPremiumAccess {
                        HeaderButtonMenu(languageManager.targetLanguage.displayName) {
                            Picker(Loc.PresetCollections.targetLanguage, selection: $languageManager.targetLanguageRaw) {
                                ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                    } else {
                        HeaderButton(
                            languageManager.targetLanguage.displayName,
                            icon: "crown.fill"
                        ) {
                            premiumFeature = .languageChange
                        }
                    }
                }
                .onAppear {
                    if !purchaseService.hasPremiumAccess && languageManager.filterByLanguage == false {
                        languageManager.filterByLanguage = true
                    }
                }

                // Only show filter by language for premium users
                if purchaseService.hasPremiumAccess {
                    HStack(spacing: 2) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Loc.TagManagement.filterByLanguage)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(Loc.TagManagement.filterByLanguageDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $languageManager.filterByLanguage)
                            .disabled(!purchaseService.hasPremiumAccess)
                            .labelsHidden()
                    }
                }
            }
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        CustomSectionView(
            header: Loc.PresetCollections.theme
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(Loc.PresetCollections.color)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        ColorPicker("", selection: $colorManager.userColor)
                            .labelsHidden()
                    } else {
                        HeaderButton(Loc.PresetCollections.color, icon: "crown.fill") {
                            premiumFeature = .customThemes
                        }
                    }
                }

                HStack(spacing: 2) {
                    Text(Loc.PresetCollections.backgroundStyle)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        HeaderButton(colorManager.backgroundStyle.displayName) {
                            navigationManager.navigate(to: .backgroundPreview)
                            AnalyticsService.trackEvent(.backgroundPreviewOpened)
                        }
                    } else {
                        HeaderButton(Loc.Settings.previewBackgrounds) {
                            navigationManager.navigate(to: .backgroundDemo)
                            AnalyticsService.trackEvent(.backgroundDemoOpened)
                        }
                    }
                }

                HStack(spacing: 2) {
                    Text(Loc.PremiumFeatures.colorScheme)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    HeaderButtonMenu(colorManager.userColorSchemePreference.localizedName) {
                        Picker(Loc.PremiumFeatures.colorScheme, selection: $colorManager.userColorSchemePreference) {
                            ForEach(ColorSchemeInternal.allCases, id: \.self) { scheme in
                                Text(scheme.localizedName)
                                    .tag(scheme)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                }
            }
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        CustomSectionView(
            header: Loc.Notifications.notifications
        ) {
            FormWithDivider {
                // Study Reminders Toggle
                HStack(spacing: 2) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Loc.Notifications.studyReminders)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Text(Loc.Notifications.studyRemindersDescription)
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
                
                // Study Reminders Time Picker
                if notificationService.isStudyRemindersEnabled {
                    HStack(spacing: 2) {
                        Text(Loc.Notifications.time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { timeIntervalToDate(notificationService.studyReminderTime) },
                                set: { newDate in
                                    let timeInterval = dateToTimeInterval(newDate)
                                    notificationService.updateStudyReminderTime(timeInterval)
                                    HapticService.shared.selection()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                }

                // Difficult Card Reminders Toggle
                HStack(spacing: 2) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Loc.Notifications.difficultCardReminders)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Text(Loc.Notifications.difficultCardRemindersDescription)
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
                
                // Difficult Card Reminders Time Picker
                if notificationService.isDifficultCardRemindersEnabled {
                    HStack(spacing: 2) {
                        Text(Loc.Notifications.time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { timeIntervalToDate(notificationService.difficultCardReminderTime) },
                                set: { newDate in
                                    let timeInterval = dateToTimeInterval(newDate)
                                    notificationService.updateDifficultCardReminderTime(timeInterval)
                                    HapticService.shared.selection()
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods for Time Conversion
    
    /// Convert time interval (seconds since midnight) to Date
    private func timeIntervalToDate(_ timeInterval: TimeInterval) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return startOfDay.addingTimeInterval(timeInterval)
    }
    
    /// Convert Date to time interval (seconds since midnight)
    private func dateToTimeInterval(_ date: Date) -> TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return date.timeIntervalSince(startOfDay)
    }
    
    // MARK: - TTS Dashboard Section
    private var ttsDashboardSection: some View {
        CustomSectionView(
            header: Loc.Tts.Settings.textToSpeech
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if purchaseService.hasPremiumAccess {
                    Text(Loc.Tts.Settings.speechifyProDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HeaderButton(
                        Loc.Tts.Settings.dashboard,
                        icon: "speaker.wave.3"
                    ) {
                        navigationManager.navigate(to: .ttsDashboard)
                    }
                } else {
                    Text(Loc.Tts.Settings.speechifyDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HeaderButton(
                        Loc.Tts.Filters.selectVoice,
                        icon: "speaker.wave.3"
                    ) {
                        showingVoicePicker = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingVoicePicker) {
            VoicePickerView()
        }
    }
    
    // MARK: - Card Display Section
    private var cardDisplaySection: some View {
        CustomSectionView(
            header: Loc.Settings.cardDisplayMode
        ) {
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    isTravelMode
                    ? Loc.Settings.travelModeDescription
                    : Loc.Settings.learningModeDescription
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Picker(Loc.Settings.cardDisplayMode, selection: $isTravelMode) {
                    Text(Loc.Settings.learningMode).tag(false)
                    Text(Loc.Settings.travelMode).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
                .onChange(of: isTravelMode) { _, newValue in
                    profileService.updateProfile(prefersTravelMode: newValue)
                    AnalyticsService.trackEvent(.travelModeToggled)
                }
            }
        }
    }
    
    // MARK: - Card Management Section
    private var cardManagementSection: some View {
        CustomSectionView(
            header: Loc.Settings.cardManagement
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Loc.Settings.cardManagementDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HeaderButton(
                    Loc.Settings.manageCards,
                    icon: "list.bullet.rectangle"
                ) {
                    navigationManager.navigate(to: .cardManagement)
                }
            }
        }
    }
    
    // MARK: - Tags Management Section
    private var tagsManagementSection: some View {
        CustomSectionView(
            header: Loc.TagManagement.tagsManagement
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    InputView(
                        Loc.TagManagement.newTagName,
                        text: $newTagText,
                        onSubmit: {
                            onAddTagButtonTap()
                        },
                        trailingButtonLabel: newTagText.isEmpty
                        ? Loc.Buttons.cancel
                        : Loc.TagManagement.addTag,
                        onTrailingButtonTap: {
                            onAddTagButtonTap()
                        },
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .textContentType(.nickname)
                    .animation(.default, value: newTagText.isEmpty)
                }
                
                if !tagManager.availableTags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Loc.TagManagement.availableTags)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HFlow(spacing: 6) {
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                Menu {
                                    Button(Loc.Buttons.delete, role: .destructive) {
                                        tagManager.removeTag(tag)
                                    }
                                } label: {
                                    TagView(title: tag.name.orEmpty, isSelected: false)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Text(Loc.TagManagement.noTagsAvailable)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
        }
    }

    private func onAddTagButtonTap() {
        HapticService.shared.buttonTapped()
        if !newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            tagManager.addTag(newTagText)
            AnalyticsService.trackTagEvent(
                .tagAdded,
                tagName: newTagText,
                tagCount: tagManager.availableTags.count
            )
            newTagText = ""
        }
    }

    // MARK: - Subscription Management Section
    private var subscriptionManagementSection: some View {
        Group {
            if purchaseService.hasPremiumAccess {
                CustomSectionView(
                    header: Loc.SubscriptionManagement.subscriptionStatus
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(Loc.SubscriptionManagement.activeSubscription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colorManager.tintColor)
                                .font(.title2)
                        }
                        
                    HeaderButton(Loc.SubscriptionManagement.manageSubscription) {
                        if let url = URL(string: PrivateConstants.appStoreSubscriptionsURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .background {
            AnimatedBackground(style: .bubbles)
        }
}
