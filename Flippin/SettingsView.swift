//
//  SettingsView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userLanguage") private var userLanguageRaw: String = Language(rawValue: Locale.current.language.languageCode?.identifier ?? "en")?.rawValue ?? Language.english.rawValue
    @AppStorage("targetLanguage") private var targetLanguageRaw: String = Language.spanish.rawValue

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Languages")) {
                    VStack(alignment: .leading) {
                        Text("My Language")
                            .font(.headline)
                        Picker("My Language", selection: $userLanguageRaw) {
                            ForEach(Language.allCases) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Target Language")
                            .font(.headline)
                        Picker("Target Language", selection: $targetLanguageRaw) {
                            ForEach(Language.allCases) { lang in
                                Text(lang.displayName).tag(lang.rawValue)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding(.vertical, 8)
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
