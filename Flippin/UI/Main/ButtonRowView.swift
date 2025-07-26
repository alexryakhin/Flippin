//
//  ButtonRowView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI

/**
 Horizontal button row with main app actions.
 Contains menu, shuffle, and add card buttons with consistent styling.
 Provides haptic feedback for all interactions.
 */
struct ButtonRowView: View {
    // MARK: - State Objects
    
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared

    @State private var showStudyModeAlert = false

    // MARK: - Properties
    
    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    let onShowStudyMode: () -> Void

    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()
            
            // Menu button with settings and my cards
            Menu {
                Section {
                    Button {
                        HapticService.shared.menuOpened()
                        onShowSettings()
                    } label: {
                        Label(LocalizationKeys.settingsLabel.localized, systemImage: "gear")
                    }
                }
                Section {
                    Button {
                        HapticService.shared.menuOpened()
                        onShowMyCards()
                    } label: {
                        Label {
                            Text(LocalizationKeys.myCards.localized)
                        } icon: {
                            Image(.stackCards)
                        }
                    }
                    Button {
                        if cardsProvider.cards.count > 4 {
                            onShowStudyMode()
                        } else {
                            showStudyModeAlert = true
                        }
                        HapticService.shared.menuOpened()
                    } label: {
                        Label("Study Mode", systemImage: "book.fill")
                    }
                }
            } label: {
                ActionButtonLabel(LocalizationKeys.menu.localized, systemImage: "line.3.horizontal")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            // Shuffle button
            Button {
                HapticService.shared.buttonTapped()
                onShuffle()
            } label: {
                ActionButtonLabel(LocalizationKeys.shuffle.localized, systemImage: "shuffle")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            // Add card button
            Button {
                HapticService.shared.buttonTapped()
                onAddItem()
            } label: {
                ActionButtonLabel(LocalizationKeys.addCardLabel.localized, systemImage: "plus")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()
        }
        .alert("Not enough cards", isPresented: $showStudyModeAlert) {
            Button("OK") { }
        } message: {
            Text("You need at least 5 cards to start study mode.")
        }
    }
}
