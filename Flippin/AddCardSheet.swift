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
                
                Section(header: Text("Tags (\(viewModel.selectedTags.count)/5)")) {
                    // Add new tag
                    HStack {
                        TextField("Add new tag", text: $viewModel.newTagText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            viewModel.addNewTag()
                        }
                        .disabled(viewModel.newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.selectedTags.count >= 5)
                    }
                    
                    // Selected tags
                    if !viewModel.selectedTags.isEmpty {
                        ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Spacer()
                                Button("Remove") {
                                    viewModel.removeTag(tag)
                                }
                                .foregroundStyle(.red)
                                .font(.caption)
                            }
                        }
                    }
                    
                    // Available tags to select
                    if !viewModel.availableTags.isEmpty {
                        ForEach(viewModel.availableTags, id: \.self) { tag in
                            if !viewModel.selectedTags.contains(tag) {
                                Button {
                                    viewModel.addTag(tag)
                                } label: {
                                    HStack {
                                        Text(tag)
                                        Spacer()
                                        if viewModel.selectedTags.count < 5 {
                                            Image(systemName: "plus.circle")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                                .disabled(viewModel.selectedTags.count >= 5)
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    
                    if viewModel.availableTags.isEmpty && viewModel.selectedTags.isEmpty {
                        Text("No tags available. Add some tags in Settings.")
                            .foregroundStyle(.secondary)
                            .font(.caption)
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
