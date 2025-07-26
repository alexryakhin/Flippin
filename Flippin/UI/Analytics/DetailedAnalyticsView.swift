import SwiftUI
import Charts

struct DetailedAnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared
    
    @State private var selectedTab = 0
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All Time"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Analytics Tab", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Performance").tag(1)
                    Text("Progress").tag(2)
                    Text("Insights").tag(3)
                }
                .pickerStyle(.segmented)
                .padding(16)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    overviewTab
                        .tag(0)
                    
                    performanceTab
                        .tag(1)
                    
                    progressTab
                        .tag(2)
                    
                    insightsTab
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Detailed Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary cards
                summaryCardsSection
                
                // Study patterns
                studyPatternsSection
                
                // Language progress
                languageProgressSection
                
                // Achievement badges
                achievementBadgesSection
            }
            .padding(16)
        }
    }
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            DetailedStatCard(
                title: "Total Study Time",
                value: formatStudyTime(analyticsService.totalStudyTime),
                subtitle: "Lifetime",
                icon: "clock.fill",
                color: .blue
            )
            
            DetailedStatCard(
                title: "Cards Mastered",
                value: "\(analyticsService.totalCardsMastered)",
                subtitle: "90%+ accuracy",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            DetailedStatCard(
                title: "Study Streak",
                value: "\(analyticsService.studyStreak)",
                subtitle: "consecutive days",
                icon: "flame.fill",
                color: .orange
            )
            
            DetailedStatCard(
                title: "Average Session",
                value: formatStudyTime(analyticsService.dailyStats?.averageSessionTime ?? 0),
                subtitle: "per session",
                icon: "timer",
                color: .purple
            )
        }
    }
    
    private var studyPatternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Study Patterns")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PatternRow(
                    title: "Most Active Time",
                    value: "Evening (6-9 PM)",
                    icon: "moon.fill",
                    color: .indigo
                )
                
                PatternRow(
                    title: "Preferred Session Length",
                    value: "15-20 minutes",
                    icon: "timer",
                    color: .blue
                )
                
                PatternRow(
                    title: "Study Frequency",
                    value: "Daily",
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var languageProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Language Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Language pair progress
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("English → Spanish")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ProgressView(value: 0.75)
                        .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))
                }
                
                Spacer()
                
                Text("75%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colorManager.tintColor)
            }
            
            // Vocabulary growth chart placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Vocabulary Growth")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var achievementBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                AchievementBadge(
                    title: "First Steps",
                    icon: "1.circle.fill",
                    isUnlocked: true,
                    color: .green
                )
                
                AchievementBadge(
                    title: "Week Warrior",
                    icon: "7.circle.fill",
                    isUnlocked: analyticsService.studyStreak >= 7,
                    color: .blue
                )
                
                AchievementBadge(
                    title: "Master Learner",
                    icon: "crown.fill",
                    isUnlocked: analyticsService.totalCardsMastered >= 50,
                    color: .orange
                )
                
                AchievementBadge(
                    title: "Dedicated",
                    icon: "30.circle.fill",
                    isUnlocked: analyticsService.studyStreak >= 30,
                    color: .purple
                )
                
                AchievementBadge(
                    title: "Vocabulary Master",
                    icon: "100.circle.fill",
                    isUnlocked: analyticsService.totalCardsMastered >= 100,
                    color: .red
                )
                
                AchievementBadge(
                    title: "Time Master",
                    icon: "clock.fill",
                    isUnlocked: analyticsService.totalStudyTime >= 3600 * 10, // 10 hours
                    color: .indigo
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Performance Tab
    
    private var performanceTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Accuracy trends
                accuracyTrendsSection
                
                // Session performance
                sessionPerformanceSection
                
                // Card difficulty analysis
                cardDifficultySection
                
                // Learning speed
                learningSpeedSection
            }
            .padding(16)
        }
    }
    
    private var accuracyTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accuracy Trends")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(0..<7, id: \.self) { day in
                    LineMark(
                        x: .value("Day", day),
                        y: .value("Accuracy", 70 + Double(day) * 3 + Double.random(in: -5...5))
                    )
                    .foregroundStyle(colorManager.tintColor.gradient)
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartYScale(domain: 60...100)
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let accuracy = value.as(Double.self) {
                                Text("\(Int(accuracy))%")
                            }
                        }
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("Charts available in iOS 16+")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var sessionPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Performance")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PerformanceMetricRow(
                    title: "Average Session Duration",
                    value: "18 minutes",
                    trend: "+2 min",
                    isPositive: true
                )
                
                PerformanceMetricRow(
                    title: "Cards per Session",
                    value: "12 cards",
                    trend: "+1 card",
                    isPositive: true
                )
                
                PerformanceMetricRow(
                    title: "Session Frequency",
                    value: "2.3 sessions/day",
                    trend: "-0.2",
                    isPositive: false
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var cardDifficultySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Difficulty Analysis")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DifficultyRow(
                    level: "Easy",
                    count: 45,
                    percentage: 60,
                    color: .green
                )
                
                DifficultyRow(
                    level: "Medium",
                    count: 25,
                    percentage: 33,
                    color: .orange
                )
                
                DifficultyRow(
                    level: "Hard",
                    count: 5,
                    percentage: 7,
                    color: .red
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var learningSpeedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Speed")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cards per Hour")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("24")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorManager.tintColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("vs. Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("+8")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Progress Tab
    
    private var progressTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Mastery timeline
                masteryTimelineSection
                
                // Vocabulary growth
                vocabularyGrowthSection
                
                // Learning milestones
                learningMilestonesSection
            }
            .padding(16)
        }
    }
    
    private var masteryTimelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mastery Timeline")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                TimelineEvent(
                    date: "Today",
                    title: "Reached 75 cards mastered",
                    description: "Great progress! You're on track for your weekly goal.",
                    isCompleted: true
                )
                
                TimelineEvent(
                    date: "Yesterday",
                    title: "Completed 3 study sessions",
                    description: "Consistent daily practice is key to success.",
                    isCompleted: true
                )
                
                TimelineEvent(
                    date: "3 days ago",
                    title: "Started new vocabulary set",
                    description: "Added 15 new travel phrases to your collection.",
                    isCompleted: true
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var vocabularyGrowthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vocabulary Growth")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Vocabulary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(analyticsService.totalCardsMastered + 25)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorManager.tintColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("+12")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            // Growth chart placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    Text("Vocabulary growth chart")
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var learningMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Milestones")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                MilestoneRow(
                    title: "First 10 cards mastered",
                    isCompleted: true,
                    date: "2 weeks ago"
                )
                
                MilestoneRow(
                    title: "7-day study streak",
                    isCompleted: true,
                    date: "1 week ago"
                )
                
                MilestoneRow(
                    title: "50 cards mastered",
                    isCompleted: analyticsService.totalCardsMastered >= 50,
                    date: analyticsService.totalCardsMastered >= 50 ? "3 days ago" : "In progress"
                )
                
                MilestoneRow(
                    title: "30-day study streak",
                    isCompleted: analyticsService.studyStreak >= 30,
                    date: analyticsService.studyStreak >= 30 ? "Today" : "In progress"
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Insights Tab
    
    private var insightsTab: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Personalized insights
                personalizedInsightsSection
                
                // Recommendations
                recommendationsSection
                
                // Learning tips
                learningTipsSection
            }
            .padding(16)
        }
    }
    
    private var personalizedInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personalized Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InsightCard(
                    title: "You're most productive in the evening",
                    description: "Your accuracy is 15% higher during 6-9 PM sessions.",
                    icon: "moon.fill",
                    color: .indigo
                )
                
                InsightCard(
                    title: "Shorter sessions work better",
                    description: "Sessions under 20 minutes have 25% higher retention.",
                    icon: "timer",
                    color: .blue
                )
                
                InsightCard(
                    title: "Consistency is key",
                    description: "Daily practice has improved your learning speed by 40%.",
                    icon: "calendar",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                RecommendationCard(
                    title: "Review difficult cards",
                    description: "5 cards need more practice. Focus on these to improve accuracy.",
                    action: "Start Review",
                    color: .orange
                )
                
                RecommendationCard(
                    title: "Add more vocabulary",
                    description: "You're ready for intermediate level phrases.",
                    action: "Browse Collections",
                    color: .blue
                )
                
                RecommendationCard(
                    title: "Extend your streak",
                    description: "You're 3 days away from a new achievement!",
                    action: "Study Now",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var learningTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Tips")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                TipCard(
                    title: "Spaced Repetition",
                    description: "Review cards at increasing intervals for better retention.",
                    icon: "clock.arrow.circlepath"
                )
                
                TipCard(
                    title: "Active Recall",
                    description: "Try to recall the answer before flipping the card.",
                    icon: "brain.head.profile"
                )
                
                TipCard(
                    title: "Context Learning",
                    description: "Learn words in phrases rather than isolation.",
                    icon: "text.bubble"
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helper Methods
    
    private func formatStudyTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Supporting Views

struct DetailedStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PatternRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.subheadline)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

struct PerformanceMetricRow: View {
    let title: String
    let value: String
    let trend: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Text(trend)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isPositive ? .green : .red)
        }
    }
}

struct DifficultyRow: View {
    let level: String
    let count: Int
    let percentage: Int
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(level)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(count) cards")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct TimelineEvent: View {
    let date: String
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Circle()
                    .fill(isCompleted ? .green : .gray)
                    .frame(width: 12, height: 12)
                
                if isCompleted {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct MilestoneRow: View {
    let title: String
    let isCompleted: Bool
    let date: String
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.subheadline)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct InsightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct RecommendationCard: View {
    let title: String
    let description: String
    let action: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action) {
                // Handle action
            }
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TipCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? color : .gray)
            
            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
        .padding(8)
        .background(isUnlocked ? color.opacity(0.1) : Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    DetailedAnalyticsView()
} 
