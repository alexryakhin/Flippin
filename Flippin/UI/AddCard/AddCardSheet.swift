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

    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
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

                    CustomSectionView(
                        header: viewModel.targetLanguage.displayName
                    ) {
                        TextField(LocalizationKeys.enterTextInTargetLanguage.localized, text: $viewModel.targetText, axis: .vertical)
                            .autocapitalization(.sentences)
                            .focused($isTargetLanguageTextFieldFocused)
                            .clippedWithPaddingAndBackground()
                            .overlay(alignment: .trailing) {
                                if viewModel.isTranslating {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                            }
                    } headerTrailingContent: {
                        if isTargetLanguageTextFieldFocused {
                            SectionHeaderButton(LocalizationKeys.done.localized) {
                                UIApplication.shared.endEditing()
                            }
                        }
                    }

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
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.addCard.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationKeys.cancel.localized) {
                        viewModel.cancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizationKeys.save.localized) {
                        if viewModel.saveCard(modelContext: modelContext) {
                            // Track card added event
                            AnalyticsService.trackCardEvent(
                                .cardAdded,
                                cardLanguage: viewModel.targetLanguage.rawValue,
                                hasTags: !viewModel.selectedTags.isEmpty,
                                tagCount: viewModel.selectedTags.count
                            )
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
