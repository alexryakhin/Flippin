//
//  AICoachDetailView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

struct AICoachDetailView: View {
    @StateObject private var colorManager = ColorManager.shared
    
    let insight: CoachInsight
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text(insight.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(insight.summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Insights Section
                CustomSectionView(header: "Key Insights", backgroundStyle: .standard) {
                    VStack(spacing: 12) {
                        ForEach(Array(insight.insights.enumerated()), id: \.offset) { index, insightItem in
                            InsightRow(insight: insightItem)
                        }
                    }
                }
                
                // Recommendations Section
                CustomSectionView(header: "Recommendations", backgroundStyle: .standard) {
                    VStack(spacing: 12) {
                        ForEach(Array(insight.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            RecommendationRow(recommendation: recommendation) {
                                handleRecommendationTap(recommendation)
                            }
                        }
                    }
                }
                
                // Generated timestamp
                Text("Generated \(Date().formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
        }
        .groupedBackground()
        .navigation(
            title: "AI Coach",
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
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            Text(insight.text)
                .font(.subheadline)
                .foregroundColor(.primary)
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
        case 1: return "High Priority"
        case 2: return "Medium Priority"
        default: return "Low Priority"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(recommendation.action)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(priorityText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor)
                        .cornerRadius(6)
                }
                
                Text(recommendation.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .padding(12)
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

