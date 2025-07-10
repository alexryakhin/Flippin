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
