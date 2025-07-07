//
//  CardStackView.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardStackView: View {
    let items: [CardItem]
    @State private var currentCardIndex = 0
    @State private var dragOffset: CGFloat = 0
    
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
                CardStackContent(
                    items: items,
                    currentCardIndex: currentCardIndex,
                    dragOffset: $dragOffset,
                    onCardChange: { newIndex in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentCardIndex = newIndex
                        }
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }
}
