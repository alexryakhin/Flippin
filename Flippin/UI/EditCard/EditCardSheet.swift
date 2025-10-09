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
    
    @State private var showingImageSearch = false

    init(card: CardItem) {
        self._viewModel = StateObject(wrappedValue: EditCardSheetViewModel(card: card))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                languageSelectionSection
                translationSection
                notesSection
                imageSection
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
        .groupedBackground()
        .navigation(
            title: Loc.Buttons.editCard,
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showingImageSearch) {
            ImageSearchView(
                cardIdentifier: viewModel.card.id ?? "edit_card"
            ) { imageUrl, localPath in
                viewModel.setSelectedImage(imageUrl: imageUrl, localPath: localPath)
            }
        }
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
    
    private var imageSection: some View {
        CustomSectionView(
            header: "Image",
            backgroundStyle: .standard
        ) {
            VStack(spacing: 12) {
                // Check if there's a newly selected image
                if let imageCacheURL = viewModel.selectedImageCacheURL,
                   let image = PexelsService.shared.getImageFromLocalPath(imageCacheURL) {
                    // Show newly selected image from cache
                    HStack(spacing: 12) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New Image")
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
                } else if let imageCacheURL = viewModel.card.imageCacheURL,
                          let image = PexelsService.shared.getImageFromLocalPath(imageCacheURL) {
                    // Show existing card image from cache
                    HStack(spacing: 12) {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Image")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Button("Change") {
                            showingImageSearch = true
                        }
                        .font(.caption)
                        .foregroundColor(colorManager.tintColor)
                        
                        Button("Remove") {
                            viewModel.clearSelectedImage()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
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
