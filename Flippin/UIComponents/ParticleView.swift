//
//  ParticleView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct ParticleView: View {

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let opacity: Double
        let direction: Double
    }

    let particle: Particle

    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: particle.size, height: particle.size)
            .opacity(particle.opacity)
            .position(
                x: (particle.x + xOffset) * UIScreen.main.bounds.width,
                y: (particle.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                let distance: CGFloat = 0.3
                let targetX = cos(particle.direction) * distance
                let targetY = sin(particle.direction) * distance
                
                withAnimation(.linear(duration: 5 / particle.speed).repeatForever(autoreverses: true)) {
                    xOffset = targetX
                    yOffset = targetY
                }
            }
    }
}
