//
//  CardStack.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/22/25.
//

import SwiftUI

/**
 A SwiftUI view that arranges its children in an interactive deck of cards.
 */
public struct CardStack<Data, Content>: View where Data: RandomAccessCollection & Hashable, Data.Element: Identifiable & Hashable, Content: View {
    @State private var currentIndex: Double = 0.0
    @State private var previousIndex: Double = 0.0

    private let data: Data
    @ViewBuilder private let content: (Data.Element) -> Content
    @Binding var finalCurrentIndex: Int

    /// Creates a stack with the given content
    /// - Parameters:
    ///   - data: The identifiable data for computing the list.
    ///   - currentIndex: The index of the topmost card in the stack
    ///   - content: A view builder that creates the view for a single card
    public init(_ data: Data, currentIndex: Binding<Int> = .constant(0), @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
        _finalCurrentIndex = currentIndex
    }

    public var body: some View {
        Group {
            if data.isEmpty {
                Text("No cards available")
                    .accessibilityLabel("No cards available")
            } else {
                ZStack {
                    ForEach(Array(data.enumerated()), id: \.element.id) { (index, element) in
                        content(element)
                            .zIndex(zIndex(for: index))
                            .offset(x: xOffset(for: index), y: 0)
                            .scaleEffect(scale(for: index), anchor: .center)
                            .accessibilityLabel("Card \(index + 1) of \(data.count)")
                            .accessibilityAddTraits(index == Int(currentIndex) ? .isSelected : [])
                    }
                }
                .highPriorityGesture(dragGesture)
                .onChange(of: data) {
                    withAnimation {
                        // Adjust indices when data changes
                        let maxIndex = Double(data.count - 1)
                        if currentIndex > maxIndex {
                            currentIndex = maxIndex
                            previousIndex = maxIndex
                            finalCurrentIndex = Int(maxIndex)
                        }
                    }
                }
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    let x = (value.translation.width / 300) - previousIndex
                    self.currentIndex = -x
                }
            }
            .onEnded { value in
                self.snapToNearestAbsoluteIndex(value.predictedEndTranslation)
                self.previousIndex = self.currentIndex
            }
    }

    private func snapToNearestAbsoluteIndex(_ predictedEndTranslation: CGSize) {
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 40)) {
            let translation = predictedEndTranslation.width
            if abs(translation) > 200 {
                if translation > 0 {
                    self.goTo(round(self.previousIndex) - 1)
                } else {
                    self.goTo(round(self.previousIndex) + 1)
                }
            } else {
                self.currentIndex = round(currentIndex)
            }
        }
    }

    private func goTo(_ index: Double) {
        let maxIndex = Double(data.count - 1)
        if index < 0 {
            self.currentIndex = 0
        } else if index > maxIndex {
            self.currentIndex = maxIndex
        } else {
            self.currentIndex = index
        }
        self.finalCurrentIndex = Int(self.currentIndex)
    }

    private func zIndex(for index: Int) -> Double {
        if (Double(index) + 0.5) < currentIndex {
            return -Double(data.count - index)
        } else {
            return Double(data.count - index)
        }
    }

    private func xOffset(for index: Int) -> CGFloat {
        let topCardProgress = currentPosition(for: index)
        let padding = 35.0
        let x = ((CGFloat(index) - currentIndex) * padding)
        if topCardProgress > 0 && topCardProgress < 0.99 && index < (data.count - 1) {
            return x * swingOutMultiplier(topCardProgress)
        }
        return x
    }

    private func scale(for index: Int) -> CGFloat {
        return 1.0 - (0.1 * abs(currentPosition(for: index)))
    }

    private func currentPosition(for index: Int) -> Double {
        currentIndex - Double(index)
    }

    private func swingOutMultiplier(_ progress: Double) -> Double {
        return sin(Double.pi * progress) * 15
    }
}
