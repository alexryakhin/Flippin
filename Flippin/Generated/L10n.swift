// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Loc {
  public enum AboutApp {
    /// about_app.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: about_app
    public static let about = Loc.tr("AboutApp", "about", fallback: "About")
    /// App Information
    public static let appInfo = Loc.tr("AboutApp", "appInfo", fallback: "App Information")
    /// App Support
    public static let appSupport = Loc.tr("AboutApp", "appSupport", fallback: "App Support")
    /// If you have any questions or need assistance, feel free to reach out to us
    public static let appSupportDescription = Loc.tr("AboutApp", "appSupportDescription", fallback: "If you have any questions or need assistance, feel free to reach out to us")
    /// Buy me a coffee
    public static let buyMeACoffee = Loc.tr("AboutApp", "buyMeACoffee", fallback: "Buy me a coffee")
    /// Contact Support
    public static let contactSupport = Loc.tr("AboutApp", "contactSupport", fallback: "Contact Support")
    /// Features
    public static let features = Loc.tr("AboutApp", "features", fallback: "Features")
    /// Follow us on social media:
    public static let followSocialMedia = Loc.tr("AboutApp", "followSocialMedia", fallback: "Follow us on social media:")
    /// Instagram
    public static let instagram = Loc.tr("AboutApp", "instagram", fallback: "Instagram")
    /// Support for major world languages
    public static let languagesDescription = Loc.tr("AboutApp", "languagesDescription", fallback: "Support for major world languages")
    /// 17 Languages
    public static let languagesTitle = Loc.tr("AboutApp", "languagesTitle", fallback: "17 Languages")
    /// Learning Analytics
    public static let learningAnalytics = Loc.tr("AboutApp", "learningAnalytics", fallback: "Learning Analytics")
    /// Track your progress and get personalized insights
    public static let learningAnalyticsDescription = Loc.tr("AboutApp", "learningAnalyticsDescription", fallback: "Track your progress and get personalized insights")
    /// Legal
    public static let legal = Loc.tr("AboutApp", "legal", fallback: "Legal")
    /// Privacy Policy
    public static let privacyPolicy = Loc.tr("AboutApp", "privacyPolicy", fallback: "Privacy Policy")
    /// Rate on App Store
    public static let rateOnAppStore = Loc.tr("AboutApp", "rateOnAppStore", fallback: "Rate on App Store")
    /// Smart Flashcards
    public static let smartCards = Loc.tr("AboutApp", "smartCards", fallback: "Smart Flashcards")
    /// Bilingual cards with auto-translation and text-to-speech
    public static let smartCardsDescription = Loc.tr("AboutApp", "smartCardsDescription", fallback: "Bilingual cards with auto-translation and text-to-speech")
    /// Support Development
    public static let support = Loc.tr("AboutApp", "support", fallback: "Support Development")
    /// If you enjoy Flippin, consider supporting its development
    public static let supportDescription = Loc.tr("AboutApp", "supportDescription", fallback: "If you enjoy Flippin, consider supporting its development")
    /// Smart flashcards for language learning
    public static let tagline = Loc.tr("AboutApp", "tagline", fallback: "Smart flashcards for language learning")
    /// Terms of Service
    public static let termsOfService = Loc.tr("AboutApp", "termsOfService", fallback: "Terms of Service")
    /// Text-to-Speech
    public static let tts = Loc.tr("AboutApp", "tts", fallback: "Text-to-Speech")
    /// Hear pronunciation with TTS technology
    public static let ttsDescription = Loc.tr("AboutApp", "ttsDescription", fallback: "Hear pronunciation with TTS technology")
    /// Version
    public static let version = Loc.tr("AboutApp", "version", fallback: "Version")
    /// Visit Website
    public static let visitWebsite = Loc.tr("AboutApp", "visitWebsite", fallback: "Visit Website")
    /// X (Twitter)
    public static let xTwitter = Loc.tr("AboutApp", "xTwitter", fallback: "X (Twitter)")
  }
  public enum AddCard {
    /// Add notes (optional)
    public static let addNotesOptional = Loc.tr("AddCard", "addNotesOptional", fallback: "Add notes (optional)")
    /// Enter text in target language
    public static let enterTextInTargetLanguage = Loc.tr("AddCard", "enterTextInTargetLanguage", fallback: "Enter text in target language")
    /// add_card.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: add_card
    public static let enterTextInYourLanguage = Loc.tr("AddCard", "enterTextInYourLanguage", fallback: "Enter text in your language")
    /// No tags available. Add some tags in Settings.
    public static let noTagsAvailableAddInSettings = Loc.tr("AddCard", "noTagsAvailableAddInSettings", fallback: "No tags available. Add some tags in Settings.")
    /// Notes
    public static let notes = Loc.tr("AddCard", "notes", fallback: "Notes")
    /// Tags (%d/5)
    public static func tagsCount(_ p1: Int) -> String {
      return Loc.tr("AddCard", "tagsCount", p1, fallback: "Tags (%d/5)")
    }
    /// Translating...
    public static let translating = Loc.tr("AddCard", "translating", fallback: "Translating...")
    /// Translation will appear here
    public static let translationWillAppearHere = Loc.tr("AddCard", "translationWillAppearHere", fallback: "Translation will appear here")
  }
  public enum AIFeatures {
    /// Get personalized insights about your learning progress
    public static let aiCoachDescription = Loc.tr("AIFeatures", "aiCoachDescription", fallback: "Get personalized insights about your learning progress")
    /// Get personalized insights about your learning
    public static let aiCoachEmptyState = Loc.tr("AIFeatures", "aiCoachEmptyState", fallback: "Get personalized insights about your learning")
    /// AI Learning Coach
    public static let aiCoachTitle = Loc.tr("AIFeatures", "aiCoachTitle", fallback: "AI Learning Coach")
    /// AI features are temporarily unavailable
    public static let aiFeatureDisabled = Loc.tr("AIFeatures", "aiFeatureDisabled", fallback: "AI features are temporarily unavailable")
    /// Describe what you want to learn and AI will create a custom flashcard collection for you
    public static let aiGeneratorDescription = Loc.tr("AIFeatures", "aiGeneratorDescription", fallback: "Describe what you want to learn and AI will create a custom flashcard collection for you")
    /// Create custom flashcard collections with AI
    public static let aiGeneratorSubtitle = Loc.tr("AIFeatures", "aiGeneratorSubtitle", fallback: "Create custom flashcard collections with AI")
    /// AIFeatures.strings
    ///   Flippin
    ///   
    ///   AI-powered features localization
    ///   Language: en
    ///   Section: ai_features
    public static let aiGeneratorTitle = Loc.tr("AIFeatures", "aiGeneratorTitle", fallback: "AI Collection Generator")
    /// Failed to import cards. You may have reached your card limit.
    public static let aiImportFailed = Loc.tr("AIFeatures", "aiImportFailed", fallback: "Failed to import cards. You may have reached your card limit.")
    /// Failed to generate insights. Please try again.
    public static let aiInsightsFailed = Loc.tr("AIFeatures", "aiInsightsFailed", fallback: "Failed to generate insights. Please try again.")
    /// Received invalid response from AI. Please try again.
    public static let aiInvalidResponse = Loc.tr("AIFeatures", "aiInvalidResponse", fallback: "Received invalid response from AI. Please try again.")
    /// Network connection failed. Check your internet and try again.
    public static let aiNetworkError = Loc.tr("AIFeatures", "aiNetworkError", fallback: "Network connection failed. Check your internet and try again.")
    /// ChatGPT service is not ready. Please try again later.
    public static let aiNotReady = Loc.tr("AIFeatures", "aiNotReady", fallback: "ChatGPT service is not ready. Please try again later.")
    /// An unexpected error occurred. Please try again.
    public static let aiUnexpectedError = Loc.tr("AIFeatures", "aiUnexpectedError", fallback: "An unexpected error occurred. Please try again.")
    /// AI is analyzing your progress...
    public static let analyzingProgress = Loc.tr("AIFeatures", "analyzingProgress", fallback: "AI is analyzing your progress...")
    /// Error
    public static let error = Loc.tr("AIFeatures", "error", fallback: "Error")
    /// Vocabulary for navigating airports
    public static let exampleAirport = Loc.tr("AIFeatures", "exampleAirport", fallback: "Vocabulary for navigating airports")
    /// Business meeting expressions
    public static let exampleBusiness = Loc.tr("AIFeatures", "exampleBusiness", fallback: "Business meeting expressions")
    /// Example Requests
    public static let exampleRequests = Loc.tr("AIFeatures", "exampleRequests", fallback: "Example Requests")
    /// Phrases for ordering at restaurants
    public static let exampleRestaurant = Loc.tr("AIFeatures", "exampleRestaurant", fallback: "Phrases for ordering at restaurants")
    /// Generate Collection
    public static let generateCollection = Loc.tr("AIFeatures", "generateCollection", fallback: "Generate Collection")
    /// Generated %@
    public static func generatedAt(_ p1: Any) -> String {
      return Loc.tr("AIFeatures", "generatedAt", String(describing: p1), fallback: "Generated %@")
    }
    /// Generate Insights
    public static let generateInsights = Loc.tr("AIFeatures", "generateInsights", fallback: "Generate Insights")
    /// High Priority
    public static let highPriority = Loc.tr("AIFeatures", "highPriority", fallback: "High Priority")
    /// Import All
    public static let importAll = Loc.tr("AIFeatures", "importAll", fallback: "Import All")
    /// Key Insights
    public static let keyInsights = Loc.tr("AIFeatures", "keyInsights", fallback: "Key Insights")
    /// Learning Coach
    public static let learningCoach = Loc.tr("AIFeatures", "learningCoach", fallback: "Learning Coach")
    /// Low Priority
    public static let lowPriority = Loc.tr("AIFeatures", "lowPriority", fallback: "Low Priority")
    /// Medium Priority
    public static let mediumPriority = Loc.tr("AIFeatures", "mediumPriority", fallback: "Medium Priority")
    /// Number of Cards
    public static let numberOfCards = Loc.tr("AIFeatures", "numberOfCards", fallback: "Number of Cards")
    /// OK
    public static let ok = Loc.tr("AIFeatures", "ok", fallback: "OK")
    /// Recommendations
    public static let recommendations = Loc.tr("AIFeatures", "recommendations", fallback: "Recommendations")
    /// Refresh Insights
    public static let refreshInsights = Loc.tr("AIFeatures", "refreshInsights", fallback: "Refresh Insights")
    /// e.g., Phrases for ordering at restaurants
    public static let requestPlaceholder = Loc.tr("AIFeatures", "requestPlaceholder", fallback: "e.g., Phrases for ordering at restaurants")
    /// Request too long. Please keep it under 500 characters.
    public static let requestTooLong = Loc.tr("AIFeatures", "requestTooLong", fallback: "Request too long. Please keep it under 500 characters.")
    /// Try Again
    public static let tryAgain = Loc.tr("AIFeatures", "tryAgain", fallback: "Try Again")
    /// View Detailed Insights
    public static let viewDetailedInsights = Loc.tr("AIFeatures", "viewDetailedInsights", fallback: "View Detailed Insights")
    /// Your Request
    public static let yourRequest = Loc.tr("AIFeatures", "yourRequest", fallback: "Your Request")
  }
  public enum Analytics {
    /// Accuracy
    public static let accuracy = Loc.tr("Analytics", "accuracy", fallback: "Accuracy")
    /// All Time
    public static let allTime = Loc.tr("Analytics", "allTime", fallback: "All Time")
    /// analytics.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: analytics
    public static let analytics = Loc.tr("Analytics", "analytics", fallback: "Analytics")
    /// Cards Mastered
    public static let cardsMastered = Loc.tr("Analytics", "cardsMastered", fallback: "Cards Mastered")
    /// Cards Studied
    public static let cardsStudied = Loc.tr("Analytics", "cardsStudied", fallback: "Cards Studied")
    /// Cards Studied Today
    public static let cardsStudiedToday = Loc.tr("Analytics", "cardsStudiedToday", fallback: "Cards Studied Today")
    /// Detailed Analytics
    public static let detailedAnalytics = Loc.tr("Analytics", "detailedAnalytics", fallback: "Detailed Analytics")
    /// Detailed Progress Reports
    public static let detailedProgressReports = Loc.tr("Analytics", "detailedProgressReports", fallback: "Detailed Progress Reports")
    /// Track your learning patterns and improvement over time
    public static let detailedProgressReportsDescription = Loc.tr("Analytics", "detailedProgressReportsDescription", fallback: "Track your learning patterns and improvement over time")
    /// Insights
    public static let insights = Loc.tr("Analytics", "insights", fallback: "Insights")
    /// Last Study Session
    public static let lastStudySession = Loc.tr("Analytics", "lastStudySession", fallback: "Last Study Session")
    /// Learning
    public static let learning = Loc.tr("Analytics", "learning", fallback: "Learning")
    /// Mastered
    public static let mastered = Loc.tr("Analytics", "mastered", fallback: "Mastered")
    /// Mastery Progress
    public static let masteryProgress = Loc.tr("Analytics", "masteryProgress", fallback: "Mastery Progress")
    /// Month
    public static let month = Loc.tr("Analytics", "month", fallback: "Month")
    /// Needs Review
    public static let needsReview = Loc.tr("Analytics", "needsReview", fallback: "Needs Review")
    /// No Analytics Data
    public static let noAnalyticsData = Loc.tr("Analytics", "noAnalyticsData", fallback: "No Analytics Data")
    /// No Recent Activity
    public static let noRecentActivity = Loc.tr("Analytics", "noRecentActivity", fallback: "No Recent Activity")
    /// No study data available
    public static let noStudyDataAvailable = Loc.tr("Analytics", "noStudyDataAvailable", fallback: "No study data available")
    /// Overview
    public static let overview = Loc.tr("Analytics", "overview", fallback: "Overview")
    /// Performance
    public static let performance = Loc.tr("Analytics", "performance", fallback: "Performance")
    /// Performance Insights
    public static let performanceInsights = Loc.tr("Analytics", "performanceInsights", fallback: "Performance Insights")
    /// Get personalized recommendations to improve your study habits
    public static let performanceInsightsDescription = Loc.tr("Analytics", "performanceInsightsDescription", fallback: "Get personalized recommendations to improve your study habits")
    /// Practice Time
    public static let practiceTime = Loc.tr("Analytics", "practiceTime", fallback: "Practice Time")
    /// Progress
    public static let progress = Loc.tr("Analytics", "progress", fallback: "Progress")
    /// Recent Activity
    public static let recentActivity = Loc.tr("Analytics", "recentActivity", fallback: "Recent Activity")
    /// Sessions
    public static let sessions = Loc.tr("Analytics", "sessions", fallback: "Sessions")
    /// Start studying to see your learning progress!
    public static let startStudyingToSeeProgress = Loc.tr("Analytics", "startStudyingToSeeProgress", fallback: "Start studying to see your learning progress!")
    /// Your study sessions will appear here
    public static let studySessionsWillAppearHere = Loc.tr("Analytics", "studySessionsWillAppearHere", fallback: "Your study sessions will appear here")
    /// Study Streak
    public static let studyStreak = Loc.tr("Analytics", "studyStreak", fallback: "Study Streak")
    /// Study Time
    public static let studyTime = Loc.tr("Analytics", "studyTime", fallback: "Study Time")
    /// Study Time Analytics
    public static let studyTimeAnalytics = Loc.tr("Analytics", "studyTimeAnalytics", fallback: "Study Time Analytics")
    /// Analyze your study sessions and optimize your learning
    public static let studyTimeAnalyticsDescription = Loc.tr("Analytics", "studyTimeAnalyticsDescription", fallback: "Analyze your study sessions and optimize your learning")
    /// Time
    public static let time = Loc.tr("Analytics", "time", fallback: "Time")
    /// Time Range
    public static let timeRange = Loc.tr("Analytics", "timeRange", fallback: "Time Range")
    /// Today
    public static let today = Loc.tr("Analytics", "today", fallback: "Today")
    /// Today's Study
    public static let todaysStudy = Loc.tr("Analytics", "todaysStudy", fallback: "Today's Study")
    /// Total Study Time
    public static let totalStudyTime = Loc.tr("Analytics", "totalStudyTime", fallback: "Total Study Time")
    /// Unlock Advanced Analytics
    public static let unlockAdvancedAnalytics = Loc.tr("Analytics", "unlockAdvancedAnalytics", fallback: "Unlock Advanced Analytics")
    /// Upgrade to Premium
    public static let upgradeToPremium = Loc.tr("Analytics", "upgradeToPremium", fallback: "Upgrade to Premium")
    /// View All
    public static let viewAll = Loc.tr("Analytics", "viewAll", fallback: "View All")
    /// Week
    public static let week = Loc.tr("Analytics", "week", fallback: "Week")
    /// Year
    public static let year = Loc.tr("Analytics", "year", fallback: "Year")
  }
  public enum BackgroundStyles {
    /// Aurora
    public static let aurora = Loc.tr("BackgroundStyles", "aurora", fallback: "Aurora")
    /// Bubbles
    public static let bubbles = Loc.tr("BackgroundStyles", "bubbles", fallback: "Bubbles")
    /// Fireflies
    public static let fireflies = Loc.tr("BackgroundStyles", "fireflies", fallback: "Fireflies")
    /// Galaxy
    public static let galaxy = Loc.tr("BackgroundStyles", "galaxy", fallback: "Galaxy")
    /// background_styles.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: background_styles
    public static let gradient = Loc.tr("BackgroundStyles", "gradient", fallback: "Gradient")
    /// Lava Lamp
    public static let lavaLamp = Loc.tr("BackgroundStyles", "lavaLamp", fallback: "Lava Lamp")
    /// Ocean
    public static let ocean = Loc.tr("BackgroundStyles", "ocean", fallback: "Ocean")
    /// Particles
    public static let particles = Loc.tr("BackgroundStyles", "particles", fallback: "Particles")
    /// Rain
    public static let rain = Loc.tr("BackgroundStyles", "rain", fallback: "Rain")
    /// Snow
    public static let snow = Loc.tr("BackgroundStyles", "snow", fallback: "Snow")
    /// Stars
    public static let stars = Loc.tr("BackgroundStyles", "stars", fallback: "Stars")
    /// Waves
    public static let waves = Loc.tr("BackgroundStyles", "waves", fallback: "Waves")
  }
  public enum Buttons {
    /// Add Card
    public static let addCardButton = Loc.tr("Buttons", "addCardButton", fallback: "Add Card")
    /// Cancel
    public static let cancel = Loc.tr("Buttons", "cancel", fallback: "Cancel")
    /// Clear
    public static let clear = Loc.tr("Buttons", "clear", fallback: "Clear")
    /// Clear Filter
    public static let clearFilter = Loc.tr("Buttons", "clearFilter", fallback: "Clear Filter")
    /// Clear Search
    public static let clearSearch = Loc.tr("Buttons", "clearSearch", fallback: "Clear Search")
    /// Close
    public static let close = Loc.tr("Buttons", "close", fallback: "Close")
    /// Delete
    public static let delete = Loc.tr("Buttons", "delete", fallback: "Delete")
    /// Delete All
    public static let deleteAll = Loc.tr("Buttons", "deleteAll", fallback: "Delete All")
    /// Delete All Cards
    public static let deleteAllCards = Loc.tr("Buttons", "deleteAllCards", fallback: "Delete All Cards")
    /// Are you sure you want to delete all cards? This action cannot be undone.
    public static let deleteAllCardsConfirmation = Loc.tr("Buttons", "deleteAllCardsConfirmation", fallback: "Are you sure you want to delete all cards? This action cannot be undone.")
    /// Delete Card
    public static let deleteCard = Loc.tr("Buttons", "deleteCard", fallback: "Delete Card")
    /// Are you sure you want to delete this card? This action cannot be undone.
    public static let deleteCardConfirmation = Loc.tr("Buttons", "deleteCardConfirmation", fallback: "Are you sure you want to delete this card? This action cannot be undone.")
    /// buttons.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: buttons
    public static let done = Loc.tr("Buttons", "done", fallback: "Done")
    /// Edit
    public static let edit = Loc.tr("Buttons", "edit", fallback: "Edit")
    /// Edit Card
    public static let editCard = Loc.tr("Buttons", "editCard", fallback: "Edit Card")
    /// OK
    public static let ok = Loc.tr("Buttons", "ok", fallback: "OK")
    /// Save
    public static let save = Loc.tr("Buttons", "save", fallback: "Save")
    /// Skip
    public static let skip = Loc.tr("Buttons", "skip", fallback: "Skip")
  }
  public enum CardImages {
    /// Add Image
    public static let addImage = Loc.tr("CardImages", "addImage", fallback: "Add Image")
    /// Current Image
    public static let currentImage = Loc.tr("CardImages", "currentImage", fallback: "Current Image")
    /// Image Attached
    public static let imageAttached = Loc.tr("CardImages", "imageAttached", fallback: "Image Attached")
    /// Image unavailable
    public static let imageUnavailable = Loc.tr("CardImages", "imageUnavailable", fallback: "Image unavailable")
    /// Remove
    public static let remove = Loc.tr("CardImages", "remove", fallback: "Remove")
    /// Image
    public static let sectionTitle = Loc.tr("CardImages", "sectionTitle", fallback: "Image")
    /// Tap to change
    public static let tapToChange = Loc.tr("CardImages", "tapToChange", fallback: "Tap to change")
    public enum ImageOnboarding {
      /// Get Started
      public static let getStarted = Loc.tr("CardImages", "imageOnboarding.getStarted", fallback: "Get Started")
      /// See how your cards will look:
      public static let previewTitle = Loc.tr("CardImages", "imageOnboarding.previewTitle", fallback: "See how your cards will look:")
      /// Skip
      public static let skip = Loc.tr("CardImages", "imageOnboarding.skip", fallback: "Skip")
      /// Add images to your flashcards for better memory retention and visual learning
      public static let subtitle = Loc.tr("CardImages", "imageOnboarding.subtitle", fallback: "Add images to your flashcards for better memory retention and visual learning")
      /// CardImages.strings
      ///   Flippin
      ///   
      ///   Localization for card images and image onboarding flow
      public static let title = Loc.tr("CardImages", "imageOnboarding.title", fallback: "Visual Learning")
      public enum Benefit {
        public enum Enhanced {
          /// Make your flashcards more engaging
          public static let description = Loc.tr("CardImages", "imageOnboarding.benefit.enhanced.description", fallback: "Make your flashcards more engaging")
          /// Enhanced Experience
          public static let title = Loc.tr("CardImages", "imageOnboarding.benefit.enhanced.title", fallback: "Enhanced Experience")
        }
        public enum Memory {
          /// Visual cues help you remember faster
          public static let description = Loc.tr("CardImages", "imageOnboarding.benefit.memory.description", fallback: "Visual cues help you remember faster")
          /// Better Memory
          public static let title = Loc.tr("CardImages", "imageOnboarding.benefit.memory.title", fallback: "Better Memory")
        }
        public enum Visual {
          /// Learn with images, not just text
          public static let description = Loc.tr("CardImages", "imageOnboarding.benefit.visual.description", fallback: "Learn with images, not just text")
          /// Visual Learning
          public static let title = Loc.tr("CardImages", "imageOnboarding.benefit.visual.title", fallback: "Visual Learning")
        }
      }
      public enum Example {
        /// I'd like to get your business card, please.
        public static let card1 = Loc.tr("CardImages", "imageOnboarding.example.card1", fallback: "I'd like to get your business card, please.")
        /// I need to warm up.
        public static let card2 = Loc.tr("CardImages", "imageOnboarding.example.card2", fallback: "I need to warm up.")
        /// I always travel by plane.
        public static let card3 = Loc.tr("CardImages", "imageOnboarding.example.card3", fallback: "I always travel by plane.")
      }
    }
    public enum ImageSearch {
      /// Cancel
      public static let cancel = Loc.tr("CardImages", "imageSearch.cancel", fallback: "Cancel")
      /// Load More
      public static let loadMore = Loc.tr("CardImages", "imageSearch.loadMore", fallback: "Load More")
      /// Search for images...
      public static let searchPrompt = Loc.tr("CardImages", "imageSearch.searchPrompt", fallback: "Search for images...")
      /// Select
      public static let select = Loc.tr("CardImages", "imageSearch.select", fallback: "Select")
      /// Search Images
      public static let title = Loc.tr("CardImages", "imageSearch.title", fallback: "Search Images")
      public enum EmptyState {
        /// Enter a search term above to find beautiful images from Pexels
        public static let subtitle = Loc.tr("CardImages", "imageSearch.emptyState.subtitle", fallback: "Enter a search term above to find beautiful images from Pexels")
        /// Search for images
        public static let title = Loc.tr("CardImages", "imageSearch.emptyState.title", fallback: "Search for images")
      }
      public enum Error {
        /// OK
        public static let ok = Loc.tr("CardImages", "imageSearch.error.ok", fallback: "OK")
        /// Error
        public static let title = Loc.tr("CardImages", "imageSearch.error.title", fallback: "Error")
        /// Unknown error occurred
        public static let unknown = Loc.tr("CardImages", "imageSearch.error.unknown", fallback: "Unknown error occurred")
      }
    }
  }
  public enum CardLimits {
    /// Card limit exceeded. You have %d cards out of %d allowed. Upgrade to premium for unlimited cards.
    public static func cardLimitExceeded(_ p1: Int, _ p2: Int) -> String {
      return Loc.tr("CardLimits", "cardLimitExceeded", p1, p2, fallback: "Card limit exceeded. You have %d cards out of %d allowed. Upgrade to premium for unlimited cards.")
    }
    /// card_limits.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: card_limits
    public static func cardsUsedOfLimit(_ p1: Int, _ p2: Int) -> String {
      return Loc.tr("CardLimits", "cardsUsedOfLimit", p1, p2, fallback: "%d of %d cards")
    }
    /// Free users are limited to %d cards
    public static func freeUsersLimitedTo(_ p1: Int) -> String {
      return Loc.tr("CardLimits", "freeUsersLimitedTo", p1, fallback: "Free users are limited to %d cards")
    }
    /// Purchase unlimited cards to add more cards to your collection
    public static let purchaseUnlimitedCards = Loc.tr("CardLimits", "purchaseUnlimitedCards", fallback: "Purchase unlimited cards to add more cards to your collection")
    /// Unlimited Cards
    public static let unlimitedCards = Loc.tr("CardLimits", "unlimitedCards", fallback: "Unlimited Cards")
    /// Upgrade
    public static let upgrade = Loc.tr("CardLimits", "upgrade", fallback: "Upgrade")
  }
  public enum CardManagement {
    /// Difficult Cards
    public static let difficultCards = Loc.tr("CardManagement", "difficultCards", fallback: "Difficult Cards")
    /// card_management.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: card_management
    public static let noDifficultCards = Loc.tr("CardManagement", "noDifficultCards", fallback: "No Difficult Cards")
    /// You don't have any cards marked as difficult yet. Study more cards to see difficulty levels.
    public static let noDifficultCardsDescription = Loc.tr("CardManagement", "noDifficultCardsDescription", fallback: "You don't have any cards marked as difficult yet. Study more cards to see difficulty levels.")
  }
  public enum CardViews {
    /// card_views.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: card_views
    public static let flip = Loc.tr("CardViews", "flip", fallback: "Flip")
    /// Tap to go back
    public static let tapToGoBack = Loc.tr("CardViews", "tapToGoBack", fallback: "Tap to go back")
  }
  public enum Categories {
    /// categories.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: categories
    public static let categoryBasics = Loc.tr("Categories", "categoryBasics", fallback: "Basics")
    /// Emergency
    public static let categoryEmergency = Loc.tr("Categories", "categoryEmergency", fallback: "Emergency")
    /// Entertainment
    public static let categoryEntertainment = Loc.tr("Categories", "categoryEntertainment", fallback: "Entertainment")
    /// Food
    public static let categoryFood = Loc.tr("Categories", "categoryFood", fallback: "Food")
    /// Lifestyle
    public static let categoryLifestyle = Loc.tr("Categories", "categoryLifestyle", fallback: "Lifestyle")
    /// Professional
    public static let categoryProfessional = Loc.tr("Categories", "categoryProfessional", fallback: "Professional")
    /// Shopping
    public static let categoryShopping = Loc.tr("Categories", "categoryShopping", fallback: "Shopping")
    /// Social
    public static let categorySocial = Loc.tr("Categories", "categorySocial", fallback: "Social")
    /// Technology
    public static let categoryTechnology = Loc.tr("Categories", "categoryTechnology", fallback: "Technology")
    /// Travel
    public static let categoryTravel = Loc.tr("Categories", "categoryTravel", fallback: "Travel")
    /// Weather
    public static let categoryWeather = Loc.tr("Categories", "categoryWeather", fallback: "Weather")
  }
  public enum ContentViews {
    /// Add your first card to start learning
    public static let addFirstCardToStartLearning = Loc.tr("ContentViews", "addFirstCardToStartLearning", fallback: "Add your first card to start learning")
    /// No cards available
    public static let noCardsAvailable = Loc.tr("ContentViews", "noCardsAvailable", fallback: "No cards available")
    /// No cards for this pair of languages
    public static let noCardsForLanguagePair = Loc.tr("ContentViews", "noCardsForLanguagePair", fallback: "No cards for this pair of languages")
    /// No cards found
    public static let noCardsFound = Loc.tr("ContentViews", "noCardsFound", fallback: "No cards found")
    /// No cards found with tag "%@"
    public static func noCardsFoundWithTag(_ p1: Any) -> String {
      return Loc.tr("ContentViews", "noCardsFoundWithTag", String(describing: p1), fallback: "No cards found with tag \"%@\"")
    }
    /// No cards match your search
    public static let noCardsMatchSearch = Loc.tr("ContentViews", "noCardsMatchSearch", fallback: "No cards match your search")
    /// No cards with selected tag
    public static let noCardsWithSelectedTag = Loc.tr("ContentViews", "noCardsWithSelectedTag", fallback: "No cards with selected tag")
    /// content_views.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: content_views
    public static let noCardsYet = Loc.tr("ContentViews", "noCardsYet", fallback: "No cards yet")
    /// Tap the + button to add your first card
    public static let tapToAddFirstCard = Loc.tr("ContentViews", "tapToAddFirstCard", fallback: "Tap the + button to add your first card")
  }
  public enum DetailedAnalytics {
    /// Accuracy Trends
    public static let accuracyTrends = Loc.tr("DetailedAnalytics", "accuracyTrends", fallback: "Accuracy Trends")
    /// Achievements
    public static let achievements = Loc.tr("DetailedAnalytics", "achievements", fallback: "Achievements")
    /// Active Recall
    public static let activeRecall = Loc.tr("DetailedAnalytics", "activeRecall", fallback: "Active Recall")
    /// Try to recall the answer before flipping the card.
    public static let activeRecallDescription = Loc.tr("DetailedAnalytics", "activeRecallDescription", fallback: "Try to recall the answer before flipping the card.")
    /// detailed_analytics.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: detailed_analytics
    public static let analyticsTab = Loc.tr("DetailedAnalytics", "analyticsTab", fallback: "Analytics Tab")
    /// Average
    public static let average = Loc.tr("DetailedAnalytics", "average", fallback: "Average")
    /// Average Session Duration
    public static let averageSessionDuration = Loc.tr("DetailedAnalytics", "averageSessionDuration", fallback: "Average Session Duration")
    /// Average Session
    public static let averageSessionTitle = Loc.tr("DetailedAnalytics", "averageSessionTitle", fallback: "Average Session")
    /// Based on %@ data
    public static func basedOnData(_ p1: Any) -> String {
      return Loc.tr("DetailedAnalytics", "basedOnData", String(describing: p1), fallback: "Based on %@ data")
    }
    /// Browse Collections
    public static let browseCollections = Loc.tr("DetailedAnalytics", "browseCollections", fallback: "Browse Collections")
    /// Card Difficulty Analysis
    public static let cardDifficultyAnalysis = Loc.tr("DetailedAnalytics", "cardDifficultyAnalysis", fallback: "Card Difficulty Analysis")
    /// cards
    public static let cards = Loc.tr("DetailedAnalytics", "cards", fallback: "cards")
    /// Cards Mastered
    public static let cardsMasteredTitle = Loc.tr("DetailedAnalytics", "cardsMasteredTitle", fallback: "Cards Mastered")
    /// Cards per Hour
    public static let cardsPerHour = Loc.tr("DetailedAnalytics", "cardsPerHour", fallback: "Cards per Hour")
    /// Cards per Session
    public static let cardsPerSession = Loc.tr("DetailedAnalytics", "cardsPerSession", fallback: "Cards per Session")
    /// Collection Size
    public static let collectionSize = Loc.tr("DetailedAnalytics", "collectionSize", fallback: "Collection Size")
    /// consecutive days
    public static let consecutiveDays = Loc.tr("DetailedAnalytics", "consecutiveDays", fallback: "consecutive days")
    /// Context Learning
    public static let contextLearning = Loc.tr("DetailedAnalytics", "contextLearning", fallback: "Context Learning")
    /// Learn words in phrases rather than isolation.
    public static let contextLearningDescription = Loc.tr("DetailedAnalytics", "contextLearningDescription", fallback: "Learn words in phrases rather than isolation.")
    /// Dedicated
    public static let dedicated = Loc.tr("DetailedAnalytics", "dedicated", fallback: "Dedicated")
    /// First Steps
    public static let firstSteps = Loc.tr("DetailedAnalytics", "firstSteps", fallback: "First Steps")
    /// Language Progress
    public static let languageProgress = Loc.tr("DetailedAnalytics", "languageProgress", fallback: "Language Progress")
    /// Learning Milestones
    public static let learningMilestones = Loc.tr("DetailedAnalytics", "learningMilestones", fallback: "Learning Milestones")
    /// Learning Speed
    public static let learningSpeed = Loc.tr("DetailedAnalytics", "learningSpeed", fallback: "Learning Speed")
    /// Learning Tips
    public static let learningTips = Loc.tr("DetailedAnalytics", "learningTips", fallback: "Learning Tips")
    /// Master Learner
    public static let masterLearner = Loc.tr("DetailedAnalytics", "masterLearner", fallback: "Master Learner")
    /// Mastery Timeline
    public static let masteryTimeline = Loc.tr("DetailedAnalytics", "masteryTimeline", fallback: "Mastery Timeline")
    /// Most Active Time
    public static let mostActiveTime = Loc.tr("DetailedAnalytics", "mostActiveTime", fallback: "Most Active Time")
    /// No difficulty data available
    public static let noDifficultyDataAvailable = Loc.tr("DetailedAnalytics", "noDifficultyDataAvailable", fallback: "No difficulty data available")
    /// No insights available yet
    public static let noInsightsAvailableYet = Loc.tr("DetailedAnalytics", "noInsightsAvailableYet", fallback: "No insights available yet")
    /// No recommendations at this time
    public static let noRecommendationsAtThisTime = Loc.tr("DetailedAnalytics", "noRecommendationsAtThisTime", fallback: "No recommendations at this time")
    /// per session
    public static let perSession = Loc.tr("DetailedAnalytics", "perSession", fallback: "per session")
    /// Personalized Insights
    public static let personalizedInsights = Loc.tr("DetailedAnalytics", "personalizedInsights", fallback: "Personalized Insights")
    /// Practice Mode
    public static let practiceMode = Loc.tr("DetailedAnalytics", "practiceMode", fallback: "Practice Mode")
    /// Practice Time
    public static let practiceTimeTitle = Loc.tr("DetailedAnalytics", "practiceTimeTitle", fallback: "Practice Time")
    /// Preferred Session Length
    public static let preferredSessionLength = Loc.tr("DetailedAnalytics", "preferredSessionLength", fallback: "Preferred Session Length")
    /// Recommendations
    public static let recommendations = Loc.tr("DetailedAnalytics", "recommendations", fallback: "Recommendations")
    /// Session Frequency
    public static let sessionFrequency = Loc.tr("DetailedAnalytics", "sessionFrequency", fallback: "Session Frequency")
    /// Session Performance
    public static let sessionPerformance = Loc.tr("DetailedAnalytics", "sessionPerformance", fallback: "Session Performance")
    /// Spaced Repetition
    public static let spacedRepetition = Loc.tr("DetailedAnalytics", "spacedRepetition", fallback: "Spaced Repetition")
    /// Review cards at increasing intervals for better retention.
    public static let spacedRepetitionDescription = Loc.tr("DetailedAnalytics", "spacedRepetitionDescription", fallback: "Review cards at increasing intervals for better retention.")
    /// Start Review
    public static let startReview = Loc.tr("DetailedAnalytics", "startReview", fallback: "Start Review")
    /// Study Frequency
    public static let studyFrequency = Loc.tr("DetailedAnalytics", "studyFrequency", fallback: "Study Frequency")
    /// Study Now
    public static let studyNow = Loc.tr("DetailedAnalytics", "studyNow", fallback: "Study Now")
    /// Study Patterns
    public static let studyPatterns = Loc.tr("DetailedAnalytics", "studyPatterns", fallback: "Study Patterns")
    /// Study Streak
    public static let studyStreakTitle = Loc.tr("DetailedAnalytics", "studyStreakTitle", fallback: "Study Streak")
    /// Study Time
    public static let studyTimeTitle = Loc.tr("DetailedAnalytics", "studyTimeTitle", fallback: "Study Time")
    /// This Month
    public static let thisMonth = Loc.tr("DetailedAnalytics", "thisMonth", fallback: "This Month")
    /// This Week
    public static let thisWeek = Loc.tr("DetailedAnalytics", "thisWeek", fallback: "This Week")
    /// This Year
    public static let thisYear = Loc.tr("DetailedAnalytics", "thisYear", fallback: "This Year")
    /// Time Master
    public static let timeMaster = Loc.tr("DetailedAnalytics", "timeMaster", fallback: "Time Master")
    /// Total Vocabulary
    public static let totalVocabulary = Loc.tr("DetailedAnalytics", "totalVocabulary", fallback: "Total Vocabulary")
    /// Vocabulary Growth
    public static let vocabularyGrowth = Loc.tr("DetailedAnalytics", "vocabularyGrowth", fallback: "Vocabulary Growth")
    /// Vocabulary Master
    public static let vocabularyMaster = Loc.tr("DetailedAnalytics", "vocabularyMaster", fallback: "Vocabulary Master")
    /// vs. Average
    public static let vsAverage = Loc.tr("DetailedAnalytics", "vsAverage", fallback: "vs. Average")
    /// Week Warrior
    public static let weekWarrior = Loc.tr("DetailedAnalytics", "weekWarrior", fallback: "Week Warrior")
  }
  public enum Errors {
    /// Errors.strings
    ///   Flippin
    /// 
    ///   Created by Alexander Riakhin on 9/7/25.
    public static let error = Loc.tr("Errors", "error", fallback: "Error")
    /// Failed to create card: %@
    public static func failedToCreateCard(_ p1: Any) -> String {
      return Loc.tr("Errors", "failedToCreateCard", String(describing: p1), fallback: "Failed to create card: %@")
    }
    /// JSON data is invalid
    public static let invalidJSON = Loc.tr("Errors", "invalidJSON", fallback: "JSON data is invalid")
    /// Ooops...
    public static let oops = Loc.tr("Errors", "oops", fallback: "Ooops...")
    /// Unknown Error
    public static let unknownError = Loc.tr("Errors", "unknown_error", fallback: "Unknown Error")
  }
  public enum Labels {
    /// Add card
    public static let addCardLabel = Loc.tr("Labels", "addCardLabel", fallback: "Add card")
    /// Menu
    public static let menu = Loc.tr("Labels", "menu", fallback: "Menu")
    /// labels.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: labels
    public static let settingsLabel = Loc.tr("Labels", "settingsLabel", fallback: "Settings")
    /// Shuffle
    public static let shuffle = Loc.tr("Labels", "shuffle", fallback: "Shuffle")
    /// Tag filter
    public static let tagFilter = Loc.tr("Labels", "tagFilter", fallback: "Tag filter")
  }
  public enum Languages {
    /// Arabic
    public static let arabic = Loc.tr("Languages", "arabic", fallback: "Arabic")
    /// Chinese
    public static let chinese = Loc.tr("Languages", "chinese", fallback: "Chinese")
    /// Croatian
    public static let croatian = Loc.tr("Languages", "croatian", fallback: "Croatian")
    /// Dutch
    public static let dutch = Loc.tr("Languages", "dutch", fallback: "Dutch")
    /// languages.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: languages
    public static let english = Loc.tr("Languages", "english", fallback: "English")
    /// French
    public static let french = Loc.tr("Languages", "french", fallback: "French")
    /// German
    public static let german = Loc.tr("Languages", "german", fallback: "German")
    /// Hindi
    public static let hindi = Loc.tr("Languages", "hindi", fallback: "Hindi")
    /// Italian
    public static let italian = Loc.tr("Languages", "italian", fallback: "Italian")
    /// Japanese
    public static let japanese = Loc.tr("Languages", "japanese", fallback: "Japanese")
    /// Korean
    public static let korean = Loc.tr("Languages", "korean", fallback: "Korean")
    /// Portuguese
    public static let portuguese = Loc.tr("Languages", "portuguese", fallback: "Portuguese")
    /// Russian
    public static let russian = Loc.tr("Languages", "russian", fallback: "Russian")
    /// Spanish
    public static let spanish = Loc.tr("Languages", "spanish", fallback: "Spanish")
    /// Swedish
    public static let swedish = Loc.tr("Languages", "swedish", fallback: "Swedish")
    /// Ukrainian
    public static let ukrainian = Loc.tr("Languages", "ukrainian", fallback: "Ukrainian")
    /// Vietnamese
    public static let vietnamese = Loc.tr("Languages", "vietnamese", fallback: "Vietnamese")
  }
  public enum LearningAnalyticsService {
    /// Your accuracy is %d%%. Focus on quality over speed.
    public static func accuracyPercentageFocusQuality(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "accuracyPercentageFocusQuality", p1, fallback: "Your accuracy is %d%%. Focus on quality over speed.")
    }
    /// Add more vocabulary
    public static let addMoreVocabulary = Loc.tr("LearningAnalyticsService", "addMoreVocabulary", fallback: "Add more vocabulary")
    /// Afternoon (12-5 PM)
    public static let afternoon = Loc.tr("LearningAnalyticsService", "afternoon", fallback: "Afternoon (12-5 PM)")
    /// Build consistency
    public static let buildConsistency = Loc.tr("LearningAnalyticsService", "buildConsistency", fallback: "Build consistency")
    /// %d cards need more practice. Focus on these to improve accuracy.
    public static func cardsNeedMorePractice(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "cardsNeedMorePractice", p1, fallback: "%d cards need more practice. Focus on these to improve accuracy.")
    }
    /// Completed
    public static let completed = Loc.tr("LearningAnalyticsService", "completed", fallback: "Completed")
    /// Completed study session
    public static let completedStudySession = Loc.tr("LearningAnalyticsService", "completedStudySession", fallback: "Completed study session")
    /// Consistent learning pattern
    public static let consistentLearningPattern = Loc.tr("LearningAnalyticsService", "consistentLearningPattern", fallback: "Consistent learning pattern")
    /// Daily
    public static let daily = Loc.tr("LearningAnalyticsService", "daily", fallback: "Daily")
    /// You're %d days away from a new achievement!
    public static func daysAwayFromAchievement(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "daysAwayFromAchievement", p1, fallback: "You're %d days away from a new achievement!")
    }
    /// Easy
    public static let easy = Loc.tr("LearningAnalyticsService", "easy", fallback: "Easy")
    /// Evening (5-9 PM)
    public static let evening = Loc.tr("LearningAnalyticsService", "evening", fallback: "Evening (5-9 PM)")
    /// Excellent progress
    public static let excellentProgress = Loc.tr("LearningAnalyticsService", "excellentProgress", fallback: "Excellent progress")
    /// Extend your streak
    public static let extendYourStreak = Loc.tr("LearningAnalyticsService", "extendYourStreak", fallback: "Extend your streak")
    /// A few times this week
    public static let fewTimesThisWeek = Loc.tr("LearningAnalyticsService", "fewTimesThisWeek", fallback: "A few times this week")
    /// 50 cards mastered
    public static let fiftyCardsMastered = Loc.tr("LearningAnalyticsService", "fiftyCardsMastered", fallback: "50 cards mastered")
    /// First 10 cards mastered
    public static let first10CardsMastered = Loc.tr("LearningAnalyticsService", "first10CardsMastered", fallback: "First 10 cards mastered")
    /// Focus on accuracy
    public static let focusOnAccuracy = Loc.tr("LearningAnalyticsService", "focusOnAccuracy", fallback: "Focus on accuracy")
    /// Good foundation
    public static let goodFoundation = Loc.tr("LearningAnalyticsService", "goodFoundation", fallback: "Good foundation")
    /// Great progress! You're building a strong foundation.
    public static let greatProgressBuildingFoundation = Loc.tr("LearningAnalyticsService", "greatProgressBuildingFoundation", fallback: "Great progress! You're building a strong foundation.")
    /// Hard
    public static let hard = Loc.tr("LearningAnalyticsService", "hard", fallback: "Hard")
    /// Improve accuracy
    public static let improveAccuracy = Loc.tr("LearningAnalyticsService", "improveAccuracy", fallback: "Improve accuracy")
    /// Improving accuracy
    public static let improvingAccuracy = Loc.tr("LearningAnalyticsService", "improvingAccuracy", fallback: "Improving accuracy")
    /// In progress
    public static let inProgress = Loc.tr("LearningAnalyticsService", "inProgress", fallback: "In progress")
    /// You've mastered most of your current cards. Ready for new challenges!
    public static let masteredMostCurrentCards = Loc.tr("LearningAnalyticsService", "masteredMostCurrentCards", fallback: "You've mastered most of your current cards. Ready for new challenges!")
    /// You've mastered %d%% of your vocabulary. Keep going!
    public static func masteredVocabularyKeepGoing(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "masteredVocabularyKeepGoing", p1, fallback: "You've mastered %d%% of your vocabulary. Keep going!")
    }
    /// You've mastered %d%% of your vocabulary!
    public static func masteredVocabularyPercentage(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "masteredVocabularyPercentage", p1, fallback: "You've mastered %d%% of your vocabulary!")
    }
    /// Medium
    public static let medium = Loc.tr("LearningAnalyticsService", "medium", fallback: "Medium")
    /// Morning (6-12 AM)
    public static let morning = Loc.tr("LearningAnalyticsService", "morning", fallback: "Morning (6-12 AM)")
    /// Most days this week
    public static let mostDaysThisWeek = Loc.tr("LearningAnalyticsService", "mostDaysThisWeek", fallback: "Most days this week")
    /// Night (9 PM-6 AM)
    public static let night = Loc.tr("LearningAnalyticsService", "night", fallback: "Night (9 PM-6 AM)")
    /// learning_analytics_service.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: learning_analytics_service
    public static let notEnoughData = Loc.tr("LearningAnalyticsService", "notEnoughData", fallback: "Not enough data")
    /// Once this week
    public static let onceThisWeek = Loc.tr("LearningAnalyticsService", "onceThisWeek", fallback: "Once this week")
    /// Optimal session length
    public static let optimalSessionLength = Loc.tr("LearningAnalyticsService", "optimalSessionLength", fallback: "Optimal session length")
    /// Over 60 minutes
    public static let over60Minutes = Loc.tr("LearningAnalyticsService", "over60Minutes", fallback: "Over 60 minutes")
    /// Reached %d cards mastered
    public static func reachedCardsMastered(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "reachedCardsMastered", p1, fallback: "Reached %d cards mastered")
    }
    /// Recent
    public static let recent = Loc.tr("LearningAnalyticsService", "recent", fallback: "Recent")
    /// Your recent accuracy has decreased. Consider reviewing difficult cards.
    public static let recentAccuracyDecreased = Loc.tr("LearningAnalyticsService", "recentAccuracyDecreased", fallback: "Your recent accuracy has decreased. Consider reviewing difficult cards.")
    /// Your recent accuracy is %d%% higher than before.
    public static func recentAccuracyHigherThanBefore(_ p1: Int) -> String {
      return Loc.tr("LearningAnalyticsService", "recentAccuracyHigherThanBefore", p1, fallback: "Your recent accuracy is %d%% higher than before.")
    }
    /// Review difficult cards
    public static let reviewDifficultCards = Loc.tr("LearningAnalyticsService", "reviewDifficultCards", fallback: "Review difficult cards")
    /// Reviewed %d cards in %@
    public static func reviewedCardsInTime(_ p1: Int, _ p2: Any) -> String {
      return Loc.tr("LearningAnalyticsService", "reviewedCardsInTime", p1, String(describing: p2), fallback: "Reviewed %d cards in %@")
    }
    /// 7-day study streak
    public static let sevenDayStudyStreak = Loc.tr("LearningAnalyticsService", "sevenDayStudyStreak", fallback: "7-day study streak")
    /// Your study sessions during this time show better focus and retention.
    public static let studySessionsDuringThisTime = Loc.tr("LearningAnalyticsService", "studySessionsDuringThisTime", fallback: "Your study sessions during this time show better focus and retention.")
    /// 10-20 minutes
    public static let tenTo20Minutes = Loc.tr("LearningAnalyticsService", "tenTo20Minutes", fallback: "10-20 minutes")
    /// 30-day study streak
    public static let thirtyDayStudyStreak = Loc.tr("LearningAnalyticsService", "thirtyDayStudyStreak", fallback: "30-day study streak")
    /// 30-60 minutes
    public static let thirtyTo60Minutes = Loc.tr("LearningAnalyticsService", "thirtyTo60Minutes", fallback: "30-60 minutes")
    /// Try to study daily to build a strong learning habit.
    public static let tryToStudyDaily = Loc.tr("LearningAnalyticsService", "tryToStudyDaily", fallback: "Try to study daily to build a strong learning habit.")
    /// 20-30 minutes
    public static let twentyTo30Minutes = Loc.tr("LearningAnalyticsService", "twentyTo30Minutes", fallback: "20-30 minutes")
    /// Under 10 minutes
    public static let under10Minutes = Loc.tr("LearningAnalyticsService", "under10Minutes", fallback: "Under 10 minutes")
    /// Unknown
    public static let unknown = Loc.tr("LearningAnalyticsService", "unknown", fallback: "Unknown")
    /// Very Easy
    public static let veryEasy = Loc.tr("LearningAnalyticsService", "veryEasy", fallback: "Very Easy")
    /// Very Hard
    public static let veryHard = Loc.tr("LearningAnalyticsService", "veryHard", fallback: "Very Hard")
    /// You're most productive in the %@
    public static func youreMostProductiveIn(_ p1: Any) -> String {
      return Loc.tr("LearningAnalyticsService", "youreMostProductiveIn", String(describing: p1), fallback: "You're most productive in the %@")
    }
    /// Your %@ sessions show the best results.
    public static func yourSessionsShowBestResults(_ p1: Any) -> String {
      return Loc.tr("LearningAnalyticsService", "yourSessionsShowBestResults", String(describing: p1), fallback: "Your %@ sessions show the best results.")
    }
    /// Your %@ study routine is working well.
    public static func yourStudyRoutineWorkingWell(_ p1: Any) -> String {
      return Loc.tr("LearningAnalyticsService", "yourStudyRoutineWorkingWell", String(describing: p1), fallback: "Your %@ study routine is working well.")
    }
  }
  public enum Navigation {
    /// Analytics
    public static let analytics = Loc.tr("Navigation", "analytics", fallback: "Analytics")
    /// List
    public static let list = Loc.tr("Navigation", "list", fallback: "List")
    /// Practice
    public static let practice = Loc.tr("Navigation", "practice", fallback: "Practice")
    /// Settings
    public static let settings = Loc.tr("Navigation", "settings", fallback: "Settings")
    /// navigation.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: navigation
    public static let stack = Loc.tr("Navigation", "stack", fallback: "Stack")
    /// Study
    public static let study = Loc.tr("Navigation", "study", fallback: "Study")
  }
  public enum NavigationTitles {
    /// navigation_titles.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: navigation_titles
    public static let addCard = Loc.tr("NavigationTitles", "addCard", fallback: "Add Card")
    /// Add New Card
    public static let addNewCard = Loc.tr("NavigationTitles", "addNewCard", fallback: "Add New Card")
    /// Background Demo
    public static let backgroundDemo = Loc.tr("NavigationTitles", "backgroundDemo", fallback: "Background Demo")
    /// Background Styles
    public static let backgroundStyles = Loc.tr("NavigationTitles", "backgroundStyles", fallback: "Background Styles")
    /// My Cards
    public static let myCards = Loc.tr("NavigationTitles", "myCards", fallback: "My Cards")
    /// Settings
    public static let settings = Loc.tr("NavigationTitles", "settings", fallback: "Settings")
  }
  public enum Notifications {
    /// You have some challenging cards that need attention. Time to review them!
    public static let difficultCardReminderBody = Loc.tr("Notifications", "difficultCardReminderBody", fallback: "You have some challenging cards that need attention. Time to review them!")
    /// Difficult Card Reminders
    public static let difficultCardReminders = Loc.tr("Notifications", "difficultCardReminders", fallback: "Difficult Card Reminders")
    /// Get reminded about difficult cards at 4:30 PM daily
    public static let difficultCardRemindersDescription = Loc.tr("Notifications", "difficultCardRemindersDescription", fallback: "Get reminded about difficult cards at 4:30 PM daily")
    /// Practice Difficult Cards
    public static let difficultCardReminderTitle = Loc.tr("Notifications", "difficultCardReminderTitle", fallback: "Practice Difficult Cards")
    /// notifications.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: notifications
    public static let notifications = Loc.tr("Notifications", "notifications", fallback: "Notifications")
    /// Keep your learning streak going. Open Flippin to practice your flashcards.
    public static let studyReminderBody = Loc.tr("Notifications", "studyReminderBody", fallback: "Keep your learning streak going. Open Flippin to practice your flashcards.")
    /// Study Reminders
    public static let studyReminders = Loc.tr("Notifications", "studyReminders", fallback: "Study Reminders")
    /// Get reminded to study at 8:30 PM the following day
    public static let studyRemindersDescription = Loc.tr("Notifications", "studyRemindersDescription", fallback: "Get reminded to study at 8:30 PM the following day")
    /// Time to Study!
    public static let studyReminderTitle = Loc.tr("Notifications", "studyReminderTitle", fallback: "Time to Study!")
  }
  public enum Paywall {
    /// and
    public static let andPreposition = Loc.tr("Paywall", "andPreposition", fallback: "and")
    /// Annual
    public static let annual = Loc.tr("Paywall", "annual", fallback: "Annual")
    /// BEST VALUE
    public static let bestValue = Loc.tr("Paywall", "bestValue", fallback: "BEST VALUE")
    /// Cancel
    public static let cancel = Loc.tr("Paywall", "cancel", fallback: "Cancel")
    /// daily
    public static let daily = Loc.tr("Paywall", "daily", fallback: "daily")
    /// Go Premium
    public static let goPremium = Loc.tr("Paywall", "goPremium", fallback: "Go Premium")
    /// Master your language learning with exclusive features
    public static let masterLanguageLearning = Loc.tr("Paywall", "masterLanguageLearning", fallback: "Master your language learning with exclusive features")
    /// Monthly
    public static let monthly = Loc.tr("Paywall", "monthly", fallback: "Monthly")
    /// monthly
    public static let monthlyPeriod = Loc.tr("Paywall", "monthlyPeriod", fallback: "monthly")
    /// OK
    public static let ok = Loc.tr("Paywall", "ok", fallback: "OK")
    /// /month
    public static let perMonth = Loc.tr("Paywall", "perMonth", fallback: "/month")
    /// Plan auto-renews for %@/%@ until cancelled.
    public static func planAutoRenews(_ p1: Any, _ p2: Any) -> String {
      return Loc.tr("Paywall", "planAutoRenews", String(describing: p1), String(describing: p2), fallback: "Plan auto-renews for %@/%@ until cancelled.")
    }
    /// Privacy Policy
    public static let privacyPolicy = Loc.tr("Paywall", "privacyPolicy", fallback: "Privacy Policy")
    /// No subscription found to restore.
    public static let restoreFailureMessage = Loc.tr("Paywall", "restoreFailureMessage", fallback: "No subscription found to restore.")
    /// Restore Subscription
    public static let restoreSubscription = Loc.tr("Paywall", "restoreSubscription", fallback: "Restore Subscription")
    /// Your subscription have been restored successfully!
    public static let restoreSuccessMessage = Loc.tr("Paywall", "restoreSuccessMessage", fallback: "Your subscription have been restored successfully!")
    /// Skip
    public static let skip = Loc.tr("Paywall", "skip", fallback: "Skip")
    /// Subscribe
    public static let subscribe = Loc.tr("Paywall", "subscribe", fallback: "Subscribe")
    /// Terms of Service
    public static let termsOfService = Loc.tr("Paywall", "termsOfService", fallback: "Terms of Service")
    /// Unlock all features with full access to premium content
    public static let trialSubtitle = Loc.tr("Paywall", "trialSubtitle", fallback: "Unlock all features with full access to premium content")
    /// Try Premium Free for 7 Days
    public static let trialTitle = Loc.tr("Paywall", "trialTitle", fallback: "Try Premium Free for 7 Days")
    /// Unlock Premium
    public static let unlockPremium = Loc.tr("Paywall", "unlockPremium", fallback: "Unlock Premium")
    /// Upgrade to premium to unlock all features!
    public static let upgradeToPremiumMessage = Loc.tr("Paywall", "upgradeToPremiumMessage", fallback: "Upgrade to premium to unlock all features!")
    /// paywall.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: paywall
    public static let upgradeToPremiumTitle = Loc.tr("Paywall", "upgradeToPremiumTitle", fallback: "Upgrade to Premium")
    /// View Options
    public static let viewOptions = Loc.tr("Paywall", "viewOptions", fallback: "View Options")
    /// weekly
    public static let weekly = Loc.tr("Paywall", "weekly", fallback: "weekly")
    /// What You Get with Premium
    public static let whatYouGetWithPremium = Loc.tr("Paywall", "whatYouGetWithPremium", fallback: "What You Get with Premium")
    /// yearly
    public static let yearly = Loc.tr("Paywall", "yearly", fallback: "yearly")
  }
  public enum Plurals {
    /// Plural format key: "%#@cards@"
    public static func cardsCount(_ p1: Int) -> String {
      return Loc.tr("Plurals", "cardsCount", p1, fallback: "Plural format key: \"%#@cards@\"")
    }
    /// Plural format key: "%#@characters@/500 characters"
    public static func characterLimit(_ p1: Int) -> String {
      return Loc.tr("Plurals", "characterLimit", p1, fallback: "Plural format key: \"%#@characters@/500 characters\"")
    }
    /// Plural format key: "Generated Cards (%#@cards@)"
    public static func generatedCardsCount(_ p1: Int) -> String {
      return Loc.tr("Plurals", "generatedCardsCount", p1, fallback: "Plural format key: \"Generated Cards (%#@cards@)\"")
    }
    /// Plural format key: "%#@sessions@"
    public static func sessionsPerDay(_ p1: Int) -> String {
      return Loc.tr("Plurals", "sessionsPerDay", p1, fallback: "Plural format key: \"%#@sessions@\"")
    }
    /// Plural format key: "%#@days@"
    public static func subscriptionDays(_ p1: Int) -> String {
      return Loc.tr("Plurals", "subscriptionDays", p1, fallback: "Plural format key: \"%#@days@\"")
    }
    /// Plural format key: "%#@months@"
    public static func subscriptionMonths(_ p1: Int) -> String {
      return Loc.tr("Plurals", "subscriptionMonths", p1, fallback: "Plural format key: \"%#@months@\"")
    }
    /// Plural format key: "%#@weeks@"
    public static func subscriptionWeeks(_ p1: Int) -> String {
      return Loc.tr("Plurals", "subscriptionWeeks", p1, fallback: "Plural format key: \"%#@weeks@\"")
    }
    /// Plural format key: "%#@years@"
    public static func subscriptionYears(_ p1: Int) -> String {
      return Loc.tr("Plurals", "subscriptionYears", p1, fallback: "Plural format key: \"%#@years@\"")
    }
    /// Plural format key: "%#@tags@"
    public static func tagsCount(_ p1: Int) -> String {
      return Loc.tr("Plurals", "tagsCount", p1, fallback: "Plural format key: \"%#@tags@\"")
    }
  }
  public enum PremiumFeatures {
    /// Get detailed learning insights, progress charts, and performance analytics with premium!
    public static let advancedAnalyticsMessage = Loc.tr("PremiumFeatures", "advancedAnalyticsMessage", fallback: "Get detailed learning insights, progress charts, and performance analytics with premium!")
    /// Advanced Analytics
    public static let advancedAnalyticsTitle = Loc.tr("PremiumFeatures", "advancedAnalyticsTitle", fallback: "Advanced Analytics")
    /// AI Collection Generator
    public static let aiCollectionGenerator = Loc.tr("PremiumFeatures", "aiCollectionGenerator", fallback: "AI Collection Generator")
    /// Create custom flashcard collections with AI
    public static let aiCollectionGeneratorDescription = Loc.tr("PremiumFeatures", "aiCollectionGeneratorDescription", fallback: "Create custom flashcard collections with AI")
    /// AI Learning Coach
    public static let aiLearningCoach = Loc.tr("PremiumFeatures", "aiLearningCoach", fallback: "AI Learning Coach")
    /// Get personalized insights and recommendations
    public static let aiLearningCoachDescription = Loc.tr("PremiumFeatures", "aiLearningCoachDescription", fallback: "Get personalized insights and recommendations")
    /// Get AI-powered insights about your learning progress
    public static let aiPremiumDescription = Loc.tr("PremiumFeatures", "aiPremiumDescription", fallback: "Get AI-powered insights about your learning progress")
    /// AI features are available with Premium subscription
    public static let aiPremiumRequired = Loc.tr("PremiumFeatures", "aiPremiumRequired", fallback: "AI features are available with Premium subscription")
    /// AI features available with Premium subscription
    public static let aiUnlimitedAccess = Loc.tr("PremiumFeatures", "aiUnlimitedAccess", fallback: "AI features available with Premium subscription")
    /// Card Images
    public static let cardImages = Loc.tr("PremiumFeatures", "cardImages", fallback: "Card Images")
    /// Add beautiful images to your flashcards for better memory retention
    public static let cardImagesDescription = Loc.tr("PremiumFeatures", "cardImagesDescription", fallback: "Add beautiful images to your flashcards for better memory retention")
    /// Enhance your learning with visual flashcards that help you remember better
    public static let cardImagesPremiumDescription = Loc.tr("PremiumFeatures", "cardImagesPremiumDescription", fallback: "Enhance your learning with visual flashcards that help you remember better")
    /// Don't miss out on visual learning, upgrade to Premium
    public static let cardImagesPremiumGate = Loc.tr("PremiumFeatures", "cardImagesPremiumGate", fallback: "Don't miss out on visual learning, upgrade to Premium")
    /// Explore a vast collection of pre-designed card presets with premium!
    public static let cardPresetsMessage = Loc.tr("PremiumFeatures", "cardPresetsMessage", fallback: "Explore a vast collection of pre-designed card presets with premium!")
    /// Card Presets
    public static let cardPresetsTitle = Loc.tr("PremiumFeatures", "cardPresetsTitle", fallback: "Card Presets")
    /// Change Languages
    public static let changeLanguages = Loc.tr("PremiumFeatures", "changeLanguages", fallback: "Change Languages")
    /// Switch between different language pairs anytime
    public static let changeLanguagesDescription = Loc.tr("PremiumFeatures", "changeLanguagesDescription", fallback: "Switch between different language pairs anytime")
    /// 30+ Collections
    public static let collections = Loc.tr("PremiumFeatures", "collections", fallback: "30+ Collections")
    /// Access all preset vocabulary collections
    public static let collectionsDescription = Loc.tr("PremiumFeatures", "collectionsDescription", fallback: "Access all preset vocabulary collections")
    /// Color Scheme
    public static let colorScheme = Loc.tr("PremiumFeatures", "colorScheme", fallback: "Color Scheme")
    /// Dark
    public static let colorSchemeDark = Loc.tr("PremiumFeatures", "colorSchemeDark", fallback: "Dark")
    /// Light
    public static let colorSchemeLight = Loc.tr("PremiumFeatures", "colorSchemeLight", fallback: "Light")
    /// System
    public static let colorSchemeSystem = Loc.tr("PremiumFeatures", "colorSchemeSystem", fallback: "System")
    /// Unlock beautiful custom themes and backgrounds with premium!
    public static let customThemesMessage = Loc.tr("PremiumFeatures", "customThemesMessage", fallback: "Unlock beautiful custom themes and backgrounds with premium!")
    /// Custom Themes
    public static let customThemesTitle = Loc.tr("PremiumFeatures", "customThemesTitle", fallback: "Custom Themes")
    /// Choose from over 15 languages to enhance your learning experience with premium!
    public static let languageChangeMessage = Loc.tr("PremiumFeatures", "languageChangeMessage", fallback: "Choose from over 15 languages to enhance your learning experience with premium!")
    /// Language Change
    public static let languageChangeTitle = Loc.tr("PremiumFeatures", "languageChangeTitle", fallback: "Language Change")
    /// Ability to learn multiple languages at the same time
    public static let multipleLanguagesDescription = Loc.tr("PremiumFeatures", "multipleLanguagesDescription", fallback: "Ability to learn multiple languages at the same time")
    /// Multiple Languages
    public static let multipleLanguagesTitle = Loc.tr("PremiumFeatures", "multipleLanguagesTitle", fallback: "Multiple Languages")
    /// Premium
    public static let premium = Loc.tr("PremiumFeatures", "premium", fallback: "Premium")
    /// Premium Backgrounds
    public static let premiumBackgrounds = Loc.tr("PremiumFeatures", "premiumBackgrounds", fallback: "Premium Backgrounds")
    /// Beautiful animated backgrounds
    public static let premiumBackgroundsDescription = Loc.tr("PremiumFeatures", "premiumBackgroundsDescription", fallback: "Beautiful animated backgrounds")
    /// premium_features.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: premium_features
    public static let premiumFeature = Loc.tr("PremiumFeatures", "premiumFeature", fallback: "Premium Feature")
    /// Access all preset collections and unlock unlimited language learning potential
    public static let premiumFeatureDescription = Loc.tr("PremiumFeatures", "premiumFeatureDescription", fallback: "Access all preset collections and unlock unlimited language learning potential")
    /// Premium Required
    public static let premiumRequired = Loc.tr("PremiumFeatures", "premiumRequired", fallback: "Premium Required")
    /// Speechify Premium Voices
    public static let premiumVoices = Loc.tr("PremiumFeatures", "premiumVoices", fallback: "Speechify Premium Voices")
    /// Thousands of high-quality voices to personalize your cards
    public static let premiumVoicesDescription = Loc.tr("PremiumFeatures", "premiumVoicesDescription", fallback: "Thousands of high-quality voices to personalize your cards")
    /// Enjoy high-quality audio for all your flashcards!
    public static let premiumVoicesMessage = Loc.tr("PremiumFeatures", "premiumVoicesMessage", fallback: "Enjoy high-quality audio for all your flashcards!")
    /// Preview
    public static let previewBackgrounds = Loc.tr("PremiumFeatures", "previewBackgrounds", fallback: "Preview")
    /// Access advanced study modes and learning techniques with premium!
    public static let studyModesMessage = Loc.tr("PremiumFeatures", "studyModesMessage", fallback: "Access advanced study modes and learning techniques with premium!")
    /// Study Modes
    public static let studyModesTitle = Loc.tr("PremiumFeatures", "studyModesTitle", fallback: "Study Modes")
    /// Create as many flashcards as you want
    public static let unlimitedCardsDescription = Loc.tr("PremiumFeatures", "unlimitedCardsDescription", fallback: "Create as many flashcards as you want")
    /// Upgrade to premium to create unlimited cards and unlock all features!
    public static let unlimitedCardsMessage = Loc.tr("PremiumFeatures", "unlimitedCardsMessage", fallback: "Upgrade to premium to create unlimited cards and unlock all features!")
    /// Unlimited Cards
    public static let unlimitedCardsTitle = Loc.tr("PremiumFeatures", "unlimitedCardsTitle", fallback: "Unlimited Cards")
    /// You've used %d of %d free cards
    public static func usedCardsOfLimit(_ p1: Int, _ p2: Int) -> String {
      return Loc.tr("PremiumFeatures", "usedCardsOfLimit", p1, p2, fallback: "You've used %d of %d free cards")
    }
  }
  public enum PresetCollections {
    /// All
    public static let allCategories = Loc.tr("PresetCollections", "allCategories", fallback: "All")
    /// Background Style
    public static let backgroundStyle = Loc.tr("PresetCollections", "backgroundStyle", fallback: "Background Style")
    /// Color
    public static let color = Loc.tr("PresetCollections", "color", fallback: "Color")
    /// Get started with curated card sets for common topics and situations
    public static let getStartedWithCollections = Loc.tr("PresetCollections", "getStartedWithCollections", fallback: "Get started with curated card sets for common topics and situations")
    /// Import
    public static let importButton = Loc.tr("PresetCollections", "importButton", fallback: "Import")
    /// Import Collection
    public static let importCollection = Loc.tr("PresetCollections", "importCollection", fallback: "Import Collection")
    /// Import %@ with %d cards to your collection?
    public static func importCollectionMessage(_ p1: Any, _ p2: Int) -> String {
      return Loc.tr("PresetCollections", "importCollectionMessage", String(describing: p1), p2, fallback: "Import %@ with %d cards to your collection?")
    }
    /// My Language
    public static let myLanguageSettings = Loc.tr("PresetCollections", "myLanguageSettings", fallback: "My Language")
    /// No collections found
    public static let noCollectionsFound = Loc.tr("PresetCollections", "noCollectionsFound", fallback: "No collections found")
    /// preset_collections.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: preset_collections
    public static let presetCollections = Loc.tr("PresetCollections", "presetCollections", fallback: "Preset Collections")
    /// Search collections...
    public static let searchCollections = Loc.tr("PresetCollections", "searchCollections", fallback: "Search collections...")
    /// See All
    public static let seeAllCollections = Loc.tr("PresetCollections", "seeAllCollections", fallback: "See All")
    /// Tap to see full screen
    public static let tapToSeeFullScreen = Loc.tr("PresetCollections", "tapToSeeFullScreen", fallback: "Tap to see full screen")
    /// Target Language
    public static let targetLanguage = Loc.tr("PresetCollections", "targetLanguage", fallback: "Target Language")
    /// Theme
    public static let theme = Loc.tr("PresetCollections", "theme", fallback: "Theme")
    /// Try adjusting your search or filter criteria
    public static let tryAdjustingSearch = Loc.tr("PresetCollections", "tryAdjustingSearch", fallback: "Try adjusting your search or filter criteria")
  }
  public enum Search {
    /// Search
    public static let search = Loc.tr("Search", "search", fallback: "Search")
    /// search.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: search
    public static let searchCards = Loc.tr("Search", "searchCards", fallback: "Search cards...")
  }
  public enum Settings {
    /// Card Display
    public static let cardDisplay = Loc.tr("Settings", "cardDisplay", fallback: "Card Display")
    /// Card Display Mode
    public static let cardDisplayMode = Loc.tr("Settings", "cardDisplayMode", fallback: "Card Display Mode")
    /// Card Management
    public static let cardManagement = Loc.tr("Settings", "cardManagement", fallback: "Card Management")
    /// Search, edit, and organize your flashcards
    public static let cardManagementDescription = Loc.tr("Settings", "cardManagementDescription", fallback: "Search, edit, and organize your flashcards")
    /// settings.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: settings
    public static let languages = Loc.tr("Settings", "languages", fallback: "Languages")
    /// Learning Mode
    public static let learningMode = Loc.tr("Settings", "learningMode", fallback: "Learning Mode")
    /// Show target language first (for learning)
    public static let learningModeDescription = Loc.tr("Settings", "learningModeDescription", fallback: "Show target language first (for learning)")
    /// Manage Cards
    public static let manageCards = Loc.tr("Settings", "manageCards", fallback: "Manage Cards")
    /// Preview Backgrounds
    public static let previewBackgrounds = Loc.tr("Settings", "previewBackgrounds", fallback: "Preview Backgrounds")
    /// Travel Mode
    public static let travelMode = Loc.tr("Settings", "travelMode", fallback: "Travel Mode")
    /// Show native language first (for travel)
    public static let travelModeDescription = Loc.tr("Settings", "travelModeDescription", fallback: "Show native language first (for travel)")
  }
  public enum Study {
    /// Accuracy
    public static let accuracy = Loc.tr("Study", "accuracy", fallback: "Accuracy")
    /// Average Session
    public static let averageSession = Loc.tr("Study", "averageSession", fallback: "Average Session")
    /// Cards Practiced
    public static let cardsPracticed = Loc.tr("Study", "cardsPracticed", fallback: "Cards Practiced")
    /// Cards Studied
    public static let cardsStudied = Loc.tr("Study", "cardsStudied", fallback: "Cards Studied")
    /// Choose the correct word:
    public static let chooseCorrectWord = Loc.tr("Study", "chooseCorrectWord", fallback: "Choose the correct word:")
    /// Complete the sentence
    public static let completeSentence = Loc.tr("Study", "completeSentence", fallback: "Complete the sentence")
    /// Correct
    public static let correct = Loc.tr("Study", "correct", fallback: "Correct")
    /// Correct Answer
    public static let correctAnswer = Loc.tr("Study", "correctAnswer", fallback: "Correct Answer")
    /// Difficult Cards
    public static let difficultCards = Loc.tr("Study", "difficultCards", fallback: "Difficult Cards")
    /// Done
    public static let done = Loc.tr("Study", "done", fallback: "Done")
    /// Exit
    public static let exit = Loc.tr("Study", "exit", fallback: "Exit")
    /// Fill in the missing word
    public static let fillInMissingWord = Loc.tr("Study", "fillInMissingWord", fallback: "Fill in the missing word")
    /// Fill in the Blank (%d)
    public static func fillInTheBlank(_ p1: Int) -> String {
      return Loc.tr("Study", "fillInTheBlank", p1, fallback: "Fill in the Blank (%d)")
    }
    /// Incorrect
    public static let incorrect = Loc.tr("Study", "incorrect", fallback: "Incorrect")
    /// Learning Progress
    public static let learningProgress = Loc.tr("Study", "learningProgress", fallback: "Learning Progress")
    /// Mastered
    public static let mastered = Loc.tr("Study", "mastered", fallback: "Mastered")
    /// Multiple Choice Quiz
    public static let multipleChoiceQuiz = Loc.tr("Study", "multipleChoiceQuiz", fallback: "Multiple Choice Quiz")
    /// No Practice Data
    public static let noPracticeData = Loc.tr("Study", "noPracticeData", fallback: "No Practice Data")
    /// No Study Data
    public static let noStudyData = Loc.tr("Study", "noStudyData", fallback: "No Study Data")
    /// Practice
    public static let practice = Loc.tr("Study", "practice", fallback: "Practice")
    /// Practice Again
    public static let practiceAgain = Loc.tr("Study", "practiceAgain", fallback: "Practice Again")
    /// Practice All Cards (%d)
    public static func practiceAllCards(_ p1: Int) -> String {
      return Loc.tr("Study", "practiceAllCards", p1, fallback: "Practice All Cards (%d)")
    }
    /// Practice Difficult Cards (%d)
    public static func practiceDifficultCards(_ p1: Int) -> String {
      return Loc.tr("Study", "practiceDifficultCards", p1, fallback: "Practice Difficult Cards (%d)")
    }
    /// Practice Mode
    public static let practiceMode = Loc.tr("Study", "practiceMode", fallback: "Practice Mode")
    /// Practice Options
    public static let practiceOptions = Loc.tr("Study", "practiceOptions", fallback: "Practice Options")
    /// %d of %d
    public static func practiceProgress(_ p1: Int, _ p2: Int) -> String {
      return Loc.tr("Study", "practiceProgress", p1, p2, fallback: "%d of %d")
    }
    /// Practice Session Complete!
    public static let practiceSessionComplete = Loc.tr("Study", "practiceSessionComplete", fallback: "Practice Session Complete!")
    /// Practice Time Today
    public static let practiceTimeToday = Loc.tr("Study", "practiceTimeToday", fallback: "Practice Time Today")
    /// Quick Stats
    public static let quickStats = Loc.tr("Study", "quickStats", fallback: "Quick Stats")
    /// Recent Activity
    public static let recentActivity = Loc.tr("Study", "recentActivity", fallback: "Recent Activity")
    /// Select the correct translation
    public static let selectCorrectTranslation = Loc.tr("Study", "selectCorrectTranslation", fallback: "Select the correct translation")
    /// Show Answer
    public static let showAnswer = Loc.tr("Study", "showAnswer", fallback: "Show Answer")
    /// Start Practice Session (10 cards)
    public static let startPracticeSession = Loc.tr("Study", "startPracticeSession", fallback: "Start Practice Session (10 cards)")
    /// Start practicing to see your progress!
    public static let startPracticingToSeeProgress = Loc.tr("Study", "startPracticingToSeeProgress", fallback: "Start practicing to see your progress!")
    /// Start studying to see your progress!
    public static let startStudyingToSeeProgress = Loc.tr("Study", "startStudyingToSeeProgress", fallback: "Start studying to see your progress!")
    /// Start Study Session (10 cards)
    public static let startStudySession = Loc.tr("Study", "startStudySession", fallback: "Start Study Session (10 cards)")
    /// study.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: study
    public static let study = Loc.tr("Study", "study", fallback: "Study")
    /// Study Again
    public static let studyAgain = Loc.tr("Study", "studyAgain", fallback: "Study Again")
    /// Study Mode
    public static let studyMode = Loc.tr("Study", "studyMode", fallback: "Study Mode")
    /// Study Options
    public static let studyOptions = Loc.tr("Study", "studyOptions", fallback: "Study Options")
    /// %d of %d
    public static func studyProgress(_ p1: Int, _ p2: Int) -> String {
      return Loc.tr("Study", "studyProgress", p1, p2, fallback: "%d of %d")
    }
    /// Study Session Complete!
    public static let studySessionComplete = Loc.tr("Study", "studySessionComplete", fallback: "Study Session Complete!")
    /// Study Time Today
    public static let studyTimeToday = Loc.tr("Study", "studyTimeToday", fallback: "Study Time Today")
    /// Time Spent
    public static let timeSpent = Loc.tr("Study", "timeSpent", fallback: "Time Spent")
    /// To cards
    public static let toCards = Loc.tr("Study", "toCards", fallback: "To cards")
    /// Total Cards
    public static let totalCards = Loc.tr("Study", "totalCards", fallback: "Total Cards")
    /// Total Practice Time
    public static let totalPracticeTime = Loc.tr("Study", "totalPracticeTime", fallback: "Total Practice Time")
    /// Total Study Time
    public static let totalStudyTime = Loc.tr("Study", "totalStudyTime", fallback: "Total Study Time")
    /// Translate to %@
    public static func translateTo(_ p1: Any) -> String {
      return Loc.tr("Study", "translateTo", String(describing: p1), fallback: "Translate to %@")
    }
    /// Unlock All Practice Modes
    public static let unlockAllPracticeModes = Loc.tr("Study", "unlockAllPracticeModes", fallback: "Unlock All Practice Modes")
    /// Unlock All Study Modes
    public static let unlockAllStudyModes = Loc.tr("Study", "unlockAllStudyModes", fallback: "Unlock All Study Modes")
  }
  public enum SubscriptionManagement {
    /// Accuracy
    public static let accuracy = Loc.tr("SubscriptionManagement", "accuracy", fallback: "Accuracy")
    /// Active Subscription
    public static let activeSubscription = Loc.tr("SubscriptionManagement", "activeSubscription", fallback: "Active Subscription")
    /// Cancel
    public static let cancel = Loc.tr("SubscriptionManagement", "cancel", fallback: "Cancel")
    /// Date
    public static let date = Loc.tr("SubscriptionManagement", "date", fallback: "Date")
    /// Delete
    public static let delete = Loc.tr("SubscriptionManagement", "delete", fallback: "Delete")
    /// Done
    public static let done = Loc.tr("SubscriptionManagement", "done", fallback: "Done")
    /// Edit
    public static let edit = Loc.tr("SubscriptionManagement", "edit", fallback: "Edit")
    /// Manage Subscription
    public static let manageSubscription = Loc.tr("SubscriptionManagement", "manageSubscription", fallback: "Manage Subscription")
    /// Mastered Cards
    public static let masteredCards = Loc.tr("SubscriptionManagement", "masteredCards", fallback: "Mastered Cards")
    /// No accuracy data available
    public static let noAccuracyDataAvailable = Loc.tr("SubscriptionManagement", "noAccuracyDataAvailable", fallback: "No accuracy data available")
    /// No cards available
    public static let noCardsAvailable = Loc.tr("SubscriptionManagement", "noCardsAvailable", fallback: "No cards available")
    /// No growth data available
    public static let noGrowthDataAvailable = Loc.tr("SubscriptionManagement", "noGrowthDataAvailable", fallback: "No growth data available")
    /// Save
    public static let save = Loc.tr("SubscriptionManagement", "save", fallback: "Save")
    /// Search cards...
    public static let searchCards = Loc.tr("SubscriptionManagement", "searchCards", fallback: "Search cards...")
    /// subscription_management.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: subscription_management
    public static let subscription = Loc.tr("SubscriptionManagement", "subscription", fallback: "Subscription")
    /// Subscription Status
    public static let subscriptionStatus = Loc.tr("SubscriptionManagement", "subscriptionStatus", fallback: "Subscription Status")
  }
  public enum TagManagement {
    /// Add
    public static let add = Loc.tr("TagManagement", "add", fallback: "Add")
    /// Add Tag
    public static let addTag = Loc.tr("TagManagement", "addTag", fallback: "Add Tag")
    /// tag_management.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: tag_management
    public static let availableTags = Loc.tr("TagManagement", "availableTags", fallback: "Available Tags")
    /// Filter by Favorites
    public static let filterByFavorites = Loc.tr("TagManagement", "filterByFavorites", fallback: "Filter by Favorites")
    /// Filter by Language
    public static let filterByLanguage = Loc.tr("TagManagement", "filterByLanguage", fallback: "Filter by Language")
    /// Show only cards that match your selected languages
    public static let filterByLanguageDescription = Loc.tr("TagManagement", "filterByLanguageDescription", fallback: "Show only cards that match your selected languages")
    /// Filter by Tag
    public static let filterByTag = Loc.tr("TagManagement", "filterByTag", fallback: "Filter by Tag")
    /// Manage tags in the settings.
    public static let manageTagsInSettings = Loc.tr("TagManagement", "manageTagsInSettings", fallback: "Manage tags in the settings.")
    /// New tag name
    public static let newTagName = Loc.tr("TagManagement", "newTagName", fallback: "New tag name")
    /// No Favorite Cards
    public static let noFavoriteCards = Loc.tr("TagManagement", "noFavoriteCards", fallback: "No Favorite Cards")
    /// You haven't marked any cards as favorites yet
    public static let noFavoriteCardsDescription = Loc.tr("TagManagement", "noFavoriteCardsDescription", fallback: "You haven't marked any cards as favorites yet")
    /// No tags available
    public static let noTagsAvailable = Loc.tr("TagManagement", "noTagsAvailable", fallback: "No tags available")
    /// Show All Cards
    public static let showAllCards = Loc.tr("TagManagement", "showAllCards", fallback: "Show All Cards")
    /// Show Favorites Only
    public static let showFavoritesOnly = Loc.tr("TagManagement", "showFavoritesOnly", fallback: "Show Favorites Only")
    /// Tags Management
    public static let tagsManagement = Loc.tr("TagManagement", "tagsManagement", fallback: "Tags Management")
    /// To settings
    public static let toSettings = Loc.tr("TagManagement", "toSettings", fallback: "To settings")
  }
  public enum Tts {
    /// Advertisement
    public static let advertisement = Loc.tr("TTS", "advertisement", fallback: "Advertisement")
    /// American Neutral
    public static let americanNeutral = Loc.tr("TTS", "american-neutral", fallback: "American Neutral")
    /// Angry
    public static let angry = Loc.tr("TTS", "angry", fallback: "Angry")
    /// Animation
    public static let animation = Loc.tr("TTS", "animation", fallback: "Animation")
    /// Assertive or Confident
    public static let assertiveOrConfident = Loc.tr("TTS", "assertive-or-confident", fallback: "Assertive or Confident")
    /// Audio Settings
    public static let audioSettings = Loc.tr("TTS", "audio_settings", fallback: "Audio Settings")
    /// Audiobook
    public static let audiobook = Loc.tr("TTS", "audiobook", fallback: "Audiobook")
    /// Audiobook & Narration
    public static let audiobookAndNarration = Loc.tr("TTS", "audiobook-and-narration", fallback: "Audiobook & Narration")
    /// Audiobooks & Narration
    public static let audiobooksAndNarration = Loc.tr("TTS", "audiobooks-and-narration", fallback: "Audiobooks & Narration")
    /// Australian
    public static let australian = Loc.tr("TTS", "australian", fallback: "Australian")
    /// Bright
    public static let bright = Loc.tr("TTS", "bright", fallback: "Bright")
    /// British
    public static let british = Loc.tr("TTS", "british", fallback: "British")
    /// Calm or Relaxed
    public static let calmOrRelaxed = Loc.tr("TTS", "calm-or-relaxed", fallback: "Calm or Relaxed")
    /// Change Voice
    public static let changeVoice = Loc.tr("TTS", "change_voice", fallback: "Change Voice")
    /// characters
    public static let characters = Loc.tr("TTS", "characters", fallback: "characters")
    /// Cheerful
    public static let cheerful = Loc.tr("TTS", "cheerful", fallback: "Cheerful")
    /// Conversational
    public static let conversational = Loc.tr("TTS", "conversational", fallback: "Conversational")
    /// Crisp
    public static let crisp = Loc.tr("TTS", "crisp", fallback: "Crisp")
    /// Current Voice
    public static let currentVoice = Loc.tr("TTS", "current_voice", fallback: "Current Voice")
    /// Customize your text-to-speech experience
    public static let customizeTtsExperience = Loc.tr("TTS", "customize_tts_experience", fallback: "Customize your text-to-speech experience")
    /// TTS Dashboard
    public static let dashboard = Loc.tr("TTS", "dashboard", fallback: "TTS Dashboard")
    /// Deep
    public static let deep = Loc.tr("TTS", "deep", fallback: "Deep")
    /// Default Voice
    public static let defaultVoice = Loc.tr("TTS", "default_voice", fallback: "Default Voice")
    /// Direct
    public static let direct = Loc.tr("TTS", "direct", fallback: "Direct")
    /// E-Learning
    public static let eLearning = Loc.tr("TTS", "e-learning", fallback: "E-Learning")
    /// Energetic
    public static let energetic = Loc.tr("TTS", "energetic", fallback: "Energetic")
    /// Enter text to test...
    public static let enterTextToTest = Loc.tr("TTS", "enter_text_to_test", fallback: "Enter text to test...")
    /// Fearful
    public static let fearful = Loc.tr("TTS", "fearful", fallback: "Fearful")
    /// Female
    public static let female = Loc.tr("TTS", "female", fallback: "Female")
    /// Free Google TTS with basic voices and reliable performance
    public static let freeGoogleTtsDescription = Loc.tr("TTS", "free_google_tts_description", fallback: "Free Google TTS with basic voices and reliable performance")
    /// Gaming
    public static let gaming = Loc.tr("TTS", "gaming", fallback: "Gaming")
    /// High Pitch
    public static let highPitch = Loc.tr("TTS", "high-pitch", fallback: "High Pitch")
    /// Indian
    public static let indian = Loc.tr("TTS", "indian", fallback: "Indian")
    /// Male
    public static let male = Loc.tr("TTS", "male", fallback: "Male")
    /// Meditation
    public static let meditation = Loc.tr("TTS", "meditation", fallback: "Meditation")
    /// Middle-aged
    public static let middleAged = Loc.tr("TTS", "middle-aged", fallback: "Middle-aged")
    /// Monthly Limit
    public static let monthlyLimit = Loc.tr("TTS", "monthly_limit", fallback: "Monthly Limit")
    /// Movie
    public static let movie = Loc.tr("TTS", "movie", fallback: "Movie")
    /// Movies, Acting & Gaming
    public static let moviesActingAndGaming = Loc.tr("TTS", "movies-acting-and-gaming", fallback: "Movies, Acting & Gaming")
    /// Narration
    public static let narration = Loc.tr("TTS", "narration", fallback: "Narration")
    /// Neutral
    public static let neutral = Loc.tr("TTS", "neutral", fallback: "Neutral")
    /// Nigerian
    public static let nigerian = Loc.tr("TTS", "nigerian", fallback: "Nigerian")
    /// Playing
    public static let playing = Loc.tr("TTS", "playing", fallback: "Playing")
    /// Podcast
    public static let podcast = Loc.tr("TTS", "podcast", fallback: "Podcast")
    /// Premium TTS Dashboard
    public static let premiumTtsDashboard = Loc.tr("TTS", "premium_tts_dashboard", fallback: "Premium TTS Dashboard")
    /// Preview Current Voice
    public static let previewCurrentVoice = Loc.tr("TTS", "preview_current_voice", fallback: "Preview Current Voice")
    /// PRO
    public static let pro = Loc.tr("TTS", "pro", fallback: "PRO")
    /// Professional
    public static let professional = Loc.tr("TTS", "professional", fallback: "Professional")
    /// Provider
    public static let provider = Loc.tr("TTS", "provider", fallback: "Provider")
    /// Ready
    public static let ready = Loc.tr("TTS", "ready", fallback: "Ready")
    /// Relaxed
    public static let relaxed = Loc.tr("TTS", "relaxed", fallback: "Relaxed")
    /// Remaining
    public static let remaining = Loc.tr("TTS", "remaining", fallback: "Remaining")
    /// Sad
    public static let sad = Loc.tr("TTS", "sad", fallback: "Sad")
    /// Senior
    public static let senior = Loc.tr("TTS", "senior", fallback: "Senior")
    /// Social Media
    public static let socialMedia = Loc.tr("TTS", "social-media", fallback: "Social Media")
    /// Speech Rate
    public static let speechRate = Loc.tr("TTS", "speech_rate", fallback: "Speech Rate")
    /// Speechify Monthly Usage
    public static let speechifyMonthlyUsage = Loc.tr("TTS", "speechify_monthly_usage", fallback: "Speechify Monthly Usage")
    /// Stop
    public static let stop = Loc.tr("TTS", "stop", fallback: "Stop")
    /// Surprised
    public static let suprised = Loc.tr("TTS", "suprised", fallback: "Surprised")
    /// Surprised
    public static let surprised = Loc.tr("TTS", "surprised", fallback: "Surprised")
    /// Teen
    public static let teen = Loc.tr("TTS", "teen", fallback: "Teen")
    /// Terrified
    public static let terrified = Loc.tr("TTS", "terrified", fallback: "Terrified")
    /// Test
    public static let test = Loc.tr("TTS", "test", fallback: "Test")
    /// Test Your Settings
    public static let testYourSettings = Loc.tr("TTS", "test_your_settings", fallback: "Test Your Settings")
    /// TTS Provider
    public static let ttsProvider = Loc.tr("TTS", "tts_provider", fallback: "TTS Provider")
    /// Usage Progress
    public static let usageProgress = Loc.tr("TTS", "usage_progress", fallback: "Usage Progress")
    /// Usage Statistics
    public static let usageStatistics = Loc.tr("TTS", "usage_statistics", fallback: "Usage Statistics")
    /// Used This Month
    public static let usedThisMonth = Loc.tr("TTS", "used_this_month", fallback: "Used This Month")
    /// Voice Customization
    public static let voiceCustomization = Loc.tr("TTS", "voice_customization", fallback: "Voice Customization")
    /// Volume
    public static let volume = Loc.tr("TTS", "volume", fallback: "Volume")
    /// Warm
    public static let warm = Loc.tr("TTS", "warm", fallback: "Warm")
    /// Warm or Friendly
    public static let warmOrFriendly = Loc.tr("TTS", "warm-or-friendly", fallback: "Warm or Friendly")
    /// Young Adult
    public static let youngAdult = Loc.tr("TTS", "young-adult", fallback: "Young Adult")
    public enum Analytics {
      /// Characters Used
      public static let charactersUsed = Loc.tr("TTS", "analytics.characters_used", fallback: "Characters Used")
      /// Favorite Language
      public static let favoriteLanguage = Loc.tr("TTS", "analytics.favorite_language", fallback: "Favorite Language")
      /// Favorite Voice
      public static let favoriteVoice = Loc.tr("TTS", "analytics.favorite_voice", fallback: "Favorite Voice")
      /// Premium Usage
      public static let premiumUsage = Loc.tr("TTS", "analytics.premium_usage", fallback: "Premium Usage")
      /// Sessions
      public static let sessions = Loc.tr("TTS", "analytics.sessions", fallback: "Sessions")
      /// Time Saved
      public static let timeSaved = Loc.tr("TTS", "analytics.time_saved", fallback: "Time Saved")
      /// Total Characters
      public static let totalCharacters = Loc.tr("TTS", "analytics.total_characters", fallback: "Total Characters")
      /// Total Duration
      public static let totalDuration = Loc.tr("TTS", "analytics.total_duration", fallback: "Total Duration")
      /// Total Sessions
      public static let totalSessions = Loc.tr("TTS", "analytics.total_sessions", fallback: "Total Sessions")
    }
    public enum EnglishAccents {
      /// American
      public static let american = Loc.tr("TTS", "english_accents.american", fallback: "American")
      /// Australian
      public static let australian = Loc.tr("TTS", "english_accents.australian", fallback: "Australian")
      /// Belgian
      public static let belgian = Loc.tr("TTS", "english_accents.belgian", fallback: "Belgian")
      /// British
      public static let british = Loc.tr("TTS", "english_accents.british", fallback: "British")
      /// Canadian
      public static let canadian = Loc.tr("TTS", "english_accents.canadian", fallback: "Canadian")
      /// Indian
      public static let indian = Loc.tr("TTS", "english_accents.indian", fallback: "Indian")
      /// Irish
      public static let irish = Loc.tr("TTS", "english_accents.irish", fallback: "Irish")
      /// Singaporean
      public static let singaporean = Loc.tr("TTS", "english_accents.singaporean", fallback: "Singaporean")
      /// South African
      public static let southAfrican = Loc.tr("TTS", "english_accents.south_african", fallback: "South African")
    }
    public enum Filters {
      /// All Accents
      public static let allAccents = Loc.tr("TTS", "filters.all_accents", fallback: "All Accents")
      /// All Ages
      public static let allAges = Loc.tr("TTS", "filters.all_ages", fallback: "All Ages")
      /// All Genders
      public static let allGenders = Loc.tr("TTS", "filters.all_genders", fallback: "All Genders")
      /// All Languages
      public static let allLanguages = Loc.tr("TTS", "filters.all_languages", fallback: "All Languages")
      /// All Timbres
      public static let allTimbres = Loc.tr("TTS", "filters.all_timbres", fallback: "All Timbres")
      /// All Use Cases
      public static let allUseCases = Loc.tr("TTS", "filters.all_use_cases", fallback: "All Use Cases")
      /// Available Voices
      public static let availableVoices = Loc.tr("TTS", "filters.available_voices", fallback: "Available Voices")
      /// Filters
      public static let filters = Loc.tr("TTS", "filters.filters", fallback: "Filters")
      /// No voices available
      public static let noVoicesAvailable = Loc.tr("TTS", "filters.no_voices_available", fallback: "No voices available")
      /// No voices found
      public static let noVoicesFound = Loc.tr("TTS", "filters.no_voices_found", fallback: "No voices found")
      /// Try adjusting your search or filters
      public static let noVoicesFoundMessage = Loc.tr("TTS", "filters.no_voices_found_message", fallback: "Try adjusting your search or filters")
      /// Reset
      public static let reset = Loc.tr("TTS", "filters.reset", fallback: "Reset")
      /// Select Voice
      public static let selectVoice = Loc.tr("TTS", "filters.select_voice", fallback: "Select Voice")
    }
    public enum Models {
      /// English
      public static let english = Loc.tr("TTS", "models.english", fallback: "English")
      /// Speechify's English text-to-speech model offers standard capabilities designed to deliver clear and natural voice output for reading texts. The model focuses on delivering a consistent user experience.
      public static let englishDescription = Loc.tr("TTS", "models.english_description", fallback: "Speechify's English text-to-speech model offers standard capabilities designed to deliver clear and natural voice output for reading texts. The model focuses on delivering a consistent user experience.")
      /// Multilingual
      public static let multilingual = Loc.tr("TTS", "models.multilingual", fallback: "Multilingual")
      /// Multilingual model allows the usage of all supported languages and supports using multiple languages within a single sentence. The audio output of this model is distinctively different from other models.
      public static let multilingualDescription = Loc.tr("TTS", "models.multilingual_description", fallback: "Multilingual model allows the usage of all supported languages and supports using multiple languages within a single sentence. The audio output of this model is distinctively different from other models.")
    }
    public enum Settings {
      /// Dashboard
      public static let dashboard = Loc.tr("TTS", "settings.dashboard", fallback: "Dashboard")
      /// Speechify
      public static let speechify = Loc.tr("TTS", "settings.speechify", fallback: "Speechify")
      /// Speechify's Text-to-Speech AI model is available for all users as a premium feature. It allows you to choose from a wide range of voices and accents, so you can fine-tune your study experience.
      public static let speechifyDescription = Loc.tr("TTS", "settings.speechify_description", fallback: "Speechify's Text-to-Speech AI model is available for all users as a premium feature. It allows you to choose from a wide range of voices and accents, so you can fine-tune your study experience.")
      /// Speechify's Text-to-Speech AI model is included in your subscription.
      public static let speechifyProDescription = Loc.tr("TTS", "settings.speechify_pro_description", fallback: "Speechify's Text-to-Speech AI model is included in your subscription.")
      /// Text-to-Speech
      public static let textToSpeech = Loc.tr("TTS", "settings.text_to_speech", fallback: "Text-to-Speech")
    }
    public enum Usage {
      /// Monthly Limit
      public static let monthlyLimit = Loc.tr("TTS", "usage.monthly_limit", fallback: "Monthly Limit")
      /// Monthly Limit Exceeded
      public static let monthlyLimitExceeded = Loc.tr("TTS", "usage.monthly_limit_exceeded", fallback: "Monthly Limit Exceeded")
      /// You have reached your monthly limit of 50,000 characters for Speechify TTS. Please try again next month or use Google TTS instead.
      public static let monthlyLimitExceededMessage = Loc.tr("TTS", "usage.monthly_limit_exceeded_message", fallback: "You have reached your monthly limit of 50,000 characters for Speechify TTS. Please try again next month or use Google TTS instead.")
      /// Monthly Usage
      public static let monthlyUsage = Loc.tr("TTS", "usage.monthly_usage", fallback: "Monthly Usage")
      /// Remaining Characters
      public static let remainingCharacters = Loc.tr("TTS", "usage.remaining_characters", fallback: "Remaining Characters")
    }
  }
  public enum UserProfile {
    /// 18-24
    public static let age18to24 = Loc.tr("UserProfile", "age18to24", fallback: "18-24")
    /// 25-34
    public static let age25to34 = Loc.tr("UserProfile", "age25to34", fallback: "25-34")
    /// 35-44
    public static let age35to44 = Loc.tr("UserProfile", "age35to44", fallback: "35-44")
    /// 45-54
    public static let age45to54 = Loc.tr("UserProfile", "age45to54", fallback: "45-54")
    /// 55+
    public static let age55plus = Loc.tr("UserProfile", "age55plus", fallback: "55+")
    /// This helps us personalize your learning experience
    public static let ageGroupSubtitle = Loc.tr("UserProfile", "ageGroupSubtitle", fallback: "This helps us personalize your learning experience")
    /// What's Your Age Group?
    public static let ageGroupTitle = Loc.tr("UserProfile", "ageGroupTitle", fallback: "What's Your Age Group?")
    /// Under 18
    public static let ageUnder18 = Loc.tr("UserProfile", "ageUnder18", fallback: "Under 18")
    /// Enable Notifications
    public static let enableNotifications = Loc.tr("UserProfile", "enableNotifications", fallback: "Enable Notifications")
    /// Female
    public static let genderFemale = Loc.tr("UserProfile", "genderFemale", fallback: "Female")
    /// Male
    public static let genderMale = Loc.tr("UserProfile", "genderMale", fallback: "Male")
    /// Prefer not to say
    public static let genderPreferNotToSay = Loc.tr("UserProfile", "genderPreferNotToSay", fallback: "Prefer not to say")
    /// This information helps us customize your experience
    public static let genderSubtitle = Loc.tr("UserProfile", "genderSubtitle", fallback: "This information helps us customize your experience")
    /// How Do You Identify?
    public static let genderTitle = Loc.tr("UserProfile", "genderTitle", fallback: "How Do You Identify?")
    /// Academic Studies
    public static let goalAcademic = Loc.tr("UserProfile", "goalAcademic", fallback: "Academic Studies")
    /// School, university, or research
    public static let goalAcademicDesc = Loc.tr("UserProfile", "goalAcademicDesc", fallback: "School, university, or research")
    /// Business Communication
    public static let goalBusiness = Loc.tr("UserProfile", "goalBusiness", fallback: "Business Communication")
    /// Professional meetings and networking
    public static let goalBusinessDesc = Loc.tr("UserProfile", "goalBusinessDesc", fallback: "Professional meetings and networking")
    /// Casual Conversation
    public static let goalCasual = Loc.tr("UserProfile", "goalCasual", fallback: "Casual Conversation")
    /// Chat with friends and make connections
    public static let goalCasualDesc = Loc.tr("UserProfile", "goalCasualDesc", fallback: "Chat with friends and make connections")
    /// Cultural Immersion
    public static let goalCultural = Loc.tr("UserProfile", "goalCultural", fallback: "Cultural Immersion")
    /// Appreciate movies, music, and literature
    public static let goalCulturalDesc = Loc.tr("UserProfile", "goalCulturalDesc", fallback: "Appreciate movies, music, and literature")
    /// Moving to Another Country
    public static let goalRelocation = Loc.tr("UserProfile", "goalRelocation", fallback: "Moving to Another Country")
    /// Preparing for life in a new place
    public static let goalRelocationDesc = Loc.tr("UserProfile", "goalRelocationDesc", fallback: "Preparing for life in a new place")
    /// Travel Abroad
    public static let goalTravel = Loc.tr("UserProfile", "goalTravel", fallback: "Travel Abroad")
    /// Planning to visit or explore new countries
    public static let goalTravelDesc = Loc.tr("UserProfile", "goalTravelDesc", fallback: "Planning to visit or explore new countries")
    /// Select topics you'd like to focus on (choose at least one)
    public static let interestsSubtitle = Loc.tr("UserProfile", "interestsSubtitle", fallback: "Select topics you'd like to focus on (choose at least one)")
    /// What Interests You?
    public static let interestsTitle = Loc.tr("UserProfile", "interestsTitle", fallback: "What Interests You?")
    /// Tell us why you're learning a new language
    public static let learningGoalSubtitle = Loc.tr("UserProfile", "learningGoalSubtitle", fallback: "Tell us why you're learning a new language")
    /// What's Your Goal?
    public static let learningGoalTitle = Loc.tr("UserProfile", "learningGoalTitle", fallback: "What's Your Goal?")
    /// How do you want to see your cards?
    public static let modeSelectionSubtitle = Loc.tr("UserProfile", "modeSelectionSubtitle", fallback: "How do you want to see your cards?")
    /// Choose Your Mode
    public static let modeSelectionTitle = Loc.tr("UserProfile", "modeSelectionTitle", fallback: "Choose Your Mode")
    /// Enter your name
    public static let namePlaceholder = Loc.tr("UserProfile", "namePlaceholder", fallback: "Enter your name")
    /// We'd love to know what to call you
    public static let nameSubtitle = Loc.tr("UserProfile", "nameSubtitle", fallback: "We'd love to know what to call you")
    /// UserProfile.strings
    ///   Flippin
    ///   
    ///   User Profile and Onboarding Localization
    ///   Language: en
    ///   Section: user_profile
    public static let nameTitle = Loc.tr("UserProfile", "nameTitle", fallback: "What's Your Name?")
    /// Daily study reminders at your preferred time
    public static let notificationFeature1 = Loc.tr("UserProfile", "notificationFeature1", fallback: "Daily study reminders at your preferred time")
    /// Practice alerts for difficult cards
    public static let notificationFeature2 = Loc.tr("UserProfile", "notificationFeature2", fallback: "Practice alerts for difficult cards")
    /// Streak notifications to stay motivated
    public static let notificationFeature3 = Loc.tr("UserProfile", "notificationFeature3", fallback: "Streak notifications to stay motivated")
    /// Get gentle reminders to practice daily
    public static let notificationSubtitle = Loc.tr("UserProfile", "notificationSubtitle", fallback: "Get gentle reminders to practice daily")
    /// Stay on Track
    public static let notificationTitle = Loc.tr("UserProfile", "notificationTitle", fallback: "Stay on Track")
    /// Advanced
    public static let proficiencyAdvanced = Loc.tr("UserProfile", "proficiencyAdvanced", fallback: "Advanced")
    /// Beginner
    public static let proficiencyBeginner = Loc.tr("UserProfile", "proficiencyBeginner", fallback: "Beginner")
    /// Intermediate
    public static let proficiencyIntermediate = Loc.tr("UserProfile", "proficiencyIntermediate", fallback: "Intermediate")
    /// Your Level
    public static let proficiencyLevel = Loc.tr("UserProfile", "proficiencyLevel", fallback: "Your Level")
    /// Learn every day to maintain your streak
    public static let streakFeature1 = Loc.tr("UserProfile", "streakFeature1", fallback: "Learn every day to maintain your streak")
    /// Track your progress with visual insights
    public static let streakFeature2 = Loc.tr("UserProfile", "streakFeature2", fallback: "Track your progress with visual insights")
    /// Unlock achievements as you grow
    public static let streakFeature3 = Loc.tr("UserProfile", "streakFeature3", fallback: "Unlock achievements as you grow")
    /// We track your daily practice to keep you motivated
    public static let streakSubtitle = Loc.tr("UserProfile", "streakSubtitle", fallback: "We track your daily practice to keep you motivated")
    /// Build Your Streak!
    public static let streakTitle = Loc.tr("UserProfile", "streakTitle", fallback: "Build Your Streak!")
    /// 10 phrases
    public static let weeklyGoal10 = Loc.tr("UserProfile", "weeklyGoal10", fallback: "10 phrases")
    /// 100 phrases
    public static let weeklyGoal100 = Loc.tr("UserProfile", "weeklyGoal100", fallback: "100 phrases")
    /// Intensive Mode
    public static let weeklyGoal100Desc = Loc.tr("UserProfile", "weeklyGoal100Desc", fallback: "Intensive Mode")
    /// Light & Relaxed
    public static let weeklyGoal10Desc = Loc.tr("UserProfile", "weeklyGoal10Desc", fallback: "Light & Relaxed")
    /// 25 phrases
    public static let weeklyGoal25 = Loc.tr("UserProfile", "weeklyGoal25", fallback: "25 phrases")
    /// Balanced Approach
    public static let weeklyGoal25Desc = Loc.tr("UserProfile", "weeklyGoal25Desc", fallback: "Balanced Approach")
    /// 50 phrases
    public static let weeklyGoal50 = Loc.tr("UserProfile", "weeklyGoal50", fallback: "50 phrases")
    /// Ambitious Learner
    public static let weeklyGoal50Desc = Loc.tr("UserProfile", "weeklyGoal50Desc", fallback: "Ambitious Learner")
    /// How many phrases do you want to learn each week?
    public static let weeklyGoalSubtitle = Loc.tr("UserProfile", "weeklyGoalSubtitle", fallback: "How many phrases do you want to learn each week?")
    /// Your Weekly Goal
    public static let weeklyGoalTitle = Loc.tr("UserProfile", "weeklyGoalTitle", fallback: "Your Weekly Goal")
  }
  public enum WelcomeScreen {
    /// Back
    public static let back = Loc.tr("WelcomeScreen", "back", fallback: "Back")
    /// Choose Your Languages
    public static let chooseLanguages = Loc.tr("WelcomeScreen", "chooseLanguages", fallback: "Choose Your Languages")
    /// Select your native language and the language you want to learn
    public static let chooseLanguagesDesc = Loc.tr("WelcomeScreen", "chooseLanguagesDesc", fallback: "Select your native language and the language you want to learn")
    /// Continue
    public static let continueButton = Loc.tr("WelcomeScreen", "continueButton", fallback: "Continue")
    /// Learning Analytics
    public static let featureAnalytics = Loc.tr("WelcomeScreen", "featureAnalytics", fallback: "Learning Analytics")
    /// Track your progress with detailed insights
    public static let featureAnalyticsDesc = Loc.tr("WelcomeScreen", "featureAnalyticsDesc", fallback: "Track your progress with detailed insights")
    /// 17 Languages
    public static let featureLanguages = Loc.tr("WelcomeScreen", "featureLanguages", fallback: "17 Languages")
    /// Support for major world languages
    public static let featureLanguagesDesc = Loc.tr("WelcomeScreen", "featureLanguagesDesc", fallback: "Support for major world languages")
    /// Auto Translation
    public static let featureLearning = Loc.tr("WelcomeScreen", "featureLearning", fallback: "Auto Translation")
    /// Real-time translation as you type
    public static let featureLearningDesc = Loc.tr("WelcomeScreen", "featureLearningDesc", fallback: "Real-time translation as you type")
    /// Text-to-Speech
    public static let featureSmart = Loc.tr("WelcomeScreen", "featureSmart", fallback: "Text-to-Speech")
    /// Hear pronunciation with TTS technology
    public static let featureSmartDesc = Loc.tr("WelcomeScreen", "featureSmartDesc", fallback: "Hear pronunciation with TTS technology")
    /// Create custom flashcards
    public static let finalFeatureAdd = Loc.tr("WelcomeScreen", "finalFeatureAdd", fallback: "Create custom flashcards")
    /// Multiple practice modes
    public static let finalFeatureModes = Loc.tr("WelcomeScreen", "finalFeatureModes", fallback: "Multiple practice modes")
    /// Practice with audio pronunciation
    public static let finalFeaturePractice = Loc.tr("WelcomeScreen", "finalFeaturePractice", fallback: "Practice with audio pronunciation")
    /// Organize with tags and favorites
    public static let finalFeatureProgress = Loc.tr("WelcomeScreen", "finalFeatureProgress", fallback: "Organize with tags and favorites")
    /// Get Started
    public static let getStarted = Loc.tr("WelcomeScreen", "getStarted", fallback: "Get Started")
    /// I'm learning
    public static let imLearning = Loc.tr("WelcomeScreen", "imLearning", fallback: "I'm learning")
    /// The language you want to learn
    public static let imLearningDesc = Loc.tr("WelcomeScreen", "imLearningDesc", fallback: "The language you want to learn")
    /// My language
    public static let myLanguage = Loc.tr("WelcomeScreen", "myLanguage", fallback: "My language")
    /// Your native language
    public static let myLanguageDesc = Loc.tr("WelcomeScreen", "myLanguageDesc", fallback: "Your native language")
    /// You're All Set!
    public static let readyToStart = Loc.tr("WelcomeScreen", "readyToStart", fallback: "You're All Set!")
    /// Your language learning journey begins now
    public static let readyToStartDesc = Loc.tr("WelcomeScreen", "readyToStartDesc", fallback: "Your language learning journey begins now")
    /// Flippin helps you learn languages for travel, study, or daily conversation using smart flashcards.
    public static let welcomeScreenMessage = Loc.tr("WelcomeScreen", "welcomeScreenMessage", fallback: "Flippin helps you learn languages for travel, study, or daily conversation using smart flashcards.")
    /// welcome_screen.strings
    ///   Flippin
    ///   
    ///   Generated from Localizable.strings
    ///   Language: en
    ///   Section: welcome_screen
    public static let welcomeScreenTitle = Loc.tr("WelcomeScreen", "welcomeScreenTitle", fallback: "Welcome to Flippin!")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Loc {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
