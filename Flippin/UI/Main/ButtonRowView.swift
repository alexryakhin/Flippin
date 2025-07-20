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
    @StateObject private var tagManager = TagManager.shared

    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    let isFilterActive: Bool

    var body: some View {
        HStack {
            Menu {
                Button(action: {
                    HapticService.shared.menuOpened()
                    onShowSettings()
                }) {
                    Label(LocalizationKeys.settingsLabel.localized, systemImage: "gear")
                }
                Button(action: {
                    HapticService.shared.menuOpened()
                    onShowMyCards()
                }) {
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

            Menu {
                Section {
                    Picker(LocalizationKeys.filterByFavorites.localized, selection: $tagManager.isFavoriteFilterOn) {
                        Text(LocalizationKeys.showAllCards.localized).tag(false)
                        Text(LocalizationKeys.showFavoritesOnly.localized).tag(true)
                    }
                    .pickerStyle(.menu)
                }
                if !tagManager.availableTags.isEmpty {
                    Section {
                        Picker(LocalizationKeys.filterByTag.localized, selection: $tagManager.currentFilterTag) {
                            Text(LocalizationKeys.showAllCards.localized).tag("")
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                Text(tag.name.orEmpty)
                                    .tag(tag)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            } label: {
                ActionButtonLabel(LocalizationKeys.filterByTag.localized, systemImage: "line.3.horizontal.decrease.circle")
            }
            .buttonStyle(
                ActionButtonStyle(
                    tintColor: isFilterActive
                    ? colorManager.adjustedTintColor(colorScheme)
                    : Color(.label)
                )
            )

            Spacer()

            Button(action: {
                HapticService.shared.buttonTapped()
                onShuffle()
            }) {
                ActionButtonLabel(LocalizationKeys.shuffle.localized, systemImage: "shuffle")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: {
                HapticService.shared.buttonTapped()
                onAddItem()
            }) {
                ActionButtonLabel(LocalizationKeys.addCardLabel.localized, systemImage: "plus")
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
}
