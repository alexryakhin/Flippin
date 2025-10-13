//
//  AICoachDetailView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

struct AICoachDetailView: View {
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var aiCoachService = AICoachService.shared
    
    private var insight: CoachInsight {
        aiCoachService.lastInsight ?? CoachInsight.example
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundStyle(.purple)
                    
                    Text(insight.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(insight.summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Insights Section
                CustomSectionView(header: Loc.AIFeatures.keyInsights, backgroundStyle: .standard) {
                    VStack(spacing: 12) {
                        ForEach(Array(insight.insights.enumerated()), id: \.offset) { index, insightItem in
                            InsightRow(insight: insightItem)
                        }
                    }
                }
                
                // Recommendations Section
                CustomSectionView(header: Loc.AIFeatures.recommendations, backgroundStyle: .standard) {
                    VStack(spacing: 12) {
                        ForEach(Array(insight.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            RecommendationRow(recommendation: recommendation) {
                                handleRecommendationTap(recommendation)
                            }
                        }
                    }
                }
                
                // Generated timestamp and refresh button
                VStack(spacing: 12) {
                    if let lastDate = aiCoachService.lastInsightDate {
                        Text(Loc.AIFeatures.generatedAt(lastDate.formatted(date: .abbreviated, time: .shortened)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if aiCoachService.shouldRefreshInsights {
                        ActionButton(
                            Loc.AIFeatures.generateInsights,
                            style: .borderedProminent
                        ) {
                            // Navigate back and trigger refresh
                            NavigationManager.shared.navigateToRoot()
                            // The parent view will handle the refresh
                        }
                    } else if aiCoachService.canManuallyRefresh {
                        ActionButton(
                            Loc.AIFeatures.refreshInsights,
                            style: .bordered
                        ) {
                            // Navigate back and trigger refresh
                            NavigationManager.shared.navigateToRoot()
                            // The parent view will handle the refresh
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .groupedBackground()
        .navigation(
            title: Loc.AIFeatures.aiCoachTitle,
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .onAppear {
            AnalyticsService.trackEvent(.aiCoachInsightViewed)
        }
    }
    
    private func handleRecommendationTap(_ recommendation: Recommendation) {
        HapticService.shared.buttonTapped()
        AnalyticsService.trackEvent(.aiCoachRecommendationTapped, parameters: [
            "action": recommendation.action,
            "priority": recommendation.priority
        ])
        
        // Handle different recommendation actions
        switch recommendation.action.lowercased() {
        case let action where action.contains("practice"):
            NavigationManager.shared.switchToTab(.practice)
        case let action where action.contains("collection"):
            NavigationManager.shared.navigate(to: .presetCollections)
        case let action where action.contains("review"):
            NavigationManager.shared.switchToTab(.practice)
        default:
            break
        }
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let insight: Insight
    
    private var iconColor: Color {
        switch insight.type {
        case .positive: return .green
        case .warning: return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            Text(insight.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .background(iconColor.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Recommendation Row

struct RecommendationRow: View {
    @StateObject private var colorManager = ColorManager.shared

    let recommendation: Recommendation
    let action: () -> Void
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case 1: return .red
        case 2: return .orange
        default: return .blue
        }
    }
    
    private var priorityText: String {
        switch recommendation.priority {
        case 1: return Loc.AIFeatures.highPriority
        case 2: return Loc.AIFeatures.mediumPriority
        default: return Loc.AIFeatures.lowPriority
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(recommendation.action)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(priorityText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor)
                        .cornerRadius(6)
                }
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(colorManager.tintColor)
                }
            }
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

