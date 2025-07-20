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
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager =  ColorManager.shared
    @StateObject private var tagManager = TagManager.shared
    @AppStorage(UserDefaultsKey.cardDisplayMode) private var isTravelMode = false

    @State private var newTagText = ""
    @State private var showingAddTagAlert = false
    @State private var showingBackgroundPreview = false
    @State private var showingPurchaseTest = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    CustomSectionView(
                        header: LocalizationKeys.languages.localized
                    ) {
                        FormWithDivider {
                            CellWrapper {
                                Text(LocalizationKeys.myLanguageSettings.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            } trailingContent: {
                                Picker(LocalizationKeys.myLanguageSettings.localized, selection: $languageManager.userLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                            }

                            CellWrapper {
                                Text(LocalizationKeys.targetLanguage.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            } trailingContent: {
                                Picker(LocalizationKeys.targetLanguage.localized, selection: $languageManager.targetLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                            }

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
                                    .labelsHidden()
                            }
                        }
                        .clippedWithBackground()
                    }

                    CustomSectionView(
                        header: LocalizationKeys.background.localized
                    ) {
                        FormWithDivider {
                            CellWrapper {
                                Text(LocalizationKeys.backgroundColor.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            } trailingContent: {
                                ColorPicker("", selection: Binding(
                                    get: { colorManager.userGradientColor },
                                    set: { newColor in
                                        colorManager.setUserGradientColor(newColor)
                                        AnalyticsService.trackSettingsEvent(.backgroundColorChanged, newValue: newColor.description)
                                    }
                                ))
                                .labelsHidden()
                            }

                            CellWrapper {
                                Text(LocalizationKeys.backgroundStyle.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            } trailingContent: {
                                Button(colorManager.backgroundStyle.displayName) {
                                    showingBackgroundPreview = true
                                    AnalyticsService.trackNavigationEvent(.backgroundDemoOpened, screenName: "BackgroundDemo")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .clippedWithBackground()
                    }

                    CustomSectionView(
                        header: LocalizationKeys.cardDisplay.localized
                    ) {
                        FormWithDivider {
                            CellWrapper {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizationKeys.cardDisplayMode.localized)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Text(isTravelMode ? LocalizationKeys.travelModeDescription.localized : LocalizationKeys.learningModeDescription.localized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } trailingContent: {
                                Toggle("", isOn: $isTravelMode)
                                    .labelsHidden()
                            }
                        }
                        .clippedWithBackground()
                    }

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
                                        AnalyticsService.trackTagEvent(.tagAdded, tagName: newTagText, tagCount: tagManager.availableTags.count)
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
                                                title: tag,
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
            .sheet(isPresented: $showingPurchaseTest) {
                NavigationView {
                    PurchaseTestView()
                }
            }
        }
    }
}
