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
            ScrollView {
                VStack(spacing: 16) {
                    CustomSectionView(
                        header: viewModel.userLanguage.displayName
                    ) {
                        TextField("Enter text in your language", text: $viewModel.nativeText, axis: .vertical)
                            .autocapitalization(.sentences)
                            .clippedWithPaddingAndBackground()
                    } headerTrailingContent: {
                        SectionHeaderButton("Done") {
                            UIApplication.shared.endEditing()
                        }
                    }

                    CustomSectionView(
                        header: viewModel.targetLanguage.displayName
                    ) {
                        TextField("Enter text in target language", text: $viewModel.targetText, axis: .vertical)
                            .autocapitalization(.sentences)
                            .clippedWithPaddingAndBackground()
                            .overlay(alignment: .trailing) {
                                if viewModel.isTranslating {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                            }
                    } headerTrailingContent: {
                        SectionHeaderButton("Done") {
                            UIApplication.shared.endEditing()
                        }
                    }

                    CustomSectionView(
                        header: "Notes"
                    ) {
                        TextField("Add notes (optional)", text: $viewModel.notes, axis: .vertical)
                            .autocapitalization(.sentences)
                            .clippedWithPaddingAndBackground()
                            .overlay(alignment: .trailing) {
                                if viewModel.isTranslating {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                            }
                    } headerTrailingContent: {
                        SectionHeaderButton("Done") {
                            UIApplication.shared.endEditing()
                        }
                    }

                    CustomSectionView(
                        header: "Tags (\(viewModel.selectedTags.count)/5)"
                    ) {
                        if !viewModel.availableTags.isEmpty {
                            HFlow(spacing: 6) {
                                ForEach(viewModel.availableTags, id: \.self) { tag in
                                    TagButton(
                                        title: tag,
                                        isSelected: viewModel.selectedTags.contains(tag),
                                        isDisabled: viewModel.selectedTags.count >= 5
                                    ) {
                                        if viewModel.selectedTags.contains(tag) {
                                            viewModel.removeTag(tag)
                                        } else {
                                            viewModel.addTag(tag)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clippedWithPaddingAndBackground()
                        } else {
                            Text("No tags available. Add some tags in Settings.")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .clippedWithPaddingAndBackground()
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
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
