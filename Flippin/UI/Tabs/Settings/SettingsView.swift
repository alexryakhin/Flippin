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
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    @State private var newTagText = ""
    @State private var premiumFeature: PremiumFeature?

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
                view.frame(maxWidth: 500, alignment: .center)
            }
        }
        .navigation(
            title: LocalizationKeys.Settings.settings.localized,
            trailingContent: {
                HeaderButton(
                    LocalizationKeys.AboutApp.about.localized,
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
    }
    
    // MARK: - Languages Section
    private var languagesSection: some View {
        CustomSectionView(
            header: LocalizationKeys.Settings.languages.localized
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(LocalizationKeys.Settings.myLanguageSettings.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        HeaderButtonMenu(languageManager.userLanguage.displayName) {
                            Picker(
                                LocalizationKeys.Settings.myLanguageSettings.localized,
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
                    Text(LocalizationKeys.Settings.targetLanguage.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()
                    if purchaseService.hasPremiumAccess {
                        HeaderButtonMenu(languageManager.targetLanguage.displayName) {
                            Picker(LocalizationKeys.Settings.targetLanguage.localized, selection: $languageManager.targetLanguageRaw) {
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
                            Text(LocalizationKeys.Settings.filterByLanguage.localized)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(LocalizationKeys.Settings.filterByLanguageDescription.localized)
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
            header: LocalizationKeys.Settings.theme.localized
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(LocalizationKeys.Settings.color.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        ColorPicker("", selection: $colorManager.userColor)
                            .labelsHidden()
                    } else {
                        HeaderButton(LocalizationKeys.Settings.color.localized, icon: "crown.fill") {
                            premiumFeature = .customThemes
                        }
                    }
                }

                HStack(spacing: 2) {
                    Text(LocalizationKeys.Settings.backgroundStyle.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        HeaderButton(colorManager.backgroundStyle.displayName) {
                            navigationManager.navigate(to: .backgroundPreview)
                            AnalyticsService.trackEvent(.backgroundPreviewOpened)
                        }
                    } else {
                        HeaderButton(LocalizationKeys.Settings.previewBackgrounds.localized) {
                            navigationManager.navigate(to: .backgroundDemo)
                            AnalyticsService.trackEvent(.backgroundDemoOpened)
                        }
                    }
                }

                HStack(spacing: 2) {
                    Text(LocalizationKeys.Settings.colorScheme.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    HeaderButtonMenu(colorManager.userColorSchemePreference.localizedName) {
                        Picker(LocalizationKeys.Settings.colorScheme.localized, selection: $colorManager.userColorSchemePreference) {
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
            header: LocalizationKeys.Settings.notifications.localized
        ) {
            FormWithDivider {
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
    
    // MARK: - TTS Dashboard Section
    private var ttsDashboardSection: some View {
        Group {
            if purchaseService.hasPremiumAccess {
                CustomSectionView(
                    header: "Text-to-Speech"
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Configure Speechify TTS for premium voice quality")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HeaderButton(
                            "TTS Dashboard",
                            icon: "speaker.wave.3"
                        ) {
                            navigationManager.navigate(to: .ttsDashboard)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Card Display Section
    private var cardDisplaySection: some View {
        CustomSectionView(
            header: LocalizationKeys.Settings.cardDisplayMode.localized
        ) {
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    isTravelMode
                    ? LocalizationKeys.Settings.travelModeDescription.localized
                    : LocalizationKeys.Settings.learningModeDescription.localized
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Picker(LocalizationKeys.Settings.cardDisplayMode.localized, selection: $isTravelMode) {
                    Text(LocalizationKeys.Settings.learningMode.localized).tag(false)
                    Text(LocalizationKeys.Settings.travelMode.localized).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
                .onChange(of: isTravelMode) { _, newValue in
                    AnalyticsService.trackEvent(.travelModeToggled)
                }
            }
        }
    }
    
    // MARK: - Card Management Section
    private var cardManagementSection: some View {
        CustomSectionView(
            header: LocalizationKeys.Settings.cardManagement.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationKeys.Settings.cardManagementDescription.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HeaderButton(
                    LocalizationKeys.Settings.manageCards.localized,
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
            header: LocalizationKeys.Tag.tagsManagement.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    InputView(
                        LocalizationKeys.Tag.newTagName.localized,
                        text: $newTagText,
                        onSubmit: {
                            onAddTagButtonTap()
                        },
                        trailingButtonLabel: newTagText.isEmpty
                        ? LocalizationKeys.General.cancel.localized
                        : LocalizationKeys.Tag.addTag.localized,
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
                        Text(LocalizationKeys.Tag.availableTags.localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HFlow(spacing: 6) {
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                Menu {
                                    Button(LocalizationKeys.General.delete.localized, role: .destructive) {
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
                    Text(LocalizationKeys.Tag.noTagsAvailable.localized)
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
                    header: LocalizationKeys.Settings.subscriptionStatus.localized
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizationKeys.Settings.activeSubscription.localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colorManager.tintColor)
                                .font(.title2)
                        }
                        
                        HeaderButton(LocalizationKeys.Settings.manageSubscription.localized) {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
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
