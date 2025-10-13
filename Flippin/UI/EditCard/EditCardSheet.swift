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
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var viewModel: EditCardSheetViewModel

    @FocusState private var isUserLanguageTextFieldFocused: Bool
    @FocusState private var isTargetLanguageTextFieldFocused: Bool
    @FocusState private var isNotesTextFieldFocused: Bool

    @State private var showingImageSearch = false
    @State private var showingImageOnboarding = false
    @State private var premiumFeature: PremiumFeature?

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
        .safeAreaBarIfAvailable {
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
        .sheet(isPresented: $showingImageOnboarding) {
            ImageOnboardingView {
                handleImageOnboardingCompletion()
            }
        }
        .premiumAlert(feature: $premiumFeature)
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
            header: Loc.CardImages.sectionTitle,
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
                            Text(Loc.CardImages.imageAttached)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(Loc.CardImages.tapToChange)
                                .font(.caption)
                                .foregroundStyle(colorManager.tintColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onTapGesture {
                        handleAddImageTap()
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
                            Text(Loc.CardImages.currentImage)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Button(Loc.CardImages.tapToChange) {
                                handleAddImageTap()
                            }
                            .font(.caption)
                            .foregroundStyle(colorManager.tintColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    ActionButton(Loc.CardImages.addImage, systemImage: "photo") {
                        handleAddImageTap()
                    }
                }
            }
        } trailingContent: {
            if viewModel.card.imageCacheURL != nil || viewModel.selectedImageCacheURL != nil {
                Button(Loc.CardImages.remove) {
                    viewModel.clearSelectedImage()
                }
                .font(.caption)
                .foregroundStyle(.red)
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
