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
    @AppStorage(UserDefaultsKey.userLanguage) private var userLanguageRaw: String = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en")?.rawValue ?? Language.english.rawValue
    @AppStorage(UserDefaultsKey.targetLanguage) private var targetLanguageRaw: String = Language.spanish.rawValue

    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager()
    @StateObject private var tagManager = TagManager()
    @State private var newTagText = ""
    @State private var showingAddTagAlert = false
    @State private var showingBackgroundPreview = false

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
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                Picker(LocalizationKeys.myLanguageSettings.localized, selection: $userLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: userLanguageRaw) { oldValue, newValue in
                                    AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: oldValue, newValue: newValue)
                                }
                            }

                            CellWrapper {
                                Text(LocalizationKeys.targetLanguage.localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                Picker(LocalizationKeys.targetLanguage.localized, selection: $targetLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: targetLanguageRaw) { oldValue, newValue in
                                    AnalyticsService.trackSettingsEvent(.languageChanged, oldValue: oldValue, newValue: newValue)
                                }
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
                                    .foregroundStyle(.secondary)
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
                                    .foregroundStyle(.secondary)
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
                        header: LocalizationKeys.tagsManagement.localized
                    ) {
                        VStack(spacing: 12) {
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
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.settings.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationKeys.close.localized) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBackgroundPreview) {
                BackgroundPreviewView()
            }
        }
    }
}
