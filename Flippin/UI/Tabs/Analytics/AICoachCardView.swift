//
//  AICoachCardView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

struct AICoachCardView: View {
    @StateObject private var chatGPTService = ChatGPTService.shared
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var aiCoachService = AICoachService.shared

    @State private var isExpanded = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var premiumFeature: PremiumFeature?

    @ViewBuilder
    var body: some View {
        if purchaseService.hasPremiumAccess {
            premiumView
        } else {
            lockedView
        }
    }
    
    // MARK: - Premium User View

    @ViewBuilder
    private var premiumView: some View {
        CustomSectionView(
            header: Loc.AIFeatures.learningCoach,
            headerFontStyle: .large
        ) {
            VStack(alignment: .leading, spacing: 16) {
                if let insight = aiCoachService.lastInsight {
                    // Summary
                    Text(insight.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(insight.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // View details button
                    Button {
                        navigationManager.navigate(to: .aiCoachDetail)
                        AnalyticsService.trackEvent(.aiCoachInsightViewed)
                        HapticService.shared.buttonTapped()
                    } label: {
                        HStack {
                            Text(Loc.AIFeatures.viewDetailedInsights)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundStyle(colorManager.tintColor)
                        .padding(12)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                } else if chatGPTService.isGenerating {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(Loc.AIFeatures.analyzingProgress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .foregroundStyle(.purple)
                        
                        Text(Loc.AIFeatures.aiCoachEmptyState)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        ActionButton(
                            Loc.AIFeatures.generateInsights,
                            style: .borderedProminent
                        ) {
                            generateInsights()
                        }
                        .disabled(!aiCoachService.canManuallyRefresh && !aiCoachService.shouldRefreshInsights)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                
                // Refresh button
                if aiCoachService.lastInsight != nil && aiCoachService.canManuallyRefresh {
                    Button {
                        generateInsights()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text(Loc.AIFeatures.refreshInsights)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .alert(Loc.AIFeatures.error, isPresented: $showingError) {
            Button(Loc.AIFeatures.ok, role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Free User Locked View

    @ViewBuilder
    private var lockedView: some View {
        CustomSectionView(
            header: Loc.AIFeatures.aiCoachTitle,
            headerFontStyle: .large
        ) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Loc.PremiumFeatures.premiumFeature)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(Loc.AIFeatures.aiCoachDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                ActionButton(
                    Loc.Paywall.upgradeToPremiumTitle,
                    style: .borderedProminent
                ) {
                    premiumFeature = .aiLearningCoach
                    AnalyticsService.trackEvent(.aiFeaturePaywallShown)
                }
            }
        }
        .premiumAlert(feature: $premiumFeature)
    }
    
    // MARK: - Actions
    
    private func generateInsights() {
        Task {
            do {
                let analyticsData = collectAnalyticsData()
                let insight = try await chatGPTService.generateWeeklyCoachInsights(analyticsData: analyticsData)
                
                await MainActor.run {
                    aiCoachService.saveInsight(insight)
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
                    errorMessage = Loc.AIFeatures.aiInsightsFailed
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

