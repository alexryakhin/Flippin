//
//  ButtonRowView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct ButtonRowView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager.shared

    let onAddItem: () -> Void
    let onSeePreviousCard: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void

    var body: some View {
        HStack {
            Menu {
                Button {
                    HapticService.shared.menuOpened()
                    onShowSettings()
                } label: {
                    Label(LocalizationKeys.settingsLabel.localized, systemImage: "gear")
                }
                .tint(colorManager.adjustedTintColor(colorScheme))
                Button {
                    HapticService.shared.menuOpened()
                    onShowMyCards()
                } label: {
                    Label {
                        Text(LocalizationKeys.myCards.localized)
                    } icon: {
                        Image(.stackCardsRotated)
                    }
                }
                .tint(colorManager.adjustedTintColor(colorScheme))
            } label: {
                ActionButtonLabel(LocalizationKeys.menu.localized, systemImage: "line.3.horizontal")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button {
                HapticService.shared.buttonTapped()
                onShuffle()
            } label: {
                ActionButtonLabel(LocalizationKeys.shuffle.localized, systemImage: "shuffle")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button {
                HapticService.shared.buttonTapped()
                onSeePreviousCard()
            } label: {
                ActionButtonLabel(LocalizationKeys.tapToGoBack.localized, systemImage: "arrowshape.turn.up.backward.fill")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button {
                HapticService.shared.buttonTapped()
                onAddItem()
            } label: {
                ActionButtonLabel(LocalizationKeys.addCardLabel.localized, systemImage: "plus")
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
}
