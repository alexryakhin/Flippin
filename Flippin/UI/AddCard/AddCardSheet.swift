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
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var viewModel = AddCardSheetViewModel()

    // MARK: - Focus State
    
    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool
    
    @State private var showingImageSearch = false
    @State private var showingImageOnboarding = false
    @State private var premiumFeature: PremiumFeature?

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
        .safeAreaInset(edge: .bottom, spacing: .zero) {
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
        .sheet(isPresented: $showingImageOnboarding) {
            ImageOnboardingView {
                handleImageOnboardingCompletion()
            }
        }
        .premiumAlert(feature: $premiumFeature)
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
            header: Loc.CardImages.sectionTitle,
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
                            Text(Loc.CardImages.imageAttached)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(Loc.CardImages.tapToChange)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                    }
                    .onTapGesture {
                        showingImageSearch = true
                    }
                } else {
                    ActionButton(Loc.CardImages.addImage, systemImage: "photo") {
                        handleAddImageTap()
                    }
                }
            }
        } trailingContent: {
            if viewModel.selectedImageCacheURL != nil {
                Button(Loc.CardImages.remove) {
                    viewModel.clearSelectedImage()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Image Handling
    
    private func handleAddImageTap() {
        // Check if user has seen image onboarding
        let hasSeenImageOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKey.hasSeenImageOnboarding)
        
        if hasSeenImageOnboarding {
            // User has seen onboarding, check premium status
            if purchaseService.hasPremiumAccess {
                // Premium user, show image selection
                showingImageSearch = true
            } else {
                // Non-premium user, show premium alert
                AnalyticsService.trackPremiumFeatureRequested(.images)
                premiumFeature = .images
            }
        } else {
            // User hasn't seen onboarding, show it first
            AnalyticsService.trackImageOnboardingEvent(.imageOnboardingShown, userHasPremium: purchaseService.hasPremiumAccess)
            showingImageOnboarding = true
        }
    }
    
    private func handleImageOnboardingCompletion() {
        showingImageOnboarding = false
        AnalyticsService.trackImageOnboardingEvent(.imageOnboardingCompleted, userHasPremium: purchaseService.hasPremiumAccess)
        
        // After onboarding, check premium status
        if purchaseService.hasPremiumAccess {
            // Premium user, show image selection and mark onboarding as seen
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.hasSeenImageOnboarding)
            showingImageSearch = true
        } else {
            // Non-premium user, show premium alert
            AnalyticsService.trackPremiumFeatureRequested(.images)
            premiumFeature = .images
        }
    }
}
