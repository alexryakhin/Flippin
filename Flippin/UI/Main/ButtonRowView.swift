//
//  ButtonRowView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct ButtonRowView: View {
    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    let onFilterTags: () -> Void
    let isFilterActive: Bool

    var body: some View {
        HStack {
            Menu {
                Button(action: onShowSettings) {
                    Label(LocalizationKeys.settingsLabel.localized, systemImage: "gear")
                }
                Button(action: onShowMyCards) {
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

            Button(action: onFilterTags) {
                ActionButtonLabel(LocalizationKeys.tagFilter.localized, systemImage: "tag")
            }
            .buttonStyle(ActionButtonStyle(tintColor: isFilterActive ? .blue : Color(.label)))

            Spacer()

            Button(action: onShuffle) {
                ActionButtonLabel(LocalizationKeys.shuffle.localized, systemImage: "shuffle")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: onAddItem) {
                ActionButtonLabel(LocalizationKeys.addCardLabel.localized, systemImage: "plus")
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
}
