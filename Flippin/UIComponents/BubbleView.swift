//
//  BubbleView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct BubbleView: View {

    struct Bubble: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let opacity: Double
    }

    let bubble: Bubble

    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .stroke(.white, lineWidth: 2)
            .frame(width: bubble.size, height: bubble.size)
            .opacity(bubble.opacity)
            .scaleEffect(scale)
            .position(
                x: bubble.x * UIScreen.main.bounds.width,
                y: (bubble.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 8 / bubble.speed).repeatForever(autoreverses: false)) {
                    yOffset = -1.5
                    scale = 1.2
                }
            }
    }
}
