//
//  CardStackContent.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardStackContent: View {
    let items: [CardItem]
    @State private var cards: [CardItem] = []
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, item in
                CardView(item: item)
                    .offset(
                        x: CGFloat(index) * 20 + (index == 0 ? dragOffset : 0),
                        y: CGFloat(index) * 10
                    )
                    .scaleEffect(1.0 - CGFloat(index) * 0.05)
                    .zIndex(Double(cards.count - index))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                    .gesture(
                        index == 0 ?
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    handleDragEnd(value)
                                }
                            : nil
                    )
            }
        }
        .onAppear {
            cards = items
        }
        .onChange(of: items) { newItems in
            withAnimation {
                cards = newItems
            }
        }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        let threshold: CGFloat = 100
        if abs(value.translation.width) > threshold && cards.count > 1 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                let first = cards.removeFirst()
                cards.append(first)
            }
        }
        dragOffset = 0
    }
}
