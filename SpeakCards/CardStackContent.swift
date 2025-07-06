//
//  CardStackContent.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardStackContent: View {
    let items: [CardItem]
    let currentCardIndex: Int
    @Binding var dragOffset: CGFloat
    let onCardChange: (Int) -> Void
    
    var body: some View {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
            CardView(item: item)
                .offset(
                    x: CGFloat(index - currentCardIndex) * 20 + (index == currentCardIndex ? dragOffset : 0),
                    y: CGFloat(index - currentCardIndex) * 10
                )
                .scaleEffect(1.0 - CGFloat(abs(index - currentCardIndex)) * 0.05)
                .zIndex(Double(items.count - abs(index - currentCardIndex)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.location.x - value.startLocation.x
                    dragOffset = translation
                }
                .onEnded { value in
                    handleDragEnd(value)
                }
        )
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        let translation = value.location.x - value.startLocation.x
        let threshold: CGFloat = 100
        if translation > threshold && currentCardIndex > 0 {
            onCardChange(currentCardIndex - 1)
        } else if translation < -threshold && currentCardIndex < items.count - 1 {
            onCardChange(currentCardIndex + 1)
        }
        dragOffset = 0
    }
}
