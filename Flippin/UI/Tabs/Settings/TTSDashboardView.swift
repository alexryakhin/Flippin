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
                // Usage Section
                usageSection

                // Listening Statistics Chart
                listeningChartSection

                // Voice Selection Section
                voiceSelectionSection

                // Test Section
                testSection
            }
            .padding(16)
        }
        .navigationTitle("TTS Dashboard")
        .navigationBarTitleDisplayMode(.large)
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
        CustomSectionView(header: "Monthly Usage") {
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

                    VStack(alignment: .center, spacing: 4) {
                        Text("Used")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(speechifyService.charactersUsed)")
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


            }
        }
    }

    // MARK: - Voice Selection Section
    private var voiceSelectionSection: some View {
        CustomSectionView(header: "Voice Selection") {
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

    // MARK: - Test Section
    private var testSection: some View {
        CustomSectionView(header: "Test TTS") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Test your selected voice with a sample text.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                AsyncHeaderButton("Test Voice", icon: "play.circle") {
                    await testTTS()
                }
                .disabled(speechifyService.selectedVoice == nil || speechifyService.isPlaying)
            }
        }
    }

    // MARK: - Helper Methods

    private func loadVoices() {
        speechifyService.loadVoices()
    }

    private func loadUsageHistory() {
        usageHistory = speechifyService.getUsageHistory(months: 6)
    }

    private func testTTS() async {
        guard speechifyService.selectedVoice != nil else { return }

        let testText = "Hello, this is a test of the Speechify text-to-speech system."

        do {
            try await speechifyService.playText(testText, language: .english)
        } catch {
            errorReceived(error)
        }
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


}



#Preview {
    NavigationView {
        TTSDashboardView()
    }
}
