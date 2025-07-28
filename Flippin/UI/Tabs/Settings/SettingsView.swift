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
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    @State private var newTagText = ""
    @State private var showingAddTagAlert = false
    @State private var showingBackgroundPreview = false
    @State private var showingBackgroundDemo = false
    @State private var showingPurchaseTest = false
    @State private var premiumFeature: PremiumFeature?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                languagesSection
                themeSection
                cardDisplaySection
                tagsManagementSection
                subscriptionManagementSection

                #if DEBUG
                purchaseTestingSection
                #endif
            }
            .padding(16)
        }
        .if(isPad) { view in
            view.frame(maxWidth: 500, alignment: .center)
        }
        .navigation(title: LocalizationKeys.settings.localized)
        .sheet(isPresented: $showingBackgroundPreview) {
            BackgroundPreviewView()
        }
        .sheet(isPresented: $showingBackgroundDemo) {
            BackgroundDemoView()
        }
        .sheet(isPresented: $showingPurchaseTest) {
            NavigationView {
                PurchaseTestView()
            }
        }
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
            header: LocalizationKeys.languages.localized
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(LocalizationKeys.myLanguageSettings.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        Picker(LocalizationKeys.myLanguageSettings.localized, selection: $languageManager.userLanguageRaw) {
                            ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                    } else {
                        Button {
                            premiumFeature = .languageChange
                        } label: {
                            HStack {
                                Text(languageManager.userLanguage.displayName)
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                    }
                }

                HStack(spacing: 2) {
                    Text(LocalizationKeys.targetLanguage.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()
                    if purchaseService.hasPremiumAccess {
                        Picker(LocalizationKeys.targetLanguage.localized, selection: $languageManager.targetLanguageRaw) {
                            ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                    } else {
                        Button {
                            premiumFeature = .languageChange
                        } label: {
                            HStack {
                                Text(languageManager.targetLanguage.displayName)
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
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
                            Text(LocalizationKeys.filterByLanguage.localized)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(LocalizationKeys.filterByLanguageDescription.localized)
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
            header: LocalizationKeys.theme.localized
        ) {
            FormWithDivider {
                HStack(spacing: 2) {
                    Text(LocalizationKeys.color.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        ColorPicker("", selection: $colorManager.userColor)
                            .labelsHidden()
                    } else {
                        Button {
                            premiumFeature = .customThemes
                        } label: {
                            HStack {
                                Circle()
                                    .fill(colorManager.userColor)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                    }
                }

                HStack(spacing: 2) {
                    Text(LocalizationKeys.backgroundStyle.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    if purchaseService.hasPremiumAccess {
                        Button(colorManager.backgroundStyle.displayName) {
                            showingBackgroundPreview = true
                            AnalyticsService.trackEvent(.backgroundPreviewOpened)
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                    } else {
                        Button(LocalizationKeys.previewBackgrounds.localized) {
                            showingBackgroundDemo = true
                            AnalyticsService.trackEvent(.backgroundDemoOpened)
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 2) {
                    Text(LocalizationKeys.colorScheme.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Picker(LocalizationKeys.colorScheme.localized, selection: $colorManager.userColorSchemePreference) {
                        ForEach(ColorSchemeInternal.allCases, id: \.self) { scheme in
                            Text(scheme.localizedName)
                                .tag(scheme)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())
                }
            }
        }
    }
    
    // MARK: - Card Display Section
    private var cardDisplaySection: some View {
        CustomSectionView(
            header: LocalizationKeys.cardDisplayMode.localized
        ) {
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    isTravelMode
                    ? LocalizationKeys.travelModeDescription.localized
                    : LocalizationKeys.learningModeDescription.localized
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Picker(LocalizationKeys.cardDisplayMode.localized, selection: $isTravelMode) {
                    Text(LocalizationKeys.learningMode.localized).tag(false)
                    Text(LocalizationKeys.travelMode.localized).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Tags Management Section
    private var tagsManagementSection: some View {
        CustomSectionView(
            header: LocalizationKeys.tagsManagement.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    InputView(
                        LocalizationKeys.newTagName.localized,
                        text: $newTagText,
                        onSubmit: {
                            onAddTagButtonTap()
                        },
                        trailingButtonLabel: newTagText.isEmpty
                        ? LocalizationKeys.cancel.localized
                        : LocalizationKeys.add.localized,
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
                        Text(LocalizationKeys.availableTags.localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HFlow(spacing: 6) {
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                SettingsTagButton(
                                    title: tag.name.orEmpty,
                                    onDelete: {
                                        tagManager.removeTag(tag)
                                    }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Text(LocalizationKeys.noTagsAvailable.localized)
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

    // MARK: - Purchase Testing Section (Debug Only)
    #if DEBUG
    private var purchaseTestingSection: some View {
        CustomSectionView(
            header: "Purchase Testing"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Test in-app purchases and get transaction IDs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Button("Open Purchase Test") {
                    showingPurchaseTest = true
                    AnalyticsService.trackEvent(.purchaseTestOpened)
                }
                .foregroundStyle(colorManager.borderedProminentForegroundColor)
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    #endif
    
    // MARK: - Subscription Management Section
    private var subscriptionManagementSection: some View {
        Group {
            if purchaseService.hasPremiumAccess {
                CustomSectionView(
                    header: LocalizationKeys.subscriptionStatus.localized
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(LocalizationKeys.activeSubscription.localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colorManager.tintColor)
                                .font(.title2)
                        }
                        
                        Button(LocalizationKeys.manageSubscription.localized) {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
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
