import Foundation

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
    static let imLearning = "imLearning"
    static let continueButton = "continueButton"

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
    
    // MARK: - Settings
    static let languages = "languages"
    static let myLanguageSettings = "myLanguageSettings"
    static let targetLanguage = "targetLanguage"
    static let background = "background"
    static let backgroundColor = "backgroundColor"
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
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 
