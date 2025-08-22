import Foundation
import FirebaseAnalytics

// MARK: - Analytics Events Enum
enum AnalyticsEvent: String, CaseIterable {
    // MARK: - Card Events
    case cardFlipped = "card_flipped"
    case cardPlayed = "card_played"
    case cardAdded = "card_added"
    case cardDeleted = "card_deleted"
    case cardEdited = "card_edited"
    case allCardsDeleted = "all_cards_deleted"
    case cardFavorited = "card_favorited"
    case cardUnfavorited = "card_unfavorited"
    case translationCompleted = "translation_completed"

    // MARK: - Navigation Events
    case settingsScreenOpened = "settings_screen_opened"
    case myCardsScreenOpened = "my_cards_screen_opened"
    case addCardScreenOpened = "add_card_screen_opened"
    case welcomeScreenOpened = "welcome_screen_opened"
    case backgroundPreviewOpened = "background_preview_opened"
    case backgroundDemoOpened = "background_demo_opened"
    case presetCollectionsOpened = "preset_collections_opened"

    // MARK: - Tag Events
    case tagAdded = "tag_added"
    case tagDeleted = "tag_deleted"
    case tagFilterApplied = "tag_filter_applied"
    case tagFilterCleared = "tag_filter_cleared"
    case favoriteFilterApplied = "favorite_filter_applied"
    case favoriteFilterCleared = "favorite_filter_cleared"

    // MARK: - Settings Events
    case languageChanged = "language_changed"
    case backgroundStyleChanged = "background_style_changed"
    case backgroundColorChanged = "background_color_changed"
    case travelModeToggled = "travel_mode_toggled"
    case aboutScreenOpened = "about_screen_opened"
    case donationLinkOpened = "donation_link_opened"

    // MARK: - Search Events
    case searchPerformed = "search_performed"
    case searchCleared = "search_cleared"

    // MARK: - App Events
    case appLaunched = "app_launched"
    case appBackgrounded = "app_backgrounded"
    case appForegrounded = "app_foregrounded"

    // MARK: - Learning Events
    case studySessionStarted = "study_session_started"
    case studySessionEnded = "study_session_ended"
    case cardsShuffled = "cards_shuffled"
    case cardReviewedCorrect = "card_reviewed_correct"
    case cardReviewedIncorrect = "card_reviewed_incorrect"
    case masteryLevelReached = "mastery_level_reached"
    case studyStreakExtended = "study_streak_extended"
    case analyticsViewed = "analytics_viewed"
    case detailedAnalyticsViewed = "detailed_analytics_viewed"
    case insightRecommendationAction = "insight_recommendation_action"

    // MARK: - Error Events
    case errorOccurred = "error_occurred"
    case translationFailed = "translation_failed"
    case ttsFailed = "tts_failed"

    // MARK: - Purchase Events
    case purchaseTestOpened = "purchase_test_opened"
    case transactionUpdated = "transaction_updated"
    case transactionVerificationFailed = "transaction_verification_failed"
    case purchaseFailed = "purchase_failed"
    case purchaseCompleted = "purchase_completed"
    case paywallOpened = "paywall_opened"

    // MARK: - Preset Collection Events
    case presetCollectionImported = "preset_collection_imported"
    case presetCollectionViewed = "preset_collection_viewed"
    
    // MARK: - Notification Events
    case studyRemindersEnabled = "study_reminders_enabled"
    case studyRemindersDisabled = "study_reminders_disabled"
    case difficultCardRemindersEnabled = "difficult_card_reminders_enabled"
    case difficultCardRemindersDisabled = "difficult_card_reminders_disabled"
    case difficultCardReminderScheduled = "difficult_card_reminder_scheduled"
}

// MARK: - Analytics Service
final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    // MARK: - Event Tracking Methods

    /// Track a simple event
    /// - Parameter event: The analytics event to track
    static func trackEvent(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.rawValue, parameters: nil)
        print("📊 Analytics: \(event.rawValue)")
    }

    /// Track an event with parameters
    /// - Parameters:
    ///   - event: The analytics event to track
    ///   - parameters: Additional parameters to include with the event
    static func trackEvent(_ event: AnalyticsEvent, parameters: [String: Any]) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        print("📊 Analytics: \(event.rawValue) with parameters: \(parameters)")
    }

    /// Track card-related events with card information
    /// - Parameters:
    ///   - event: The card event to track
    ///   - cardLanguage: The language of the card
    ///   - hasTags: Whether the card has tags
    ///   - tagCount: Number of tags on the card
    static func trackCardEvent(_ event: AnalyticsEvent, cardLanguage: String? = nil, hasTags: Bool? = nil, tagCount: Int? = nil) {
        var parameters: [String: Any] = [:]

        if let cardLanguage = cardLanguage {
            parameters["card_language"] = cardLanguage
        }
        if let hasTags = hasTags {
            parameters["has_tags"] = hasTags
        }
        if let tagCount = tagCount {
            parameters["tag_count"] = tagCount
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track settings changes
    /// - Parameters:
    ///   - event: The settings event to track
    ///   - oldValue: The previous value
    ///   - newValue: The new value
    static func trackSettingsEvent(_ event: AnalyticsEvent, oldValue: String? = nil, newValue: String? = nil) {
        var parameters: [String: Any] = [:]

        if let oldValue = oldValue {
            parameters["old_value"] = oldValue
        }
        if let newValue = newValue {
            parameters["new_value"] = newValue
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track search events
    /// - Parameters:
    ///   - event: The search event to track
    ///   - searchTerm: The search term used
    ///   - resultCount: Number of results found
    static func trackSearchEvent(_ event: AnalyticsEvent, searchTerm: String? = nil, resultCount: Int? = nil) {
        var parameters: [String: Any] = [:]

        if let searchTerm = searchTerm {
            parameters["search_term"] = searchTerm
        }
        if let resultCount = resultCount {
            parameters["result_count"] = resultCount
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track tag events
    /// - Parameters:
    ///   - event: The tag event to track
    ///   - tagName: The name of the tag
    ///   - tagCount: Total number of tags
    static func trackTagEvent(_ event: AnalyticsEvent, tagName: String? = nil, tagCount: Int? = nil) {
        var parameters: [String: Any] = [:]

        if let tagName = tagName {
            parameters["tag_name"] = tagName
        }
        if let tagCount = tagCount {
            parameters["tag_count"] = tagCount
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track error events
    /// - Parameters:
    ///   - event: The error event to track
    ///   - errorMessage: The error message
    ///   - errorCode: The error code if available
    static func trackErrorEvent(_ event: AnalyticsEvent, errorMessage: String? = nil, errorCode: String? = nil) {
        var parameters: [String: Any] = [:]

        if let errorMessage = errorMessage {
            parameters["error_message"] = errorMessage
        }
        if let errorCode = errorCode {
            parameters["error_code"] = errorCode
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track study session events
    /// - Parameters:
    ///   - event: The study session event to track
    ///   - sessionDuration: Duration of the session in seconds
    ///   - cardsReviewed: Number of cards reviewed
    static func trackStudySessionEvent(_ event: AnalyticsEvent, sessionDuration: TimeInterval? = nil, cardsReviewed: Int? = nil) {
        var parameters: [String: Any] = [:]

        if let sessionDuration = sessionDuration {
            parameters["session_duration"] = sessionDuration
        }
        if let cardsReviewed = cardsReviewed {
            parameters["cards_reviewed"] = cardsReviewed
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track favorite events
    /// - Parameters:
    ///   - event: The favorite event to track
    ///   - cardLanguage: The language of the card
    ///   - hasTags: Whether the card has tags
    static func trackFavoriteEvent(_ event: AnalyticsEvent, cardLanguage: String? = nil, hasTags: Bool? = nil) {
        var parameters: [String: Any] = [:]

        if let cardLanguage = cardLanguage {
            parameters["card_language"] = cardLanguage
        }
        if let hasTags = hasTags {
            parameters["has_tags"] = hasTags
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track preset collection events
    /// - Parameters:
    ///   - event: The preset collection event to track
    ///   - collectionName: The name of the collection
    ///   - cardCount: Number of cards in the collection
    ///   - category: The category of the collection
    static func trackPresetCollectionEvent(_ event: AnalyticsEvent, collectionName: String? = nil, cardCount: Int? = nil, category: String? = nil) {
        var parameters: [String: Any] = [:]

        if let collectionName = collectionName {
            parameters["collection_name"] = collectionName
        }
        if let cardCount = cardCount {
            parameters["card_count"] = cardCount
        }
        if let category = category {
            parameters["category"] = category
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track filter events
    /// - Parameters:
    ///   - event: The filter event to track
    ///   - filterType: The type of filter (tag, favorite, language)
    ///   - filterValue: The value of the filter
    static func trackFilterEvent(_ event: AnalyticsEvent, filterType: String? = nil, filterValue: String? = nil) {
        var parameters: [String: Any] = [:]

        if let filterType = filterType {
            parameters["filter_type"] = filterType
        }
        if let filterValue = filterValue {
            parameters["filter_value"] = filterValue
        }

        trackEvent(event, parameters: parameters)
    }

    /// Track insight recommendation action
    /// - Parameters:
    ///   - action: The action type (e.g., studyNow, startReview, etc.)
    ///   - title: The recommendation title
    ///   - description: The recommendation description (optional)
    static func trackInsightRecommendationAction(action: String, title: String, description: String? = nil) {
        var parameters: [String: Any] = [
            "action": action,
            "title": title
        ]
        if let description = description {
            parameters["description"] = description
        }
        trackEvent(.insightRecommendationAction, parameters: parameters)
    }

    // MARK: - User Properties

    /// Set user properties for analytics
    /// - Parameters:
    ///   - nativeLanguage: User's native language
    ///   - targetLanguage: Language user is learning
    ///   - backgroundStyle: User's preferred background style
    static func setUserProperties(nativeLanguage: String? = nil, targetLanguage: String? = nil, backgroundStyle: String? = nil) {
        if let nativeLanguage = nativeLanguage {
            Analytics.setUserProperty(nativeLanguage, forName: "native_language")
        }
        if let targetLanguage = targetLanguage {
            Analytics.setUserProperty(targetLanguage, forName: "target_language")
        }
        if let backgroundStyle = backgroundStyle {
            Analytics.setUserProperty(backgroundStyle, forName: "background_style")
        }
    }

    /// Set user ID for analytics
    /// - Parameter userId: The user's unique identifier
    static func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
}
