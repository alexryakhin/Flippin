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
        CustomSectionView(header: "Monthly Usage", backgroundStyle: .standard) {
            VStack(alignment: .leading, spacing: 16) {
                // Usage Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Characters Used")
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text("\(speechifyService.charactersUsed) / \(speechifyService.charactersLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: speechifyService.usagePercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: colorManager.tintColor))

                    Text("\(Int(speechifyService.usagePercentage))% used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Usage Stats
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(speechifyService.remainingCharacters)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Listening Time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatListeningTime(speechifyService.listeningTimeMinutes))
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                
                // Cache information
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview Cache Size: \(formatBytes(SpeechifyTTSPreviewPlayer.shared.getCacheSize()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Voice Selection Section
    private var voiceSelectionSection: some View {
        CustomSectionView(header: "Voice Selection", backgroundStyle: .standard) {
            VStack(alignment: .leading, spacing: 12) {
                // Selected Voice Display
                if let selectedVoice = speechifyService.selectedVoice {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Current Voice")
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(selectedVoice.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        HStack {
                            Text("Language")
                                .font(.subheadline)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(selectedVoice.language)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let gender = selectedVoice.gender {
                            HStack {
                                Text("Gender")
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

                HeaderButton("Change Voice", icon: "speaker.wave.3") {
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
        if minutes < 1 {
            return "\(Int(minutes * 60))s"
        } else if minutes < 60 {
            return "\(Int(minutes))m"
        } else {
            let hours = Int(minutes / 60)
            let remainingMinutes = Int(minutes.truncatingRemainder(dividingBy: 60))
            return "\(hours)h \(remainingMinutes)m"
        }
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
