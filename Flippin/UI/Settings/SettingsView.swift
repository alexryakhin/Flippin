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
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.settings.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticService.shared.buttonTapped()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.secondary)
                }
            }
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
            .sheet(isPresented: $showPaywall) {
                Paywall.ContentView()
            }
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
                CellWrapper {
                    Text(LocalizationKeys.myLanguageSettings.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                } trailingContent: {
                    if purchaseService.hasPremiumAccess {
                        Picker(LocalizationKeys.myLanguageSettings.localized, selection: $languageManager.userLanguageRaw) {
                            ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        HStack {
                            Text(languageManager.userLanguage.displayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                    }
                }
                .onTapGesture {
                    if !purchaseService.hasPremiumAccess {
                        showPaywall = true
                    }
                }

                CellWrapper {
                    Text(LocalizationKeys.targetLanguage.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                } trailingContent: {
                    if purchaseService.hasPremiumAccess {
                        Picker(LocalizationKeys.targetLanguage.localized, selection: $languageManager.targetLanguageRaw) {
                            ForEach(Language.sortedByDisplayNameWithSystemFirst) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        HStack {
                            Text(languageManager.targetLanguage.displayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                                .font(.caption)
                        }
                    }
                }
                .onTapGesture {
                    if !purchaseService.hasPremiumAccess {
                        showPaywall = true
                    }
                }
                .onAppear {
                    if !purchaseService.hasPremiumAccess && languageManager.filterByLanguage == false {
                        languageManager.filterByLanguage = true
                    }
                }

                // Only show filter by language for premium users
                if purchaseService.hasPremiumAccess {
                    CellWrapper {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizationKeys.filterByLanguage.localized)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Text(LocalizationKeys.filterByLanguageDescription.localized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } trailingContent: {
                        Toggle("", isOn: $languageManager.filterByLanguage)
                            .disabled(!purchaseService.hasPremiumAccess)
                            .labelsHidden()
                    }
                }
            }
            .clippedWithBackground()
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        CustomSectionView(
            header: LocalizationKeys.theme.localized
        ) {
            FormWithDivider {
                CellWrapper {
                    Text(LocalizationKeys.color.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                } trailingContent: {
                    ColorPicker("", selection: $colorManager.userColor)
                        .labelsHidden()
                }

                CellWrapper {
                    Text(LocalizationKeys.backgroundStyle.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                } trailingContent: {
                    Button(LocalizationKeys.previewBackgrounds.localized) {
                        showingBackgroundPreview = true
                    }
                    .buttonStyle(.bordered)
                }

                CellWrapper {
                    Text(LocalizationKeys.colorScheme.localized)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                } trailingContent: {
                    Picker(LocalizationKeys.colorScheme.localized, selection: $colorManager.userColorSchemePreference) {
                        ForEach(ColorSchemeInternal.allCases, id: \.self) { scheme in
                            Text(scheme.localizedName)
                                .tag(scheme)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .clippedWithBackground()
        }
    }
    
    // MARK: - Card Display Section
    private var cardDisplaySection: some View {
        CustomSectionView(
            header: LocalizationKeys.cardDisplay.localized
        ) {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationKeys.cardDisplayMode.localized)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(isTravelMode ? LocalizationKeys.travelModeDescription.localized : LocalizationKeys.learningModeDescription.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker(LocalizationKeys.cardDisplayMode.localized, selection: $isTravelMode) {
                    Text(LocalizationKeys.learningMode.localized).tag(false)
                    Text(LocalizationKeys.travelMode.localized).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
            }
            .clippedWithPaddingAndBackground()
        }
    }
    
    // MARK: - Tags Management Section
    private var tagsManagementSection: some View {
        CustomSectionView(
            header: LocalizationKeys.tagsManagement.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField(LocalizationKeys.newTagName.localized, text: $newTagText)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        .textContentType(.nickname)

                    Button(LocalizationKeys.add.localized) {
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
                    .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .clippedWithPaddingAndBackground()
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
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clippedWithPaddingAndBackground()
        }
    }
    #endif
    
    // MARK: - Subscription Management Section
    private var subscriptionManagementSection: some View {
        Group {
            if purchaseService.hasPremiumAccess {
                CustomSectionView(
                    header: LocalizationKeys.subscription.localized
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizationKeys.subscriptionStatus.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(LocalizationKeys.activeSubscription.localized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .clippedWithPaddingAndBackground()
                }
            }
        }
    }
}
