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
    @State private var isAnimatingCardRemoval = false
    @State private var cardToRemove: CardItem?
    @State private var isAnimatingCardAddition = false
    @State private var backCardOffset: CGFloat = 0
    @State private var backAnimationProgress: CGFloat = 0

    var body: some View {
        VStack {
            Button("Back") {
                goBack()
            }
            .disabled(cards.count <= 1 || isAnimatingCardRemoval || isAnimatingCardAddition)
            .opacity(cards.count <= 1 ? 0.5 : 1.0)

            ZStack(alignment: .bottomTrailing) {
                // Back card (slides in from the side)
                if isAnimatingCardAddition, let backCard = getBackCard() {
                    CardView(item: backCard)
                        .offset(x: backCardOffset, y: 0)
                        .scaleEffect(0.85 + (backAnimationProgress * 0.15)) // Start at 85% and grow to 100%
                        .zIndex(Double(cards.count + 1))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: backCardOffset)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: backAnimationProgress)
                }
                
                ForEach(Array(cards.enumerated().prefix(3)), id: \.element.id) { index, item in
                    CardView(item: item)
                        .offset(
                            x: offsetForIndex(index),
                            y: CGFloat(index) * 10
                        )
                        .scaleEffect(scaleForIndex(index))
                        .zIndex(Double(cards.count - index))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: backAnimationProgress)
                        .gesture(
                            index == 0 && !isAnimatingCardRemoval && !isAnimatingCardAddition ?
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
            isAnimatingCardRemoval = true
            cardToRemove = cards.first
            
            // Animate the card going off-screen
            withAnimation(.easeOut(duration: 0.2)) {
                dragOffset = value.translation.width > 0 ? 500 : -500 // Move card off-screen
            }
            
            // After the card is off-screen, remove it and reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    let first = cards.removeFirst()
                    cards.append(first)
                }
                
                // Reset states
                dragOffset = 0
                isAnimatingCardRemoval = false
                cardToRemove = nil
            }
        } else {
            // If threshold not met, just reset the drag offset
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                dragOffset = 0
            }
        }
    }
    
    private func goBack() {
        guard cards.count > 1 && !isAnimatingCardRemoval && !isAnimatingCardAddition else { return }
        
        isAnimatingCardAddition = true
        backAnimationProgress = 0
        
        // Start with the back card off-screen (to the left)
        backCardOffset = -500
        
        // Animate the back card sliding in from the left and growing
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            backCardOffset = 0
            backAnimationProgress = 1.0
        }
        
        // After the back card is in position, update the stack
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Update the stack without animation to avoid blinking
            let last = cards.removeLast()
            cards.insert(last, at: 0)
            
            // Reset states
            isAnimatingCardAddition = false
            backCardOffset = 0
            backAnimationProgress = 0
        }
    }
    
    private func getBackCard() -> CardItem? {
        // Get the card that was most recently moved to the back
        // This is the last card in the array
        return cards.last
    }
    
    // Scale cards based on their position in the stack, with reverse effect for back animation
    private func scaleForIndex(_ index: Int) -> CGFloat {
        let baseScale = 1.0 - CGFloat(index) * 0.05
        
        if isAnimatingCardAddition {
            // When going backwards, all current cards get smaller
            let reverseEffect = 1.0 - (backAnimationProgress * 0.05)
            return baseScale * reverseEffect
        } else {
            return baseScale
        }
    }
    
    private func offsetForIndex(_ index: Int) -> CGFloat {
        let baseOffset = CGFloat(index) * 20 + (index == 0 ? dragOffset : 0)
        
        if isAnimatingCardAddition {
            // When going backwards, only background cards (index >= 0) get additional offset
            if index >= 0 {
                let additionalOffset = backAnimationProgress * 10 // Additional 10 points of offset
                return baseOffset + additionalOffset
            } else {
                return baseOffset // Current card keeps its normal offset
            }
        } else {
            return baseOffset
        }
    }
}
