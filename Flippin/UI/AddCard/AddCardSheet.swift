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
    
    @State private var showingImageSearch = false

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                languageSelectionSection
                translationSection
                notesSection
                imageSection
                tagsSection
                FeaturedPresetCollections(bgStyle: .standard)
            }
            .padding(16)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
        }
        .groupedBackground()
        .navigation(
            title: Loc.NavigationTitles.addNewCard,
            mode: .inline,
            showsBackButton: true
        )
        .onAppear {
            AnalyticsService.trackEvent(.addCardScreenOpened)
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showingImageSearch) {
            ImageSearchView(
                cardIdentifier: viewModel.targetText.isEmpty ? "new_card" : viewModel.targetText
            ) { imageUrl, localPath in
                viewModel.setSelectedImage(imageUrl: imageUrl, localPath: localPath)
            }
        }
    }

    // MARK: - UI Components
    
    private var saveButton: some View {
        ActionButton(
            Loc.Buttons.save,
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
            TextField(Loc.AddCard.enterTextInYourLanguage, text: $viewModel.nativeText, axis: .vertical)
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
            header: Loc.Plurals.tagsCount(viewModel.selectedTags.count),
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
            TextField(Loc.AddCard.addNotesOptional, text: $viewModel.notes, axis: .vertical)
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
    
    private var imageSection: some View {
        CustomSectionView(
            header: "Image",
            backgroundStyle: .standard
        ) {
            VStack(spacing: 12) {
                if let imageCacheURL = viewModel.selectedImageCacheURL,
                   let image = PexelsService.shared.getImageFromLocalPath(imageCacheURL) {
                    // Show selected image from cache
                    HStack(spacing: 12) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Image Attached")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Tap to change")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Remove") {
                            viewModel.clearSelectedImage()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .onTapGesture {
                        showingImageSearch = true
                    }
                } else {
                    // Show add image button
                    Button(action: {
                        showingImageSearch = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(colorManager.tintColor)
                            
                            Text("Add Image")
                                .font(.subheadline)
                                .foregroundColor(colorManager.tintColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colorManager.tintColor.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
