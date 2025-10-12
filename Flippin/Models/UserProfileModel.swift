//
//  UserProfileModel.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import Foundation
import CoreData

// MARK: - Age Group

enum AgeGroup: String, Codable, CaseIterable, Identifiable {
    case under18
    case age18to24
    case age25to34
    case age35to44
    case age45to54
    case age55plus
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .under18: return Loc.UserProfile.ageUnder18
        case .age18to24: return Loc.UserProfile.age18to24
        case .age25to34: return Loc.UserProfile.age25to34
        case .age35to44: return Loc.UserProfile.age35to44
        case .age45to54: return Loc.UserProfile.age45to54
        case .age55plus: return Loc.UserProfile.age55plus
        }
    }
    
    var icon: String {
        switch self {
        case .under18: return "figure.wave"
        case .age18to24: return "figure.walk"
        case .age25to34: return "figure.run"
        case .age35to44: return "figure.hiking"
        case .age45to54: return "figure.cooldown"
        case .age55plus: return "figure.mind.and.body"
        }
    }
}

// MARK: - Gender

enum Gender: String, Codable, CaseIterable, Identifiable {
    case male
    case female
    case preferNotToSay
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .male: return Loc.UserProfile.genderMale
        case .female: return Loc.UserProfile.genderFemale
        case .preferNotToSay: return Loc.UserProfile.genderPreferNotToSay
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "person"
        case .female: return "person"
        case .preferNotToSay: return "questionmark.circle"
        }
    }
}

// MARK: - Language Proficiency

enum LanguageProficiency: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .beginner: return Loc.UserProfile.proficiencyBeginner
        case .intermediate: return Loc.UserProfile.proficiencyIntermediate
        case .advanced: return Loc.UserProfile.proficiencyAdvanced
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.circle.fill"
        }
    }
}

// MARK: - Learning Goal

enum LearningGoal: String, Codable, CaseIterable, Identifiable {
    case travel
    case business
    case academic
    case casual
    case cultural
    case relocation
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .travel: return Loc.UserProfile.goalTravel
        case .business: return Loc.UserProfile.goalBusiness
        case .academic: return Loc.UserProfile.goalAcademic
        case .casual: return Loc.UserProfile.goalCasual
        case .cultural: return Loc.UserProfile.goalCultural
        case .relocation: return Loc.UserProfile.goalRelocation
        }
    }
    
    var description: String {
        switch self {
        case .travel: return Loc.UserProfile.goalTravelDesc
        case .business: return Loc.UserProfile.goalBusinessDesc
        case .academic: return Loc.UserProfile.goalAcademicDesc
        case .casual: return Loc.UserProfile.goalCasualDesc
        case .cultural: return Loc.UserProfile.goalCulturalDesc
        case .relocation: return Loc.UserProfile.goalRelocationDesc
        }
    }
    
    var icon: String {
        switch self {
        case .travel: return "airplane.departure"
        case .business: return "briefcase.fill"
        case .academic: return "graduationcap.fill"
        case .casual: return "message.fill"
        case .cultural: return "theatermasks.fill"
        case .relocation: return "house.fill"
        }
    }
}

// MARK: - Weekly Goal

enum WeeklyGoal: Int, Codable, CaseIterable, Identifiable {
    case ten = 10
    case twentyFive = 25
    case fifty = 50
    case hundred = 100
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .ten: return Loc.UserProfile.weeklyGoal10
        case .twentyFive: return Loc.UserProfile.weeklyGoal25
        case .fifty: return Loc.UserProfile.weeklyGoal50
        case .hundred: return Loc.UserProfile.weeklyGoal100
        }
    }
    
    var description: String {
        switch self {
        case .ten: return Loc.UserProfile.weeklyGoal10Desc
        case .twentyFive: return Loc.UserProfile.weeklyGoal25Desc
        case .fifty: return Loc.UserProfile.weeklyGoal50Desc
        case .hundred: return Loc.UserProfile.weeklyGoal100Desc
        }
    }
    
    var icon: String {
        switch self {
        case .ten: return "leaf.fill"
        case .twentyFive: return "hare.fill"
        case .fifty: return "bolt.fill"
        case .hundred: return "flame.fill"
        }
    }
}

// MARK: - User Profile Core Data Model

@objc(UserProfile)
public final class UserProfile: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var ageGroupRaw: String?
    @NSManaged public var genderRaw: String?
    @NSManaged public var languageProficienciesRaw: String? // JSON dictionary [languageCode: proficiencyLevel]
    @NSManaged public var selectedInterestsRaw: String?
    @NSManaged public var weeklyPhraseGoal: Int32
    @NSManaged public var learningGoalRaw: String?
    @NSManaged public var prefersTravelMode: Bool
    @NSManaged public var onboardingCompletedDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
    // MARK: - Computed Properties
    
    var ageGroup: AgeGroup? {
        get {
            guard let raw = ageGroupRaw else { return nil }
            return AgeGroup(rawValue: raw)
        }
        set {
            ageGroupRaw = newValue?.rawValue
        }
    }
    
    var gender: Gender? {
        get {
            guard let raw = genderRaw else { return nil }
            return Gender(rawValue: raw)
        }
        set {
            genderRaw = newValue?.rawValue
        }
    }
    
    // MARK: - Language Proficiencies (Multiple Languages Support)
    
    /// Dictionary of [languageCode: proficiencyLevel] for all target languages
    var languageProficiencies: [String: LanguageProficiency] {
        get {
            guard let raw = languageProficienciesRaw, !raw.isEmpty else {
                return [:]
            }
            
            // Decode JSON dictionary
            guard let data = raw.data(using: .utf8),
                  let dict = try? JSONDecoder().decode([String: String].self, from: data) else {
                return [:]
            }
            
            // Convert string values to LanguageProficiency enum
            var result: [String: LanguageProficiency] = [:]
            for (lang, proficiencyRaw) in dict {
                if let proficiency = LanguageProficiency(rawValue: proficiencyRaw) {
                    result[lang] = proficiency
                }
            }
            return result
        }
        set {
            // Convert enum values to strings
            let dict = newValue.mapValues { $0.rawValue }
            
            // Encode to JSON
            if let data = try? JSONEncoder().encode(dict),
               let jsonString = String(data: data, encoding: .utf8) {
                languageProficienciesRaw = jsonString
            }
        }
    }
    
    /// Get proficiency for a specific language
    func getProficiency(for language: Language) -> LanguageProficiency? {
        return languageProficiencies[language.rawValue]
    }
    
    /// Get proficiency for current target language
    var currentTargetLanguageProficiency: LanguageProficiency? {
        return getProficiency(for: LanguageManager.shared.targetLanguage)
    }
    
    /// Set proficiency for a specific language
    func setLanguageProficiency(_ proficiency: LanguageProficiency, for language: Language) {
        var proficiencies = languageProficiencies
        proficiencies[language.rawValue] = proficiency
        languageProficiencies = proficiencies
        updatedAt = Date()
    }
    
    /// Remove proficiency for a specific language
    func removeProficiency(for language: Language) {
        var proficiencies = languageProficiencies
        proficiencies.removeValue(forKey: language.rawValue)
        languageProficiencies = proficiencies
        updatedAt = Date()
    }
    
    /// Get all languages user is learning
    var learningLanguages: [Language] {
        return languageProficiencies.keys.compactMap { Language(rawValue: $0) }
    }
    
    var learningGoal: LearningGoal? {
        get {
            guard let raw = learningGoalRaw else { return nil }
            return LearningGoal(rawValue: raw)
        }
        set {
            learningGoalRaw = newValue?.rawValue
        }
    }
    
    var selectedInterests: [PresetModel.Category] {
        get {
            guard let raw = selectedInterestsRaw, !raw.isEmpty else { return [] }
            return raw.split(separator: ",")
                .compactMap { PresetModel.Category(rawValue: String($0)) }
        }
        set {
            selectedInterestsRaw = newValue.map { $0.rawValue }.joined(separator: ",")
        }
    }
    
    var weeklyGoal: WeeklyGoal {
        get {
            return WeeklyGoal(rawValue: Int(weeklyPhraseGoal)) ?? .twentyFive
        }
        set {
            weeklyPhraseGoal = Int32(newValue.rawValue)
        }
    }
    
    // MARK: - Helpers
    
    /// Generates a formatted string for ChatGPT context
    func generateChatGPTContext() -> String {
        var context = "User Profile:\n"
        
        if let name = name, !name.isEmpty {
            context += "- Name: \(name)\n"
        }
        
        if let ageGroup = ageGroup {
            context += "- Age Group: \(ageGroup.displayName)\n"
        }
        
        if let gender = gender, gender != .preferNotToSay {
            context += "- Gender: \(gender.displayName)\n"
        }
        
        // Current target language proficiency (only the active one)
        let currentLanguage = LanguageManager.shared.targetLanguage
        if let proficiency = getProficiency(for: currentLanguage) {
            context += "- Target Language: \(currentLanguage.displayName)\n"
            context += "- Language Level: \(proficiency.displayName)\n"
        }
        
        if !selectedInterests.isEmpty {
            let interests = selectedInterests.map { $0.displayTitle }.joined(separator: ", ")
            context += "- Interests: \(interests)\n"
        }
        
        context += "- Weekly Goal: \(weeklyGoal.rawValue) phrases\n"
        
        if let goal = learningGoal {
            context += "- Learning Goal: \(goal.displayName)\n"
        }
        
        context += "- Preferred Mode: \(prefersTravelMode ? "Travel Mode" : "Learning Mode")\n"
        
        return context
    }
}

