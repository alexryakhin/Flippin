import Foundation
import SwiftUI

enum LocalizationKeys {
    
    // MARK: - Navigation Titles
    static let addCard = "addCard"
    static let addNewCard = "addNewCard"
    static let settings = "settings"
    static let myCards = "myCards"
    static let backgroundStyles = "backgroundStyles"
    static let backgroundDemo = "backgroundDemo"
    
    // MARK: - Welcome Screen
    static let welcomeScreenTitle = "welcomeScreenTitle"
    static let welcomeScreenMessage = "welcomeScreenMessage"
    static let myLanguage = "myLanguage"
    static let myLanguageDesc = "myLanguageDesc"
    static let imLearning = "imLearning"
    static let imLearningDesc = "imLearningDesc"
    static let continueButton = "continueButton"
    static let back = "back"
    static let getStarted = "getStarted"
    static let chooseLanguages = "chooseLanguages"
    static let chooseLanguagesDesc = "chooseLanguagesDesc"
    static let readyToStart = "readyToStart"
    static let readyToStartDesc = "readyToStartDesc"
    static let featureLearning = "featureLearning"
    static let featureLearningDesc = "featureLearningDesc"
    static let featureLanguages = "featureLanguages"
    static let featureLanguagesDesc = "featureLanguagesDesc"
    static let featureSmart = "featureSmart"
    static let featureSmartDesc = "featureSmartDesc"
    static let finalFeatureAdd = "finalFeatureAdd"
    static let finalFeaturePractice = "finalFeaturePractice"
    static let finalFeatureProgress = "finalFeatureProgress"

    // MARK: - Content Views
    static let noCardsYet = "noCardsYet"
    static let tapToAddFirstCard = "tapToAddFirstCard"
    static let noCardsWithSelectedTag = "noCardsWithSelectedTag"
    static let noCardsFoundWithTag = "noCardsFoundWithTag"
    static let noCardsAvailable = "noCardsAvailable"
    static let noCardsFound = "noCardsFound"
    static let addFirstCardToStartLearning = "addFirstCardToStartLearning"
    static let noCardsMatchSearch = "noCardsMatchSearch"
    
    // MARK: - Card Views
    static let showAnswer = "showAnswer"
    static let tapToGoBack = "tapToGoBack"
    
    // MARK: - Tag Management
    static let availableTags = "availableTags"
    static let noTagsAvailable = "noTagsAvailable"
    static let manageTagsInSettings = "manageTagsInSettings"
    static let toSettings = "toSettings"
    static let newTagName = "newTagName"
    static let add = "add"
    static let addTag = "addTag"
    static let tagsManagement = "tagsManagement"
    static let filterByTag = "filterByTag"
    static let filterByLanguage = "filterByLanguage"
    static let filterByLanguageDescription = "filterByLanguageDescription"
    static let noCardsForLanguagePair = "noCardsForLanguagePair"
    static let filterByFavorites = "filterByFavorites"
    static let showAllCards = "showAllCards"
    static let showFavoritesOnly = "showFavoritesOnly"
    static let noFavoriteCards = "noFavoriteCards"
    static let noFavoriteCardsDescription = "noFavoriteCardsDescription"
    
    // MARK: - Settings
    static let languages = "languages"
    static let voiceSettings = "voiceSettings"
    static let voiceGender = "voiceGender"
    static let maleVoice = "maleVoice"
    static let femaleVoice = "femaleVoice"
    static let cardDisplay = "cardDisplay"
    static let cardDisplayMode = "cardDisplayMode"
    static let learningMode = "learningMode"
    static let travelMode = "travelMode"
    static let learningModeDescription = "learningModeDescription"
    static let travelModeDescription = "travelModeDescription"
    
    // MARK: - Preset Collections
    static let presetCollections = "presetCollections"
    static let seeAllCollections = "seeAllCollections"
    static let importCollection = "importCollection"
    static let importButton = "importButton"
    static let importCollectionMessage = "importCollectionMessage"
    static let noCollectionsFound = "noCollectionsFound"
    static let tryAdjustingSearch = "tryAdjustingSearch"
    static let getStartedWithCollections = "getStartedWithCollections"
    static let searchCollections = "searchCollections"
    static let allCategories = "allCategories"
    static let myLanguageSettings = "myLanguageSettings"
    static let targetLanguage = "targetLanguage"
    static let theme = "theme"
    static let color = "color"
    static let backgroundStyle = "backgroundStyle"
    static let tapToSeeFullScreen = "tapToSeeFullScreen"
    
    // MARK: - Add Card
    static let enterTextInYourLanguage = "enterTextInYourLanguage"
    static let enterTextInTargetLanguage = "enterTextInTargetLanguage"
    static let addNotesOptional = "addNotesOptional"
    static let notes = "notes"
    static let tagsCount = "tagsCount"
    static let noTagsAvailableAddInSettings = "noTagsAvailableAddInSettings"
    static let translating = "translating"
    static let translationWillAppearHere = "translationWillAppearHere"
    
    // MARK: - Buttons
    static let done = "done"
    static let cancel = "cancel"
    static let save = "save"
    static let close = "close"
    static let clear = "clear"
    static let clearFilter = "clearFilter"
    static let clearSearch = "clearSearch"
    static let addCardButton = "addCardButton"
    static let edit = "edit"
    static let editCard = "editCard"
    static let delete = "delete"
    static let deleteCard = "deleteCard"
    static let deleteCardConfirmation = "deleteCardConfirmation"
    static let deleteAll = "deleteAll"
    static let deleteAllCards = "deleteAllCards"
    static let deleteAllCardsConfirmation = "deleteAllCardsConfirmation"
    static let ok = "ok"
    
    // MARK: - Card Limits
    static let cardLimitExceeded = "cardLimitExceeded"
    static let upgradeToPremium = "upgradeToPremium"
    static let cardsRemaining = "cardsRemaining"
    static let unlimitedCards = "unlimitedCards"
    
    // MARK: - Labels
    static let settingsLabel = "settingsLabel"
    static let menu = "menu"
    static let tagFilter = "tagFilter"
    static let shuffle = "shuffle"
    static let addCardLabel = "addCardLabel"
    
    // MARK: - Search
    static let searchCards = "searchCards"
    
    // MARK: - Placeholder Text
    static let placeholderAB = "placeholderAB"
    
    // MARK: - Languages
    static let english = "english"
    static let spanish = "spanish"
    static let french = "french"
    static let german = "german"
    static let italian = "italian"
    static let portuguese = "portuguese"
    static let dutch = "dutch"
    static let swedish = "swedish"
    static let chinese = "chinese"
    static let japanese = "japanese"
    static let korean = "korean"
    static let vietnamese = "vietnamese"
    static let russian = "russian"
    static let arabic = "arabic"
    static let hindi = "hindi"
    static let croatian = "croatian"
    static let ukrainian = "ukrainian"
    
    // MARK: - Background Styles
    static let gradient = "gradient"
    static let lavaLamp = "lavaLamp"
    static let snow = "snow"
    static let rain = "rain"
    static let stars = "stars"
    static let bubbles = "bubbles"
    static let waves = "waves"
    static let particles = "particles"
    static let aurora = "aurora"
    static let fireflies = "fireflies"
    static let ocean = "ocean"
    static let galaxy = "galaxy"
}

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    var localizedKey: LocalizedStringKey {
        return LocalizedStringKey(self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 
