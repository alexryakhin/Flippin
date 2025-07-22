//
//  ParticlesBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct ParticlesBackground: View {
    @StateObject private var colorManager = ColorManager.shared
    @State private var particles: [ParticleView.Particle] = []

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    colorManager.userColor.darker(by: 10),
                    colorManager.userColor.darker(by: 30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Particles
            ForEach(particles) { particle in
                ParticleView(particle: particle)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<80).map { _ in
            ParticleView.Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...8),
                speed: CGFloat.random(in: 0.5...2.0),
                opacity: Double.random(in: 0.2...0.6),
                direction: Double.random(in: 0...2 * .pi)
            )
        }
    }
}
