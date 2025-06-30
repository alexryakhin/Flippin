//
//  ButtonRowView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct ButtonRowView: View {
    let onAddItem: () -> Void
    let onShuffle: () -> Void
    let onShowSettings: () -> Void
    let onShowMyCards: () -> Void
    
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
                    .padding()
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())

            Button(action: onShuffle) {
                Image(systemName: "shuffle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding()
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())

            Button(action: onAddItem) {
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding()
            }
            .buttonStyle(.bordered)
            .clipShape(Circle())
        }
        .padding(.vertical, 36)
    }
}
