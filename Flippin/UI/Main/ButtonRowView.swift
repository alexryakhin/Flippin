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
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(20)
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: onFilterTags) {
                Image(systemName: "tag")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(20)
            }
            .buttonStyle(ActionButtonStyle(tintColor: isFilterActive ? .blue : Color(.label)))

            Spacer()

            Button(action: onShuffle) {
                Group {
                    if isPad {
                        Label("Shuffle", systemImage: "shuffle")
                            .padding(20)
                            .lineLimit(1)
                    } else {
                        Image(systemName: "shuffle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(20)
                    }
                }
            }
            .buttonStyle(ActionButtonStyle())

            Spacer()

            Button(action: onAddItem) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(20)
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
}
