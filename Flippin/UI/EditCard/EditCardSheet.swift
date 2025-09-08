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
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var viewModel: EditCardSheetViewModel
    
    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    init(card: CardItem) {
        self._viewModel = StateObject(wrappedValue: EditCardSheetViewModel(card: card))
    }

    var body: some View {
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
            ActionButton(
                Loc.Buttons.save,
                style: .borderedProminent
            ) {
                viewModel.updateCard()
                dismiss()
            }
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(viewModel.nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .gradientStyle(.bottomButtonOnList)
        }
        .background(Color(.systemGroupedBackground))
        .navigation(
            title: Loc.Buttons.editCard,
            mode: .inline(withBackButton: true)
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .interactiveDismissDisabled()
    }

    private var languageSelectionSection: some View {
        CustomSectionView(
            header: languageManager.userLanguage.displayName,
            backgroundStyle: .standard
        ) {
            TextField(
                Loc.AddCard.enterTextInYourLanguage,
                text: $viewModel.nativeText,
                axis: .vertical
            )
            .autocapitalization(.sentences)
            .focused($isUserLanguageTextFieldFocused)
            .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
        } trailingContent: {
            if isUserLanguageTextFieldFocused {
                SectionHeaderButton(Loc.Buttons.done) {
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
                Loc.AddCard.translationWillAppearHere,
                text: $viewModel.targetText,
                axis: .vertical
            )
            .autocapitalization(.sentences)
            .focused($isTargetLanguageTextFieldFocused)
            .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
            .shimmering(when: viewModel.isTranslating)
        } trailingContent: {
            if isTargetLanguageTextFieldFocused {
                SectionHeaderButton(Loc.Buttons.done) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }

    private var tagsSection: some View {
        CustomSectionView(
            header: Loc.Plurals.tagsCount(viewModel.card.tagArray.count),
            backgroundStyle: .standard
        ) {
            if !viewModel.availableTags.isEmpty {
                HFlow(spacing: 6) {
                    ForEach(viewModel.availableTags, id: \.self) { tag in
                        TagView(
                            title: tag.name.orEmpty,
                            isSelected: viewModel.card.tagArray.contains(tag)
                        )
                        .onTap {
                            if viewModel.card.tagArray.contains(tag) {
                                viewModel.removeTag(tag)
                            } else {
                                viewModel.addTag(tag)
                            }
                        }
                        .disabled(viewModel.card.tagArray.count >= 5)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(Loc.AddCard.noTagsAvailableAddInSettings)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var notesSection: some View {
        CustomSectionView(
            header: Loc.AddCard.notes,
            backgroundStyle: .standard
        ) {
            TextField(
                Loc.AddCard.addNotesOptional,
                text: $viewModel.notes,
                axis: .vertical
            )
            .autocapitalization(.sentences)
            .focused($isNotesTextFieldFocused)
            .clippedWithPaddingAndBackground(colorManager.tintColor.opacity(0.1))
        } trailingContent: {
            if isNotesTextFieldFocused {
                SectionHeaderButton(Loc.Buttons.done) {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
} 
