//
//  FireflyView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct FireflyView: View {

    struct Firefly: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let brightness: Double
        let pulseSpeed: Double
    }

    let firefly: Firefly

    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.4
    
    var body: some View {
        Circle()
            .fill(.yellow)
            .frame(width: firefly.size, height: firefly.size)
            .opacity(opacity)
            .position(
                x: (firefly.x + xOffset) * UIScreen.main.bounds.width,
                y: (firefly.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                // Random movement
                let distance: CGFloat = 0.2
                let targetX = CGFloat.random(in: -distance...distance)
                let targetY = CGFloat.random(in: -distance...distance)
                
                withAnimation(.easeInOut(duration: 8 / firefly.speed).repeatForever(autoreverses: true)) {
                    xOffset = targetX
                    yOffset = targetY
                }
                
                // Pulsing brightness
                withAnimation(.easeInOut(duration: firefly.pulseSpeed).repeatForever(autoreverses: true)) {
                    opacity = firefly.brightness
                }
            }
    }
}
