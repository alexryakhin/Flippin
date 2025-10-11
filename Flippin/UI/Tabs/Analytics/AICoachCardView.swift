//
//  AICoachCardView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI
import DotLottie

struct AICoachCardView: View {
    @StateObject private var chatGPTService = ChatGPTService.shared
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var navigationManager = NavigationManager.shared
    
    @State private var coachInsight: CoachInsight?
    @State private var isExpanded = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingPaywall = false
    @State private var lastGeneratedDate: Date?
    
    var canRefresh: Bool {
        guard let lastDate = lastGeneratedDate else { return true }
        return Date().timeIntervalSince(lastDate) > 3600 // 1 hour cooldown
    }
    
    var body: some View {
        if purchaseService.hasPremiumAccess {
            premiumView
        } else {
            lockedView
        }
    }
    
    // MARK: - Premium User View
    
    private var premiumView: some View {
        CustomSectionView(
            header: "🧠 AI Learning Coach",
            headerFontStyle: .large
        ) {
            VStack(alignment: .leading, spacing: 16) {
                DotLottieAnimation(fileName: "book_loading", config: .init())
                    .view()
                if let insight = coachInsight {
                    // Summary
                    Text(insight.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(insight.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // View details button
                    Button {
                        navigationManager.navigate(to: .aiCoachDetail(insight))
                        AnalyticsService.trackEvent(.aiCoachInsightViewed)
                        HapticService.shared.buttonTapped()
                    } label: {
                        HStack {
                            Text("View Detailed Insights")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.accentColor)
                        .padding(12)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                } else if chatGPTService.isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("AI is analyzing your progress...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                        
                        Text("Get personalized insights about your learning")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        ActionButton(
                            "Generate Insights",
                            style: .borderedProminent
                        ) {
                            generateInsights()
                        }
                        .disabled(!canRefresh)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                
                // Refresh button
                if coachInsight != nil && canRefresh {
                    Button {
                        generateInsights()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh Insights")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Free User Locked View
    
    private var lockedView: some View {
        CustomSectionView(
            header: "🧠 AI Learning Coach",
            headerFontStyle: .large
        ) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Feature")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Get AI-powered insights about your learning progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                ActionButton(
                    "Upgrade to Premium",
                    style: .borderedProminent
                ) {
                    showingPaywall = true
                    AnalyticsService.trackEvent(.aiFeaturePaywallShown)
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            Paywall.ContentView()
        }
    }
    
    // MARK: - Actions
    
    private func generateInsights() {
        Task {
            do {
                let analyticsData = collectAnalyticsData()
                let insight = try await chatGPTService.generateWeeklyCoachInsights(analyticsData: analyticsData)
                
                await MainActor.run {
                    coachInsight = insight
                    lastGeneratedDate = Date()
                    HapticService.shared.success()
                    AnalyticsService.trackEvent(.aiCoachInsightGenerated)
                }
            } catch let error as ChatGPTError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    HapticService.shared.error()
                    AnalyticsService.trackEvent(.aiFeatureError, parameters: [
                        "error": error.localizedDescription
                    ])
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate insights. Please try again."
                    showingError = true
                    HapticService.shared.error()
                }
            }
        }
    }
    
    private func collectAnalyticsData() -> AnalyticsDataSnapshot {
        let difficultCards = analyticsService.getDifficultCardsNeedingReview()
            .compactMap { $0.frontText }
        
        let weeklyData = analyticsService.getWeeklyStudyData()
        let weeklyCardsStudied = weeklyData.reduce(0) { $0 + $1.cardsStudied }
        let accuracy = analyticsService.getOverallAccuracy()
        let masteryStats = analyticsService.getMasteryStats()
        
        // Calculate average time per card
        let studyTimeStats = analyticsService.getStudyTimeStats()
        let averageTime = weeklyCardsStudied > 0 ? studyTimeStats.total / Double(weeklyCardsStudied) : 0
        
        return AnalyticsDataSnapshot(
            weeklyAccuracy: accuracy,
            cardsReviewed: weeklyCardsStudied,
            studyConsistency: weeklyData.filter { $0.cardsStudied > 0 }.count,
            difficultCards: Array(difficultCards.prefix(10)),
            averageTimePerCard: averageTime,
            masteryDistribution: [:],
            streakDays: analyticsService.studyStreak,
            totalCards: masteryStats.total,
            masteredCards: masteryStats.mastered
        )
    }
}

