//
//  AddCardSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import SwiftData

struct AddCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddCardSheetViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(viewModel.userLanguage.displayName)) {
                    TextField("Enter text in your language", text: $viewModel.nativeText)
                        .autocapitalization(.sentences)
                }
                Section(header: Text(viewModel.targetLanguage.displayName)) {
                    ZStack(alignment: .trailing) {
                        TextField("Enter text in target language", text: $viewModel.targetText)
                            .autocapitalization(.sentences)
                        if viewModel.isTranslating {
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
                        viewModel.cancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveCard(modelContext: modelContext) {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}
