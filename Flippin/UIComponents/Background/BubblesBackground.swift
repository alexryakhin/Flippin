//
//  BubblesBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct BubblesBackground: View {
    let baseColor: Color
    @State private var bubbles: [BubbleView.Bubble] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 40),
                    baseColor.lighter(by: 20)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Bubbles
            ForEach(bubbles) { bubble in
                BubbleView(bubble: bubble)
            }
        }
        .onAppear {
            createBubbles()
        }
    }
    
    private func createBubbles() {
        bubbles = (0..<20).map { _ in
            BubbleView.Bubble(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 20...80),
                speed: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.1...0.3)
            )
        }
    }
}
