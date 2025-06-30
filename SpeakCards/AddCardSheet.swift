//
//  AddCardSheet.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct AddCardSheet: View {

    @Environment(\.dismiss) var dismiss

    let userLanguage: Language
    let targetLanguage: Language
    var onSave: (String, String) -> Void
    @State private var nativeText: String = ""
    @State private var targetText: String = ""
    @State private var isTranslating = false
    @State private var debounceTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(userLanguage.displayName)) {
                    TextField("Enter text in your language", text: $nativeText)
                        .autocapitalization(.sentences)
                        .onChange(of: nativeText) { newValue in
                            targetText = ""
                            debounceTask?.cancel()
                            guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            debounceTask = Task {
                                guard !isTranslating else { return }
                                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s debounce
                                isTranslating = true
                                if let translated = try? await TranslationService.translate(
                                    text: newValue,
                                    from: userLanguage.rawValue,
                                    to: targetLanguage.rawValue
                                ) {
                                    await MainActor.run {
                                        targetText = translated
                                    }
                                }
                                await MainActor.run {
                                    isTranslating = false
                                }
                            }
                        }
                }
                Section(header: Text(targetLanguage.displayName)) {
                    ZStack(alignment: .trailing) {
                        TextField("Enter text in target language", text: $targetText)
                            .autocapitalization(.sentences)
                        if isTranslating {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                    }
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(nativeText, targetText)
                        }
                    }
                    .disabled(nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onDisappear {
            debounceTask?.cancel()
        }
    }
}
