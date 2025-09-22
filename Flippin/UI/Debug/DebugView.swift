//
//  DebugView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI
import Flow

struct DebugView: View {
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var analyticsService = LearningAnalyticsService.shared
    @StateObject private var remoteConfigService = RemoteConfigService.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Premium Access Debug
                    premiumAccessSection

                    // App State Debug
                    appStateSection

                    // Analytics Debug
                    analyticsSection

                    // Cards Debug
                     cardsSection
                     
                     // Remote Config Debug
                     remoteConfigSection
                 }
                .padding(16)
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Premium Access Section
    private var premiumAccessSection: some View {
        CustomSectionView(header: "Premium Access") {
            FormWithDivider {
                HStack {
                    Text("Debug Mode")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { purchaseService.isDebugModeEnabled },
                        set: { _ in
                            purchaseService.toggleDebugMode()
                        }
                    ))
                    .labelsHidden()
                }

                HStack {
                    Text("Premium Access")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(purchaseService.hasPremiumAccess ? "Enabled" : "Disabled")
                        .font(.subheadline)
                        .foregroundStyle(purchaseService.hasPremiumAccess ? .green : .red)
                }

                NavigationLink {
                    PurchaseTestView()
                } label: {
                    TagView(title: "Purchase Test", isSelected: true, size: .regular)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - App State Section
    private var appStateSection: some View {
        CustomSectionView(header: "App State") {
            FormWithDivider {
                HStack {
                    Text("Total Cards")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(cardsProvider.cards.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Cards with Cached Audio")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(cardsProvider.cards.filter(\.hasCachedAudio).count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Card Limit")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(cardsProvider.cardLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Unlimited Cards")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(cardsProvider.hasUnlimitedCards ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundStyle(cardsProvider.hasUnlimitedCards ? .green : .red)
                }

                HStack {
                    Text("Would Exceed Limit")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(cardsProvider.wouldExceedLimit ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundStyle(cardsProvider.wouldExceedLimit ? .red : .green)
                }
            }
        }
    }

    // MARK: - Analytics Section
    private var analyticsSection: some View {
        CustomSectionView(header: "Analytics") {
            FormWithDivider {
                HStack {
                    Text("Study Streak")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(analyticsService.studyStreak) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Total Study Time")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(formatStudyTime(analyticsService.totalStudyTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Cards Mastered")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(analyticsService.totalCardsMastered)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Current Session")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(analyticsService.currentSession != nil ? "Active" : "None")
                        .font(.subheadline)
                        .foregroundStyle(analyticsService.currentSession != nil ? .green : .red)
                }
            }
        }
    }

    // MARK: - Cards Section
    private var cardsSection: some View {
        CustomSectionView(header: "Cards Debug") {
            HFlow(alignment: .top, spacing: 12) {
                HeaderButton("Add Test Card") {
                    addTestCard()
                }

                HeaderButton("Clear All Cards", role: .destructive) {
                    clearAllCards()
                }

                HeaderButton("Cache Audio for All Cards") {
                    Task {
                        await cardsProvider.cacheAudioForAllCards()
                    }
                }

                HeaderButton("Clear Audio Cache", role: .destructive) {
                    do {
                        try AudioCacheService.shared.clearCache()
                    } catch {
                        print("Failed to clear audio cache: \(error)")
                    }
                }

                HeaderButton("Refresh Analytics") {
                    analyticsService.refreshAnalytics()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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

    private func addTestCard() {
        try? cardsProvider.addCard(
            frontText: "Test Card \(Date().timeIntervalSince1970)",
            backText: "Test Translation",
            notes: "Debug test card",
            tags: []
        )
        print("🔧 Added test card")
    }

    private func clearAllCards() {
        cardsProvider.deleteAllCards()
        print("🔧 Cleared all cards")
    }
    
    // MARK: - Remote Config Section
    private var remoteConfigSection: some View {
        CustomSectionView(header: "Remote Config") {
            FormWithDivider {
                HStack {
                    Text("Remote Config")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(remoteConfigService.isConfigured ? "Connected" : "Not Connected")
                        .font(.subheadline)
                        .foregroundStyle(remoteConfigService.isConfigured ? .green : .red)
                }
                
                HStack {
                    Text("Speechify Enabled")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(remoteConfigService.getSpeechifyEnabled() ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundStyle(remoteConfigService.getSpeechifyEnabled() ? .green : .red)
                }
                
                HStack {
                    Text("API Key Configured")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(!remoteConfigService.getSpeechifyAPIKey().isEmpty ? "Yes" : "No")
                        .font(.subheadline)
                        .foregroundStyle(!remoteConfigService.getSpeechifyAPIKey().isEmpty ? .green : .red)
                }
                
                if let lastFetch = remoteConfigService.lastFetchTime {
                    HStack {
                        Text("Last Updated")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        Text(lastFetch, style: .relative)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button {
                    Task {
                        await remoteConfigService.forceRefresh()
                    }
                } label: {
                    Label("Refresh Config", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    NavigationView {
        DebugView()
    }
}
