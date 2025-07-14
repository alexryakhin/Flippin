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
                        header: "Languages"
                    ) {
                        FormWithDivider {
                            CellWrapper {
                                Text("My Language")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                Picker("My Language", selection: $userLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                            }

                            CellWrapper {
                                Text("Target Language")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                Picker("Target Language", selection: $targetLanguageRaw) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                        .clippedWithBackground()
                    }

                    CustomSectionView(
                        header: "Background"
                    ) {
                        FormWithDivider {
                            CellWrapper {
                                Text("Background Color")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                ColorPicker("", selection: Binding(
                                    get: { colorManager.userGradientColor },
                                    set: { newColor in
                                        colorManager.setUserGradientColor(newColor)
                                    }
                                ))
                                .labelsHidden()
                            }

                            CellWrapper {
                                Text("Background Style")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } trailingContent: {
                                Button(colorManager.backgroundStyle.displayName) {
                                    showingBackgroundPreview = true
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .clippedWithBackground()
                    }

                    CustomSectionView(
                        header: "Tags Management"
                    ) {
                        VStack(spacing: 12) {
                            HStack {
                                TextField("New tag name", text: $newTagText)
                                    .textFieldStyle(.roundedBorder)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.asciiCapable)
                                    .textContentType(.nickname)

                                Button("Add") {
                                    if !newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        tagManager.addTag(newTagText)
                                        newTagText = ""
                                    }
                                }
                                .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            
                            if !tagManager.availableTags.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Available Tags")
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
                                Text("No tags available")
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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
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
