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
    
    @StateObject private var colorManager = ColorManager.shared

    // MARK: - Properties
    
    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void

    // MARK: - Body
    
    var body: some View {
        HStack {
            Spacer()

            // Menu button with settings and my cards
            Menu {
                Button {
                    HapticService.shared.menuOpened()
                    onShowSettings()
                } label: {
                    Label(LocalizationKeys.settingsLabel.localized, systemImage: "gear")
                }
                
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
    }
}
