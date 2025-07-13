//
//  AddCardSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import SwiftData
import Flow

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
                
                Section(header: Text("Notes")) {
                    TextField("Add notes (optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                        .autocapitalization(.sentences)
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Tags")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HFlow(spacing: 6) {
                                ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                                    SelectedTagButton(
                                        title: tag,
                                        onRemove: {
                                            viewModel.removeTag(tag)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Available tags to select
                    if !viewModel.availableTags.isEmpty {
                        let availableTags = viewModel.availableTags.filter { !viewModel.selectedTags.contains($0) }
                        if !availableTags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Tags")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HFlow(spacing: 6) {
                                    ForEach(availableTags, id: \.self) { tag in
                                        TagButton(
                                            title: tag,
                                            isSelected: false,
                                            isDisabled: viewModel.selectedTags.count >= 5
                                        ) {
                                            viewModel.addTag(tag)
                                        }
                                    }
                                }
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

struct SelectedTagButton: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
        .foregroundStyle(.blue)
        .overlay(
            Capsule()
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}
