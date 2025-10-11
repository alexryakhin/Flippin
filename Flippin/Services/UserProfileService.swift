//
//  UserProfileService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import Foundation
import CoreData
import Combine

@MainActor
final class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    @Published private(set) var currentProfile: UserProfile?
    
    private let coreDataService = CoreDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadProfile()
    }
    
    // MARK: - Public Methods
    
    /// Loads the user profile from Core Data
    func loadProfile() {
        do {
            let request = NSFetchRequest<UserProfile>(entityName: "UserProfile")
            let profiles = try coreDataService.context.fetch(request)
            currentProfile = profiles.first
            
            if currentProfile != nil {
                print("✅ Loaded user profile")
            }
        } catch {
            print("❌ Failed to load user profile: \(error)")
        }
    }
    
    /// Creates or updates the user profile
    func createOrUpdateProfile() -> UserProfile {
        if let existing = currentProfile {
            existing.updatedAt = Date()
            return existing
        } else {
            let newProfile = UserProfile(context: coreDataService.context)
            newProfile.id = UUID().uuidString
            newProfile.createdAt = Date()
            newProfile.updatedAt = Date()
            newProfile.weeklyPhraseGoal = 25
            currentProfile = newProfile
            return newProfile
        }
    }
    
    /// Updates a specific field in the user profile
    func updateProfile(
        name: String? = nil,
        ageGroup: AgeGroup? = nil,
        gender: Gender? = nil,
        proficiency: LanguageProficiency? = nil,
        interests: [PresetModel.Category]? = nil,
        weeklyGoal: WeeklyGoal? = nil,
        learningGoal: LearningGoal? = nil,
        prefersTravelMode: Bool? = nil
    ) {
        let profile = createOrUpdateProfile()
        
        if let name = name {
            profile.name = name
        }
        if let ageGroup = ageGroup {
            profile.ageGroup = ageGroup
        }
        if let gender = gender {
            profile.gender = gender
        }
        if let proficiency = proficiency {
            // Set proficiency for current target language
            profile.setLanguageProficiency(proficiency, for: LanguageManager.shared.targetLanguage)
        }
        if let interests = interests {
            profile.selectedInterests = interests
        }
        if let weeklyGoal = weeklyGoal {
            profile.weeklyGoal = weeklyGoal
        }
        if let learningGoal = learningGoal {
            profile.learningGoal = learningGoal
        }
        if let prefersTravelMode = prefersTravelMode {
            profile.prefersTravelMode = prefersTravelMode
        }
        
        profile.updatedAt = Date()
        saveContext()
    }
    
    /// Marks onboarding as completed
    func completeOnboarding() {
        let profile = createOrUpdateProfile()
        profile.onboardingCompletedDate = Date()
        profile.updatedAt = Date()
        saveContext()
        
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.userProfileCompleted)
        print("✅ Onboarding completed")
    }
    
    /// Checks if onboarding is complete
    func isOnboardingComplete() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.userProfileCompleted)
    }
    
    /// Generates a formatted context string for ChatGPT
    func getChatGPTContext() -> String {
        guard let profile = currentProfile else {
            return "User Profile: Not available"
        }
        return profile.generateChatGPTContext()
    }
    
    /// Updates language proficiency for a specific language
    func updateLanguageProficiency(_ proficiency: LanguageProficiency, for language: Language) {
        let profile = createOrUpdateProfile()
        profile.setLanguageProficiency(proficiency, for: language)
        profile.updatedAt = Date()
        saveContext()
        print("✅ Updated proficiency for \(language.displayName) to \(proficiency.displayName)")
    }
    
    /// Called when target language changes for premium users
    func handleTargetLanguageChange(to language: Language) {
        let profile = createOrUpdateProfile()
        
        // If this language doesn't have a proficiency yet, set default to beginner
        if profile.getProficiency(for: language) == nil {
            profile.setLanguageProficiency(.beginner, for: language)
            profile.updatedAt = Date()
            saveContext()
            print("✅ Added \(language.displayName) to learning languages with beginner proficiency")
        } else {
            print("ℹ️ \(language.displayName) already tracked with \(profile.getProficiency(for: language)!.displayName) proficiency")
        }
    }
    
    /// Resets the user profile (for debugging)
    func resetProfile() {
        if let profile = currentProfile {
            coreDataService.context.delete(profile)
            currentProfile = nil
            saveContext()
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.userProfileCompleted)
            print("🔄 User profile reset")
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try coreDataService.saveContext()
        } catch {
            print("❌ Failed to save user profile: \(error)")
        }
    }
}

