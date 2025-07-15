//
//  AddCardSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI
import Flow

struct AddCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AddCardSheetViewModel()
    
    let onSave: (CardItem) -> Void

    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    init(onSave: @escaping (CardItem) -> Void) {
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    languageSelectionSection
                    translationSection
                    notesSection
                    tagsSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.addNewCard.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationKeys.cancel.localized) {
                        viewModel.cancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationKeys.save.localized) {
                        if let newCard = viewModel.createCard() {
                            onSave(newCard)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var languageSelectionSection: some View {
        CustomSectionView(
            header: viewModel.userLanguage.displayName
        ) {
            TextField(LocalizationKeys.enterTextInYourLanguage.localized, text: $viewModel.nativeText, axis: .vertical)
                .autocapitalization(.sentences)
                .focused($isUserLanguageTextFieldFocused)
                .clippedWithPaddingAndBackground()
        } headerTrailingContent: {
            if isUserLanguageTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }

    private var translationSection: some View {
        CustomSectionView(
            header: viewModel.targetLanguage.displayName
        ) {
            if viewModel.isTranslating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(LocalizationKeys.translating.localized)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
            } else {
                TextField(LocalizationKeys.translationWillAppearHere.localized, text: $viewModel.targetText, axis: .vertical)
                    .autocapitalization(.sentences)
                    .focused($isTargetLanguageTextFieldFocused)
                    .clippedWithPaddingAndBackground()
            }
        } headerTrailingContent: {
            if isTargetLanguageTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }

    private var tagsSection: some View {
        CustomSectionView(
            header: LocalizationKeys.tagsCount.localized(with: viewModel.selectedTags.count)
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
                Text(LocalizationKeys.noTagsAvailableAddInSettings.localized)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .clippedWithPaddingAndBackground()
            }
        }
    }

    private var notesSection: some View {
        CustomSectionView(
            header: LocalizationKeys.notes.localized
        ) {
            TextField(LocalizationKeys.addNotesOptional.localized, text: $viewModel.notes, axis: .vertical)
                .autocapitalization(.sentences)
                .focused($isNotesTextFieldFocused)
                .clippedWithPaddingAndBackground()
        } headerTrailingContent: {
            if isNotesTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
}
