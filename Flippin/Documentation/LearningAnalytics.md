# Learning Analytics System

## Overview

The Learning Analytics System provides comprehensive tracking and insights for user learning progress in the Flippin app. It tracks study sessions, card performance, mastery levels, and provides detailed analytics to help users understand their learning patterns and improve their language acquisition.

## Architecture

### Core Components

1. **LearningAnalyticsService**: Main service for managing analytics data
2. **StudySession**: Core Data entity for tracking study sessions
3. **CardPerformance**: Core Data entity for individual card performance
4. **DailyStats**: Core Data entity for daily learning statistics
5. **AnalyticsDashboardView**: Main analytics dashboard UI
6. **DetailedAnalyticsView**: Advanced analytics with multiple tabs
7. **StudyModeView**: Dedicated study mode with progress tracking

### Data Flow

```
User Interaction → LearningAnalyticsService → Core Data → Analytics Views
     ↓
Firebase Analytics → Remote Analytics Dashboard
```

## Data Models

### StudySession Entity

Tracks individual study sessions with detailed metrics:

```swift
@objc(StudySession)
public final class StudySession: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var duration: Double
    @NSManaged public var cardsReviewed: Int32
    @NSManaged public var cardsCorrect: Int32
    @NSManaged public var cardsIncorrect: Int32
    @NSManaged public var sessionType: String? // "review", "new", "practice"
    @NSManaged public var languagePair: String? // "en-es", "fr-en", etc.
    @NSManaged public var tags: NSSet?
}
```

### CardPerformance Entity

Tracks individual card mastery and performance:

```swift
@objc(CardPerformance)
public final class CardPerformance: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var cardId: String?
    @NSManaged public var totalReviews: Int32
    @NSManaged public var correctReviews: Int32
    @NSManaged public var incorrectReviews: Int32
    @NSManaged public var lastReviewed: Date?
    @NSManaged public var nextReviewDate: Date?
    @NSManaged public var difficultyLevel: Int16 // 1-5 scale
    @NSManaged public var timeSpent: Double
    @NSManaged public var consecutiveCorrect: Int32
    @NSManaged public var consecutiveIncorrect: Int32
    @NSManaged public var masteryLevel: Int16 // 0-100 scale
}
```

### DailyStats Entity

Tracks daily learning statistics:

```swift
@objc(DailyStats)
public final class DailyStats: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var date: Date?
    @NSManaged public var totalStudyTime: Double
    @NSManaged public var cardsStudied: Int32
    @NSManaged public var newCardsAdded: Int32
    @NSManaged public var sessionsCompleted: Int32
    @NSManaged public var streakDays: Int32
    @NSManaged public var languagePair: String?
}
```

## LearningAnalyticsService

### Key Features

- **Study Session Management**: Start/end sessions with automatic timing
- **Card Performance Tracking**: Record correct/incorrect answers with timing
- **Mastery System**: Calculate mastery levels based on performance
- **Spaced Repetition**: Determine next review dates using spaced repetition algorithm
- **Statistics Calculation**: Calculate streaks, study time, and performance metrics
- **Data Persistence**: Automatic Core Data integration with CloudKit sync

### Usage Examples

#### Starting a Study Session

```swift
// Start a new study session
LearningAnalyticsService.shared.startStudySession(sessionType: "review")

// Session is automatically tracked with timing
```

#### Recording Card Reviews

```swift
// Record a card review with timing
LearningAnalyticsService.shared.recordCardReview(
    cardId: card.id,
    wasCorrect: true,
    timeSpent: 5.2 // seconds
)
```

#### Getting Analytics Data

```swift
// Get mastery statistics
let masteryStats = analyticsService.getMasteryStats()
// Returns: (total: Int, mastered: Int, learning: Int, needsReview: Int)

// Get study time statistics
let studyTimeStats = analyticsService.getStudyTimeStats()
// Returns: (total: TimeInterval, today: TimeInterval, average: TimeInterval)

// Get cards needing review
let cardsNeedingReview = analyticsService.getCardsNeedingReview()
```

## Mastery System

### Mastery Calculation

The mastery system uses a sophisticated algorithm that considers:

1. **Accuracy Rate**: Percentage of correct answers
2. **Consecutive Correct**: Bonus for consistent performance
3. **Recent Mistakes**: Penalty for recent incorrect answers
4. **Time Spent**: Learning effort consideration

```swift
private func updateCardMastery(performance: CardPerformance) {
    let accuracy = performance.accuracyRate
    let consecutiveCorrect = performance.consecutiveCorrect
    
    var mastery = Int16(accuracy * 100)
    
    // Bonus for consecutive correct answers
    if consecutiveCorrect >= 5 {
        mastery += 10
    } else if consecutiveCorrect >= 3 {
        mastery += 5
    }
    
    // Penalty for recent mistakes
    if performance.consecutiveIncorrect >= 2 {
        mastery -= 15
    }
    
    performance.masteryLevel = max(0, min(100, mastery))
}
```

### Mastery Levels

- **0-30**: Needs Work (Red)
- **31-60**: Learning (Orange)
- **61-89**: Good Progress (Blue)
- **90-100**: Mastered (Green)

## Spaced Repetition System

### Algorithm

The spaced repetition system determines when cards should be reviewed based on:

1. **Current Accuracy**: Higher accuracy = longer intervals
2. **Consecutive Correct**: More consecutive correct = longer intervals
3. **Difficulty Level**: Harder cards = shorter intervals

```swift
private func updateNextReviewDate(performance: CardPerformance) {
    let accuracy = performance.accuracyRate
    let consecutiveCorrect = performance.consecutiveCorrect
    
    var daysToAdd: Int
    
    if accuracy >= 0.9 && consecutiveCorrect >= 3 {
        // Well known: review in 7-30 days
        daysToAdd = min(30, 7 + consecutiveCorrect * 2)
    } else if accuracy >= 0.7 {
        // Known: review in 3-7 days
        daysToAdd = min(7, 3 + consecutiveCorrect)
    } else {
        // Needs work: review soon
        daysToAdd = max(1, 3 - consecutiveCorrect)
    }
    
    performance.nextReviewDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date())
}
```

## UI Components

### AnalyticsDashboardView

Main dashboard showing:
- Study streak
- Total study time
- Cards mastered
- Quick statistics
- Study time chart
- Mastery progress
- Recent activity

### DetailedAnalyticsView

Advanced analytics with four tabs:

1. **Overview**: Summary cards, study patterns, language progress, achievements
2. **Performance**: Accuracy trends, session performance, card difficulty analysis
3. **Progress**: Mastery timeline, vocabulary growth, learning milestones
4. **Insights**: Personalized insights, recommendations, learning tips

### StudyModeView

Dedicated study mode with:
- Progress tracking
- Card-by-card review
- Correct/incorrect feedback
- Session results
- Performance analytics

## Analytics Events

### New Events Added

```swift
case cardReviewedCorrect = "card_reviewed_correct"
case cardReviewedIncorrect = "card_reviewed_incorrect"
case masteryLevelReached = "mastery_level_reached"
case studyStreakExtended = "study_streak_extended"
case analyticsViewed = "analytics_viewed"
case detailedAnalyticsViewed = "detailed_analytics_viewed"
```

### Event Tracking

```swift
// Track card review
AnalyticsService.trackCardEvent(
    wasCorrect ? .cardReviewedCorrect : .cardReviewedIncorrect,
    cardLanguage: card.frontLanguage?.rawValue,
    hasTags: !card.tagNames.isEmpty,
    tagCount: card.tagNames.count
)

// Track study session
AnalyticsService.trackStudySessionEvent(
    .studySessionEnded,
    sessionDuration: duration,
    cardsReviewed: Int(session.cardsReviewed)
)
```

## Integration Points

### Card Interaction

The system automatically tracks card interactions:

```swift
// In CardView
.onTapGesture {
    // Start study session if not already started
    if LearningAnalyticsService.shared.currentSession == nil {
        LearningAnalyticsService.shared.startStudySession()
    }
}
```

### Settings Integration

Analytics section added to settings:

```swift
// In SettingsView
private var analyticsSection: some View {
    CustomSectionView(header: "Learning Analytics") {
        Button("View Analytics") {
            // Present analytics dashboard
        }
    }
}
```

### App Lifecycle

Automatic session management:

```swift
// In LearningAnalyticsService
private func setupObservers() {
    NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        .sink { [weak self] _ in
            self?.endStudySession()
        }
        .store(in: &cancellables)
}
```

## Premium Features

### Free Users
- Basic analytics dashboard
- Study session tracking
- Card performance tracking
- Basic mastery system

### Premium Users
- Detailed analytics with multiple tabs
- Advanced insights and recommendations
- Achievement badges
- Personalized learning tips
- Advanced charts and visualizations
- Export capabilities

## Performance Considerations

### Data Management
- Efficient Core Data queries with proper indexing
- Batch operations for bulk data updates
- Automatic cleanup of old data
- CloudKit sync optimization

### Memory Management
- Lazy loading of analytics data
- Proper object lifecycle management
- Background processing for heavy calculations

### UI Performance
- Efficient chart rendering
- Smooth animations and transitions
- Proper state management
- Background data loading

## Future Enhancements

### Planned Features
1. **Advanced Spaced Repetition**: More sophisticated algorithms
2. **Learning Paths**: Personalized learning sequences
3. **Social Features**: Compare progress with friends
4. **Gamification**: More achievement badges and rewards
5. **Export/Import**: Data portability
6. **Machine Learning**: Predictive analytics and recommendations

### Technical Improvements
1. **Real-time Sync**: Live analytics updates
2. **Offline Support**: Analytics without internet
3. **Data Visualization**: More advanced charts
4. **Performance Optimization**: Faster data processing
5. **Accessibility**: VoiceOver and accessibility improvements

## Troubleshooting

### Common Issues

#### Analytics Not Updating
1. Check Core Data context is properly saved
2. Verify CloudKit sync is working
3. Ensure analytics service is properly initialized

#### Performance Issues
1. Check for memory leaks in analytics service
2. Verify Core Data queries are optimized
3. Monitor background processing

#### Data Inconsistencies
1. Check CloudKit sync status
2. Verify data migration is working
3. Check for concurrent access issues

### Debug Tools

```swift
// Enable analytics debugging
print("📊 Analytics: \(event.rawValue)")

// Check analytics data
let masteryStats = analyticsService.getMasteryStats()
print("Mastery Stats: \(masteryStats)")

// Verify Core Data
let context = CoreDataService.shared.context
print("Core Data context: \(context)")
```

## Best Practices

### Data Collection
- Collect only necessary data
- Respect user privacy
- Provide clear data usage information
- Allow users to opt out

### Performance
- Use efficient Core Data queries
- Implement proper error handling
- Monitor memory usage
- Optimize UI updates

### User Experience
- Provide clear, actionable insights
- Use intuitive visualizations
- Offer personalized recommendations
- Maintain consistent design language

### Privacy
- Store data locally by default
- Use CloudKit for optional sync
- Anonymize analytics data
- Follow GDPR and privacy guidelines 