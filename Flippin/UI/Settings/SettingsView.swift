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
                        Text("Background Style")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(backgroundStyle.displayName) {
                            showingBackgroundPreview = true
                        }
                        .buttonStyle(.bordered)
                    }
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

struct SettingsTagButton: View {
    let title: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
            
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
        .foregroundStyle(.primary)
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
