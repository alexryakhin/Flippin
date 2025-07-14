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
                    Label("Settings", systemImage: "gear")
                }
                Button(action: onShowMyCards) {
                    Label {
                        Text("My Cards")
                    } icon: {
                        Image(.stackCards)
                    }
                }
            } label: {
                ActionButtonLabel("Menu", systemImage: "line.3.horizontal")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: onFilterTags) {
                ActionButtonLabel("Tag filter", systemImage: "tag")
            }
            .buttonStyle(ActionButtonStyle(tintColor: isFilterActive ? .blue : Color(.label)))

            Spacer()

            Button(action: onShuffle) {
                ActionButtonLabel("Shuffle", systemImage: "shuffle")
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: onAddItem) {
                ActionButtonLabel("Add card", systemImage: "plus")
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
}
