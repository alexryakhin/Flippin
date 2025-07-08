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

    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = "#4A90E2" // Default blue

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }

    var body: some View {
        HStack(spacing: 40) {
            Menu {
                Button(action: onShowSettings) {
                    Label("Settings", systemImage: "gear")
                }
                Button(action: onShowMyCards) {
                    Label("My Cards", systemImage: "rectangle.stack")
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(20)
                    .foregroundColor(Color(.label))
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button(action: onShuffle) {
                Label("Shuffle", systemImage: "shuffle")
                    .padding(20)
                    .foregroundColor(Color(.label))
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button(action: onAddItem) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(20)
                    .foregroundColor(Color(.label))
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.vertical, 36)
    }
}
