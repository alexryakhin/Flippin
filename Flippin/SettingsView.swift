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
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = "#4A90E2" // Default blue
    @StateObject private var tagManager = TagManager()
    @State private var newTagText = ""
    @State private var showingAddTagAlert = false

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
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
        }
    }
}
