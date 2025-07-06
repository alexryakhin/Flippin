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
    @Query(sort: \CardItem.timestamp) private var items: [CardItem]

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
            SettingsView()
        }
        .sheet(isPresented: $showMyCards) {
            MyCardsListView()
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddCardSheet(
                userLanguage: userLanguage,
                targetLanguage: targetLanguage,
                onSave: { nativeText, targetText in
                    addItem(nativeText: nativeText, targetText: targetText)
                    showAddCardSheet = false
                }
            )
        }
    }
    
    private func addItem(nativeText: String, targetText: String) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newItem = CardItem(
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
