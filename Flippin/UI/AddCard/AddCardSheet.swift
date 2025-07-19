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
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var cardsProvider: CardsProvider
    @EnvironmentObject private var colorManager: ColorManager
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
                    presetCollectionsSection
                }
                .padding(16)
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    if let newCard = viewModel.createCard() {
                        onSave(newCard)
                        dismiss()
                    }
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
            .navigationTitle(LocalizationKeys.addNewCard.localized)
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
    
    private var presetCollectionsSection: some View {
        CustomSectionView(
            header: LocalizationKeys.presetCollections.localized
        ) {
            FeaturedPresetCollections()
                .environmentObject(languageManager)
                .environmentObject(cardsProvider)
                .environmentObject(colorManager)
        }
    }
}
