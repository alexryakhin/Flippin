//
//  CardStackView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardStackView: View {
    let items: [CardItem]

    var body: some View {
        ZStack {
            if items.isEmpty {
                ContentUnavailableView {
                    VStack {
                        Image(systemName: "rectangle.stack")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No cards yet")
                    }
                } description: {
                    Text("Tap the + button to add your first card")
                }
            } else {
                CardStackContent(items: items)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}
