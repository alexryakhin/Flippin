//
//  EditCardSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//
import SwiftUI
import Flow

struct EditCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var viewModel: EditCardSheetViewModel
    
    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    init(card: CardItem) {
        self._viewModel = StateObject(wrappedValue: EditCardSheetViewModel(card: card))
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
            .safeAreaInset(edge: .bottom) {
                Button {
                    viewModel.updateCard()
                    dismiss()
                } label: {
                    Text(LocalizationKeys.save.localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(vertical: 12, horizontal: 16)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.editCard.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.cancel()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var languageSelectionSection: some View {
        CustomSectionView(
            header: languageManager.userLanguage.displayName
        ) {
            TextField(
                LocalizationKeys.enterTextInYourLanguage.localized,
                text: $viewModel.nativeText,
                axis: .vertical
            )
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
            header: languageManager.targetLanguage.displayName
        ) {
            TextField(
                LocalizationKeys.translationWillAppearHere.localized,
                text: $viewModel.targetText,
                axis: .vertical
            )
            .autocapitalization(.sentences)
            .focused($isTargetLanguageTextFieldFocused)
            .clippedWithPaddingAndBackground()
            .shimmering(when: viewModel.isTranslating)
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
            header: LocalizationKeys.tagsCount.localized(with: viewModel.card.tagArray.count)
        ) {
            if !viewModel.availableTags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        TagButton(
                            title: tag.name.orEmpty,
                            isSelected: viewModel.card.tagArray.contains(tag),
                            isDisabled: viewModel.card.tagArray.count >= 5
                        ) {
                            if viewModel.card.tagArray.contains(tag) {
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
            TextField(
                LocalizationKeys.addNotesOptional.localized,
                text: $viewModel.notes,
                axis: .vertical
            )
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
