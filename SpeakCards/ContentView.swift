//
//  ContentView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @AppStorage("userLanguage") private var userLanguageRaw: String = Locale.current.language.languageCode?.identifier ?? Language.english.rawValue
    @AppStorage("targetLanguage") private var targetLanguageRaw: String = Language.spanish.rawValue
    @AppStorage("didShowWelcomeSheet") private var didShowWelcomeSheet: Bool = false
    @State private var showWelcomeSheet = false
    @State private var showSettings = false
    @State private var showMyCards = false
    @State private var showAddCardSheet = false
    
    var userLanguage: Language {
        Language(rawValue: userLanguageRaw) ?? .english
    }
    var targetLanguage: Language {
        Language(rawValue: targetLanguageRaw) ?? .spanish
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CardStackView(items: items)
            ButtonRowView(
                onAddItem: { showAddCardSheet = true },
                onShuffle: shuffleCards,
                onShowSettings: { showSettings = true },
                onShowMyCards: { showMyCards = true }
            )
        }
        .background(Color(.systemBackground))
        .onAppear {
            if !didShowWelcomeSheet {
                showWelcomeSheet = true
            }
        }
        .sheet(isPresented: $showWelcomeSheet) {
            WelcomeSheet(
                userLanguageRaw: $userLanguageRaw,
                targetLanguageRaw: $targetLanguageRaw,
                onContinue: {
                    didShowWelcomeSheet = true
                    showWelcomeSheet = false
                }
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(onClose: { showSettings = false })
        }
        .sheet(isPresented: $showMyCards) {
            MyCardsListView(onClose: { showMyCards = false })
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet(
                userLanguage: userLanguage,
                targetLanguage: targetLanguage,
                onSave: { nativeText, targetText in
                    addItem(nativeText: nativeText, targetText: targetText)
                    showAddCardSheet = false
                },
                onCancel: { showAddCardSheet = false }
            )
        }
    }
    
    private func addItem(nativeText: String, targetText: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newItem = Item(
                frontText: targetText,
                backText: nativeText,
                frontLanguage: targetLanguage,
                backLanguage: userLanguage,
                notes: nil
            )
            modelContext.insert(newItem)
        }
    }
    
    private func shuffleCards() {
        // TODO: Implement shuffle functionality
        // This would require modifying the data model or adding a shuffle mechanism
    }
}

struct CardStackView: View {
    let items: [Item]
    @State private var currentCardIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            if items.isEmpty {
                EmptyStateView()
            } else {
                CardStackContent(
                    items: items,
                    currentCardIndex: currentCardIndex,
                    dragOffset: $dragOffset,
                    onCardChange: { newIndex in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentCardIndex = newIndex
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No cards yet")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tap the + button to add your first card")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CardStackContent: View {
    let items: [Item]
    let currentCardIndex: Int
    @Binding var dragOffset: CGFloat
    let onCardChange: (Int) -> Void
    
    var body: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            CardView(item: item)
                .offset(
                    x: CGFloat(index - currentCardIndex) * 20 + (index == currentCardIndex ? dragOffset : 0),
                    y: CGFloat(index - currentCardIndex) * 10
                )
                .scaleEffect(1.0 - CGFloat(abs(index - currentCardIndex)) * 0.05)
                .zIndex(Double(items.count - abs(index - currentCardIndex)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.location.x - value.startLocation.x
                    dragOffset = translation
                }
                .onEnded { value in
                    handleDragEnd(value)
                }
        )
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        let translation = value.location.x - value.startLocation.x
        let threshold: CGFloat = 100
        if translation > threshold && currentCardIndex > 0 {
            onCardChange(currentCardIndex - 1)
        } else if translation < -threshold && currentCardIndex < items.count - 1 {
            onCardChange(currentCardIndex + 1)
        }
        dragOffset = 0
    }
}

struct ButtonRowView: View {
    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            MenuButton(onShowSettings: onShowSettings, onShowMyCards: onShowMyCards)
                .buttonStyle(.bordered)
                .clipShape(Circle())
            ShuffleButton(onShuffle: onShuffle)
                .buttonStyle(.bordered)
                .clipShape(Circle())

            AddButton(onAddItem: onAddItem)
                .buttonStyle(.bordered)
                .clipShape(Circle())

        }
        
        .padding(.bottom, 50)
        .padding(.top, 30)
    }
}

struct MenuButton: View {
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    @State private var showMenu = false
    
    var body: some View {
        Menu {
            Button(action: onShowSettings) {
                Label("Settings", systemImage: "gear")
            }
            Button(action: onShowMyCards) {
                Label("My Cards", systemImage: "rectangle.stack")
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding()
        }
    }
}

struct ShuffleButton: View {
    let onShuffle: () -> Void
    
    var body: some View {
        Button(action: onShuffle) {
            Image(systemName: "shuffle")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding()
        }
    }
}

struct AddButton: View {
    let onAddItem: () -> Void
    
    var body: some View {
        Button(action: onAddItem) {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding()
        }
    }
}

struct CardView: View {
    let item: Item
    @State private var isFlipped = false
    @State private var animationStart: Date? = nil
    @State private var animationDirection: CGFloat = 1 // 1 for forward, -1 for backward
    let animationDuration: Double = 0.5 // seconds

    var body: some View {
        TimelineView(.animation) { context in
            let now = context.date
            let start = animationStart ?? now
            let progress = min(max(now.timeIntervalSince(start) / animationDuration, 0), 1)
            let baseAngle: CGFloat = isFlipped ? 180 : 0
            let direction = animationDirection
            var animatedAngle: CGFloat {
                if animationStart != nil && progress < 1 {
                    baseAngle + direction * 180 * CGFloat(progress)
                } else {
                    isFlipped ? 180 : 0
                }
            }

            ZStack {
                if animatedAngle <= 90 {
                    CardFrontView(item: item)
                } else {
                    CardBackView(item: item)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .rotation3DEffect(.degrees(animatedAngle), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                if animationStart == nil {
                    animationDirection = isFlipped ? -1 : 1
                    animationStart = now
                }
            }
            .onChange(of: progress) { newProgress in
                if newProgress >= 1, animationStart != nil {
                    isFlipped.toggle()
                    animationStart = nil
                }
            }
        }
    }
}

struct CardFrontView: View {
    let item: Item
    @State private var isPlayingTTS = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.frontLanguage.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(item.frontText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }
            Spacer()
            HStack {
                Button(action: {
                    isPlayingTTS = true
                    Task {
                        do {
                            try await TTSPlayer.shared.play(item.frontText)
                        } catch {
                            print("TTS error: \(error)")
                        }
                        isPlayingTTS = false
                    }
                }) {
                    Image(systemName: isPlayingTTS ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(8)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                Spacer()
                Text("Show answer")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct CardBackView: View {
    let item: Item
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(item.backLanguage.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(item.backText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
            Spacer()
            Text("Tap to go back")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct WelcomeSheet: View {
    @Binding var userLanguageRaw: String
    @Binding var targetLanguageRaw: String
    var onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Welcome to SpeakCards!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .multilineTextAlignment(.center)
                    Text("SpeakCards helps you learn and practice new languages using flashcards. Select your native language and the language you want to learn.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    VStack(spacing: 20) {
                        HStack {
                            Text("My language")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("My language", selection: $userLanguageRaw) {
                                ForEach(Language.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack {
                            Text("I'm learning")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("I'm learning", selection: $targetLanguageRaw) {
                                ForEach(Language.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .navigationBarHidden(true)
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// Placeholder SettingsView
struct SettingsView: View {
    var onClose: () -> Void
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}

// Placeholder MyCardsListView
struct MyCardsListView: View {
    var onClose: () -> Void
    var body: some View {
        NavigationView {
            VStack {
                Text("My Cards List")
                    .font(.largeTitle)
                    .padding()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}

struct AddCardSheet: View {
    let userLanguage: Language
    let targetLanguage: Language
    var onSave: (String, String) -> Void
    var onCancel: () -> Void
    @State private var nativeText: String = ""
    @State private var targetText: String = ""
    @State private var isTranslating = false
    @State private var debounceTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(userLanguage.displayName)) {
                    TextField("Enter text in your language", text: $nativeText)
                        .autocapitalization(.sentences)
                        .onChange(of: nativeText) { newValue in
                            targetText = ""
                            debounceTask?.cancel()
                            guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            debounceTask = Task {
                                guard !isTranslating else { return }
                                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s debounce
                                isTranslating = true
                                if let translated = try? await TranslationService.translate(
                                    text: newValue,
                                    from: userLanguage.rawValue,
                                    to: targetLanguage.rawValue
                                ) {
                                    await MainActor.run {
                                        targetText = translated
                                    }
                                }
                                await MainActor.run {
                                    isTranslating = false
                                }
                            }
                        }
                }
                Section(header: Text(targetLanguage.displayName)) {
                    ZStack(alignment: .trailing) {
                        TextField("Enter text in target language", text: $targetText)
                            .autocapitalization(.sentences)
                        if isTranslating {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                    }
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSave(nativeText, targetText)
                        }
                    }
                    .disabled(nativeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || targetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onDisappear {
            debounceTask?.cancel()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
