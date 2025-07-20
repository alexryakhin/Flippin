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
    let onSeePreviousCard: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    let isFilterActive: Bool

    var body: some View {
        HStack {
            Menu {
                Section {
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
                }
                Section {
                    Picker(LocalizationKeys.filterByFavorites.localized, selection: $tagManager.isFavoriteFilterOn) {
                        Text(LocalizationKeys.showAllCards.localized).tag(false)
                        Text(LocalizationKeys.showFavoritesOnly.localized).tag(true)
                    }
                    .pickerStyle(.menu)
                    if !tagManager.availableTags.isEmpty {
                        Picker(LocalizationKeys.filterByTag.localized, selection: $tagManager.selectedFilterTag) {
                            Text(LocalizationKeys.showAllCards.localized)
                                .tag(nil as Tag?)
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                Text(tag.name.orEmpty)
                                    .tag(tag)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
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
