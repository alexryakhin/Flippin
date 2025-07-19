//
//  LocalizedPresetService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

class LocalizedPresetService: ObservableObject {
    static let shared = LocalizedPresetService()
    
    private init() {}
    
    // MARK: - Collection Definitions
    struct LocalizedPresetCollection {
        let id: String
        let category: PresetCategory
        let phraseKeys: [String]
    }
    
    // Define the preset collections with their phrase keys
    private let presetCollections: [LocalizedPresetCollection] = [
        LocalizedPresetCollection(
            id: "essentialPhrases",
            category: .basics,
            phraseKeys: [
                "hello", "thankYou", "please", "yes", "no", 
                "goodbye", "excuseMe", "dontUnderstand"
            ]
        ),
        LocalizedPresetCollection(
            id: "travelEssentials",
            category: .travel,
            phraseKeys: [
                "whereBathroom", "howMuchCost", "needHelp", "speakEnglish",
                "imLost", "canYouHelp", "whatTime", "allergicTo"
            ]
        ),
        LocalizedPresetCollection(
            id: "entertainmentMedia",
            category: .entertainment,
            phraseKeys: [
                "loveMovie", "favoriteMusic", "songAmazing", "playVideoGames",
                "seenShow", "readComics", "disneyGreat", "whatGenre"
            ]
        ),
        LocalizedPresetCollection(
            id: "foodDining",
            category: .food,
            phraseKeys: [
                "imHungry", "delicious", "vegetarian", "canHaveMenu",
                "likeToOrder", "billPlease", "allergicNuts", "whatRecommend"
            ]
        ),
        LocalizedPresetCollection(
            id: "healthMedical",
            category: .health,
            phraseKeys: [
                "dontFeelWell", "haveHeadache", "needDoctor", "whereHospital",
                "haveFever", "takingMedication", "haveAllergy", "callAmbulance"
            ]
        ),
        LocalizedPresetCollection(
            id: "leisureHobbies",
            category: .leisure,
            phraseKeys: [
                "likeToRead", "playSports", "loveHiking", "whatDoForFun",
                "enjoyCooking", "goForWalk", "playGuitar", "likePhotography"
            ]
        )
    ]
    
    // MARK: - Public Methods
    
    func getLocalizedCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        return presetCollections.map { collection in
            let localizedName = getLocalizedString("collection.\(collection.id).name", language: userLanguage)
            let localizedDescription = getLocalizedString("collection.\(collection.id).description", language: userLanguage)
            
            let cards = collection.phraseKeys.map { phraseKey in
                let userLanguageText = getLocalizedString("phrase.\(phraseKey).text", language: userLanguage)
                let targetLanguageText = getLocalizedString("phrase.\(phraseKey).text", language: targetLanguage)
                let notes = getLocalizedString("phrase.\(phraseKey).notes", language: userLanguage)
                
                return PresetCard(
                    frontText: targetLanguageText,
                    backText: userLanguageText,
                    notes: notes,
                    tags: [collection.category.localizedTag(for: userLanguage)]
                )
            }
            
            return PresetCollection(
                name: localizedName,
                description: localizedDescription,
                icon: collection.category.icon,
                category: collection.category,
                cards: cards
            )
        }
    }
    
    func getFeaturedCollections(for userLanguage: Language, targetLanguage: Language) -> [PresetCollection] {
        let allCollections = getLocalizedCollections(for: userLanguage, targetLanguage: targetLanguage)
        return Array(allCollections.prefix(2))
    }
    
    // MARK: - Private Methods
    
    private func getLocalizedString(_ key: String, language: Language) -> String {
        let bundle = Bundle.main
        let languageCode = language.localizationCode
        
        // Try to load the string from the specific language bundle
        if let languageBundle = bundle.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: languageBundle) {
            let localizedString = NSLocalizedString(key, tableName: "PresetPhrases", bundle: bundle, value: key, comment: "")
            if localizedString != key {
                return localizedString
            }
        }
        
        // Fallback to main bundle
        return NSLocalizedString(key, tableName: "PresetPhrases", bundle: bundle, value: key, comment: "")
    }
    
    func convertPresetCardsToCardItems(_ presetCards: [PresetCard], userLanguage: Language, targetLanguage: Language) -> [CardItem] {
        return presetCards.map { presetCard in
            CardItem(
                timestamp: Date(),
                frontText: presetCard.frontText,
                backText: presetCard.backText,
                frontLanguage: targetLanguage,
                backLanguage: userLanguage,
                notes: presetCard.notes,
                tags: presetCard.tags,
                isFavorite: false,
                id: UUID().uuidString
            )
        }
    }
} 