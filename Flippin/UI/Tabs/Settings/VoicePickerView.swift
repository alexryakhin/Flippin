//
//  VoicePickerView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import SwiftUI

struct VoicePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechifyService = SpeechifyService.shared
    @State private var searchText = ""
    @State private var selectedLanguage: String = "All"
    @State private var selectedGender: String = "All"
    @State private var isLoading = false

    // Voice categories for filtering
    @State private var availableLanguages: [String] = []
    @State private var availableGenders: [String] = []

    var body: some View {
        NavigationView {
            ScrollView {
                voiceList
                    .padding(.horizontal, 16)
                    .if(isPad) { view in
                        view
                            .frame(maxWidth: 550, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
            }
            .background(Color(.systemGroupedBackground))
            .navigation(
                title: "Select Voice",
                mode: .large,
                trailingContent: {
                    HeaderButton("Done") {
                        dismiss()
                    }
                    .disabled(speechifyService.selectedVoiceId.isEmpty)
                },
                bottomContent: {
                    VStack(spacing: 8) {
                        InputView.searchView("Search", searchText: $searchText)
                        languageFilterView
                    }
                }
            )
            .onAppear {
                loadVoices()
            }
        }
    }

    // MARK: - Voice List

    private var voiceList: some View {
        CustomSectionView(header: "Available Voices") {
            Group {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading voices...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredVoices.isEmpty {
                    ContentUnavailableView(
                        "No voices found",
                        systemImage: "speaker.slash",
                        description: Text(searchText.isEmpty ? "No voices available" : "Try adjusting your search or filters")
                    )
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredVoices, id: \.id) { voice in
                            VoiceRowView(
                                voice: voice,
                                isSelected: speechifyService.selectedVoiceId == voice.id,
                                onSelect: {
                                    speechifyService.selectVoice(voice.id)
                                },
                                onPreview: {
                                    previewVoice(voice)
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredVoices: [SpeechifyVoice] {
        var voices = speechifyService.availableVoices

        // Apply search filter
        if !searchText.isEmpty {
            voices = voices.filter { voice in
                voice.name.localizedCaseInsensitiveContains(searchText) ||
                voice.language.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply language filter
        if selectedLanguage != "All" {
            voices = voices.filter { $0.language == selectedLanguage }
        }

        // Apply gender filter
        if selectedGender != "All" {
            voices = voices.filter { $0.gender == selectedGender }
        }

        return voices.sorted { $0.name < $1.name }
    }

    // MARK: - Helper Methods

    private func loadVoices() {
        Task { @MainActor in
            isLoading = true

            await speechifyService.loadVoices()

            // Extract unique languages and genders
            let languages = Set(speechifyService.availableVoices.map { $0.language }).sorted()
            let genders = Set(speechifyService.availableVoices.compactMap { $0.gender }).sorted()

            availableLanguages = ["All"] + languages
            availableGenders = ["All"] + genders

            isLoading = false
        }
    }

    private func previewVoice(_ voice: SpeechifyVoice) {
        Task {
            do {
                try await speechifyService.playText("Hello, this is a preview of this voice.", language: .english)
            } catch {
                print("Voice preview failed: \(error)")
            }
        }
    }
    
    private func languageDisplayName(for language: String) -> String {
        if language == "All" {
            return "All"
        }
        return Locale.current.localizedString(forIdentifier: language) ?? language
    }

    // MARK: - Language Filter View

    private var languageFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableLanguages, id: \.self) { language in
                    TagView(
                        title: languageDisplayName(for: language),
                        isSelected: selectedLanguage == language
                    )
                    .onTap {
                        selectedLanguage = language
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .scrollClipDisabled()
    }

    // MARK: - Supporting Views

    struct VoiceRowView: View {
        let voice: SpeechifyVoice
        let isSelected: Bool
        let onSelect: () -> Void
        let onPreview: () -> Void

        var body: some View {
            HStack(spacing: 12) {
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }

                // Voice info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(voice.name)
                            .font(.headline)
                            .fontWeight(.medium)

                        Spacer()

                        // Gender indicator
                        Text(voice.gender.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(genderColor(for: voice.gender).opacity(0.2))
                            .foregroundColor(genderColor(for: voice.gender))
                            .cornerRadius(4)
                    }

                    Text(voice.language)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(voice.voiceType.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Preview button
                Button(action: onPreview) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(vertical: 12, horizontal: 16)
            .clippedWithBackground(
                isSelected ? Color.blue.opacity(0.1) : Color(.tertiarySystemGroupedBackground),
                cornerRadius: 16
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
        }

        private func genderColor(for gender: String) -> Color {
            switch gender.lowercased() {
            case "female":
                return .pink
            case "male":
                return .blue
            default:
                return .gray
            }
        }
    }
}
