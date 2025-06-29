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
                onAddItem: addItem,
                onShuffle: shuffleCards
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
    }
    
    private func addItem() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newItem = Item(
                frontText: "Hello",
                backText: "Hola",
                frontLanguage: userLanguage,
                backLanguage: targetLanguage,
                notes: "A common greeting."
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
                .opacity(1.0 - CGFloat(abs(index - currentCardIndex)) * 0.3)
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
    
    var body: some View {
        HStack(spacing: 40) {
            MenuButton()
            ShuffleButton(onShuffle: onShuffle)
            AddButton(onAddItem: onAddItem)
        }
        .padding(.bottom, 50)
        .padding(.top, 30)
    }
}

struct MenuButton: View {
    var body: some View {
        Button(action: {
            // TODO: Implement menu functionality
        }) {
            Image(systemName: "line.3.horizontal")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}

struct ShuffleButton: View {
    let onShuffle: () -> Void
    
    var body: some View {
        Button(action: onShuffle) {
            Image(systemName: "shuffle")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}

struct AddButton: View {
    let onAddItem: () -> Void
    
    var body: some View {
        Button(action: onAddItem) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.primary)
        }
    }
}

struct CardView: View {
    let item: Item
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            CardFrontView(item: item)
                .opacity(isFlipped ? 0 : 1)
            CardBackView(item: item)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0)
                )
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
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

struct CardFrontView: View {
    let item: Item
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
            Text("Tap to see answer")
                .font(.footnote)
                .foregroundColor(.gray)
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
