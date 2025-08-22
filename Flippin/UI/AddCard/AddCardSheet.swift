//
//  AddCardSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI
import Flow

/**
 Sheet for adding new flashcards with automatic translation.
 Supports text input in user's language with real-time translation to target language.
 Includes tag selection, notes, and preset collection integration.
 */
struct AddCardSheet: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State Objects
    
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var viewModel = AddCardSheetViewModel()

    // MARK: - Focus State
    
    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                languageSelectionSection
                translationSection
                notesSection
                tagsSection
                FeaturedPresetCollections(bgStyle: .standard)
            }
            .padding(16)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
        .background(Color(.systemGroupedBackground))
        .navigation(
            title: LocalizationKeys.Card.addNewCard.localized,
            mode: .inline(withBackButton: true)
        )
        .onAppear {
            AnalyticsService.trackEvent(.addCardScreenOpened)
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .interactiveDismissDisabled()
    }

    // MARK: - UI Components
    
    private var saveButton: some View {
        ActionButton(
            LocalizationKeys.General.save.localized,
            style: .borderedProminent
        ) {
            viewModel.createCard()
            dismiss()
        }
        .padding(.horizontal)
        .padding(.bottom)
        .disabled(viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                 viewModel.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .gradientStyle(.bottomButtonOnList)
    }

    private var languageSelectionSection: some View {
        CustomSectionView(
            header: languageManager.userLanguage.displayName,
            backgroundStyle: .standard
        ) {
            TextField(LocalizationKeys.Card.enterTextInYourLanguage.localized, text: $viewModel.nativeText, axis: .vertical)
                .autocapitalization(.sentences)
                .focused($isUserLanguageTextFieldFocused)
                .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
        } trailingContent: {
            if isUserLanguageTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.General.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }

    private var translationSection: some View {
        CustomSectionView(
            header: languageManager.targetLanguage.displayName,
            backgroundStyle: .standard
        ) {
            TextField(
                LocalizationKeys.Card.translationWillAppearHere.localized,
                text: $viewModel.targetText,
                axis: .vertical
            )
            .autocapitalization(.sentences)
            .focused($isTargetLanguageTextFieldFocused)
            .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
            .shimmering(when: viewModel.isTranslating)
        } trailingContent: {
            if isTargetLanguageTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.General.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }

    private var tagsSection: some View {
        CustomSectionView(
            header: LocalizationKeys.Tag.tagsCount.localized(with: viewModel.selectedTags.count),
            backgroundStyle: .standard
        ) {
            if !viewModel.availableTags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        TagView(
                            title: tag.name.orEmpty,
                            isSelected: viewModel.selectedTags.contains(tag)
                        )
                        .onTap {
                            if viewModel.selectedTags.contains(tag) {
                                viewModel.removeTag(tag)
                            } else {
                                viewModel.addTag(tag)
                            }
                        }
                        .disabled(viewModel.selectedTags.count >= 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(LocalizationKeys.Tag.noTagsAvailableAddInSettings.localized)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var notesSection: some View {
        CustomSectionView(
            header: LocalizationKeys.Card.notes.localized,
            backgroundStyle: .standard
        ) {
            TextField(LocalizationKeys.Card.addNotesOptional.localized, text: $viewModel.notes, axis: .vertical)
                .autocapitalization(.sentences)
                .focused($isNotesTextFieldFocused)
                .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
        } trailingContent: {
            if isNotesTextFieldFocused {
                SectionHeaderButton(LocalizationKeys.General.done.localized) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
}
