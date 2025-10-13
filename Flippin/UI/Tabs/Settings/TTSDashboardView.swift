//
//  TTSDashboardView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct TTSDashboardView: View {
    @StateObject private var speechifyService = SpeechifyService.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var colorManager = ColorManager.shared

    @State private var isLoading = false
    @State private var showingVoicePicker = false
    @State private var usageHistory: [SpeechifyUsage] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Listening Statistics Chart
                listeningChartSection

                // Voice Selection Section
                voiceSelectionSection

                // Usage Section
                usageSection
            }
            .padding(16)
        }
        .navigation(
            title: Loc.Tts.dashboard,
            mode: .inline,
            showsBackButton: true
        )
        .groupedBackground()
        .onAppear {
            loadVoices()
            loadUsageHistory()
        }
        .sheet(isPresented: $showingVoicePicker) {
            VoicePickerView()
        }
    }

    // MARK: - Usage Section
    private var usageSection: some View {
        CustomSectionView(header: Loc.Tts.Usage.monthlyUsage, backgroundStyle: .standard) {
            VStack(alignment: .leading, spacing: 16) {
                // Usage Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(Loc.Tts.Analytics.charactersUsed)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text("\(speechifyService.charactersUsed) / \(speechifyService.charactersLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: speechifyService.usagePercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))

                    Text("\(Int(speechifyService.usagePercentage))\(Loc.Tts.Usage.percentUsed)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Usage Stats
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Loc.Tts.remaining)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(speechifyService.remainingCharacters)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(Loc.Tts.Usage.listeningTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatListeningTime(speechifyService.listeningTimeMinutes))
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                
                // Cache information
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(Loc.Tts.Usage.previewCacheSize): \(formatBytes(SpeechifyTTSPreviewPlayer.shared.getCacheSize()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Voice Selection Section
    private var voiceSelectionSection: some View {
        CustomSectionView(header: Loc.Tts.Usage.voiceSelection, backgroundStyle: .standard) {
            VStack(alignment: .leading, spacing: 12) {
                // Selected Voice Display
                if let selectedVoice = speechifyService.selectedVoice {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(Loc.Tts.currentVoice)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(selectedVoice.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text(Loc.Tts.Usage.language)
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(selectedVoice.language)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let gender = selectedVoice.gender {
                            HStack {
                                Text(Loc.Tts.Usage.gender)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text(gender)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                HeaderButton(Loc.Tts.changeVoice, icon: "speaker.wave.3") {
                    showingVoicePicker = true
                }
            }
        }
    }

    // MARK: - Listening Chart Section
    private var listeningChartSection: some View {
        SpeechifyListeningChart(usageHistory: usageHistory)
    }

    // MARK: - Helper Methods

    private func loadVoices() {
        speechifyService.loadVoices()
    }

    private func loadUsageHistory() {
        usageHistory = speechifyService.getUsageHistory(months: 6)
    }

    private func formatListeningTime(_ minutes: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = minutes < 60 ? [.minute, .second] : [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        let timeInterval = TimeInterval(minutes * 60)
        return formatter.string(from: timeInterval) ?? "\(Int(minutes))m"
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview {
    NavigationView {
        TTSDashboardView()
    }
}
