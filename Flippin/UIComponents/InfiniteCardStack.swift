//
//  InfiniteCardStack.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/22/25.
//

import SwiftUI

/**
 A SwiftUI view that arranges its children in an infinite, interactive deck of cards, rendering only 5 cards at a time.
 Supports right-to-left (RTL) languages with automatic gesture direction adjustment.
 */
public struct InfiniteCardStack<Data, Content>: View where Data: RandomAccessCollection, Data.Element: Identifiable & Hashable, Content: View {
    @State private var currentIndex: Double = 0.0
    @State private var previousIndex: Double = 0.0
    @State private var visibleCards: [VisibleCard] = []
    @Environment(\.layoutDirection) private var layoutDirection

    private let data: [Data.Element] // Convert to array for easier indexing
    private let cardCount: Int
    @ViewBuilder private let content: (Data.Element) -> Content
    @Binding var finalCurrentIndex: Int

    private struct VisibleCard: Identifiable {
        let id: AnyHashable
        let element: Data.Element
        let virtualIndex: Int // Tracks position in infinite sequence
    }

    /// Creates an infinite stack with the given content
    /// - Parameters:
    ///   - data: The identifiable data for computing the list.
    ///   - currentIndex: The index of the topmost card in the stack (maps to data index)
    ///   - content: A view builder that creates the view for a single card
    public init(_ data: Data, currentIndex: Binding<Int> = .constant(0), @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = Array(data)
        self.cardCount = data.count
        self.content = content
        _finalCurrentIndex = currentIndex
    }

    public var body: some View {
        Group {
            if cardCount == 0 {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(Loc.ContentViews.noCardsAvailable)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel(Loc.ContentViews.noCardsAvailable)
            } else {
                ZStack {
                    ForEach(visibleCards) { card in
                        content(card.element)
                            .zIndex(zIndex(for: card.virtualIndex))
                            .offset(x: xOffset(for: card.virtualIndex), y: 0)
                            .scaleEffect(scale(for: card.virtualIndex), anchor: .center)
                            .accessibilityLabel("Card \(modulo(Int(currentIndex), cardCount) + 1) of \(cardCount)")
                            .accessibilityAddTraits(card.virtualIndex == Int(currentIndex) ? .isSelected : [])
                    }
                }
                .highPriorityGesture(dragGesture)
                .onAppear {
                    initializeVisibleCards()
                }
                .onChange(of: data) {
                    // Reinitialize visible cards when data changes (e.g., after shuffle)
                    initializeVisibleCards()
                    // Ensure finalCurrentIndex stays within bounds
                    finalCurrentIndex = modulo(finalCurrentIndex, cardCount)
                }
            }
        }
    }

    // MARK: - Gesture Handling

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    let screenWidth = UIScreen.main.bounds.width
                    let translation = value.translation.width
                    let rtlMultiplier = layoutDirection == .rightToLeft ? -1.0 : 1.0
                    let adjustedTranslation = translation * rtlMultiplier
                    let x = (adjustedTranslation / (screenWidth * 0.5)) - previousIndex
                    self.currentIndex = -x
                }
            }
            .onEnded { value in
                snapToNearestAbsoluteIndex(value.predictedEndTranslation)
                self.previousIndex = self.currentIndex
                updateVisibleCards()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
    }

    // MARK: - Card Management

    private func initializeVisibleCards() {
        visibleCards = []
        let centerIndex = Int(currentIndex)
        // Load 5 cards: 2 before, current, 2 after
        for i in -2...2 {
            let virtualIndex = centerIndex + i
            let dataIndex = modulo(virtualIndex, cardCount)
            let element = data[dataIndex]
            visibleCards.append(VisibleCard(id: element.id, element: element, virtualIndex: virtualIndex))
        }
    }

    private func updateVisibleCards() {
        let centerIndex = Int(round(currentIndex))
        let newVisibleCards: [VisibleCard] = (-2...2).map { i in
            let virtualIndex = centerIndex + i
            let dataIndex = modulo(virtualIndex, cardCount)
            let element = data[dataIndex]
            return VisibleCard(id: element.id, element: element, virtualIndex: virtualIndex)
        }
        visibleCards = newVisibleCards
        finalCurrentIndex = modulo(centerIndex, cardCount)
    }

    private func snapToNearestAbsoluteIndex(_ predictedEndTranslation: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 40)) {
            let translation = predictedEndTranslation.width
            let screenWidth = UIScreen.main.bounds.width
            let rtlMultiplier = layoutDirection == .rightToLeft ? -1.0 : 1.0
            let adjustedTranslation = translation * rtlMultiplier
            
            if abs(adjustedTranslation) > screenWidth * 0.3 {
                if adjustedTranslation > 0 {
                    self.currentIndex = round(self.previousIndex) - 1
                } else {
                    self.currentIndex = round(self.previousIndex) + 1
                }
            } else {
                self.currentIndex = round(currentIndex)
            }
        }
    }

    // MARK: - Visual Effects

    private func zIndex(for virtualIndex: Int) -> Double {
        // Compute zIndex based on distance from currentIndex
        let distance = abs(Double(virtualIndex) - currentIndex)
        return -distance // Closer cards have higher zIndex (negative for descending order)
    }

    private func xOffset(for virtualIndex: Int) -> CGFloat {
        let topCardProgress = currentPosition(for: virtualIndex)
        let padding: CGFloat = 35.0
        let x = ((CGFloat(virtualIndex) - currentIndex) * padding)
        
        if topCardProgress > 0 && topCardProgress < 0.99 {
            return x * swingOutMultiplier(topCardProgress)
        }
        return x
    }

    private func scale(for virtualIndex: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: virtualIndex)))
    }

    private func currentPosition(for virtualIndex: Int) -> Double {
        currentIndex - Double(virtualIndex)
    }

    private func swingOutMultiplier(_ progress: Double) -> Double {
        return sin(Double.pi * progress) * 15
    }

    // MARK: - Utilities

    private func modulo(_ a: Int, _ n: Int) -> Int {
        let r = a % n
        return r >= 0 ? r : r + n
    }
}
