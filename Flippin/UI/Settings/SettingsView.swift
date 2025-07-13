//
//  SettingsView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(UserDefaultsKey.userLanguage) private var userLanguageRaw: String = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en")?.rawValue ?? Language.english.rawValue
    @AppStorage(UserDefaultsKey.targetLanguage) private var targetLanguageRaw: String = Language.spanish.rawValue
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = Constant.defaultColorHex // Default blue
    @AppStorage(UserDefaultsKey.backgroundStyle) private var backgroundStyleRaw: String = BackgroundStyle.gradient.rawValue
    @StateObject private var tagManager = TagManager()
    @State private var newTagText = ""
    @State private var showingAddTagAlert = false
    @State private var showingBackgroundPreview = false

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }
    
    var backgroundStyle: BackgroundStyle {
        BackgroundStyle(rawValue: backgroundStyleRaw) ?? .gradient
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Languages")) {
                    Picker("My Language", selection: $userLanguageRaw) {
                        ForEach(Language.allCases) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }

                    Picker("Target Language", selection: $targetLanguageRaw) {
                        ForEach(Language.allCases) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Background")) {
                    ColorPicker("Background Color", selection: Binding(
                        get: { userGradientColor },
                        set: { newColor in
                            userGradientColorHex = newColor.uiColor.toHexString()
                        }
                    ))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Background Style")
                                .font(.headline)
                            Text(backgroundStyle.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Preview") {
                            showingBackgroundPreview = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Picker("Background Style", selection: $backgroundStyleRaw) {
                        ForEach(BackgroundStyle.allCases, id: \.self) { style in
                            Label(style.displayName, systemImage: style.icon)
                                .tag(style.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Tags Management")) {
                    HStack {
                        TextField("New tag name", text: $newTagText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            if !newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                tagManager.addTag(newTagText)
                                newTagText = ""
                            }
                        }
                        .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    if !tagManager.availableTags.isEmpty {
                        ForEach(tagManager.availableTags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Spacer()
                                Button("Delete") {
                                    tagManager.removeTag(tag)
                                }
                                .foregroundStyle(.red)
                                .font(.caption)
                            }
                        }
                    } else {
                        Text("No tags available")
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
                BackgroundPreviewView(selectedStyle: $backgroundStyleRaw)
            }
        }
    }
}
