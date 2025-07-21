//
//  GalaxyBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct GalaxyBackground: View {
    let baseColor: Color
    @State private var stars: [StarView.Star] = []
    @State private var nebulae: [NebulaView.Nebula] = []

    var body: some View {
        ZStack {
            // Deep space background
            Color.black
            
            // Nebulae
            ForEach(nebulae) { nebula in
                NebulaView(nebula: nebula)
            }
            
            // Stars
            ForEach(stars) { star in
                StarView(star: star)
            }
        }
        .onAppear {
            createGalaxy()
        }
        .onChange(of: baseColor) {
            createGalaxy()
        }
    }
    
    private func createGalaxy() {
        stars = (0..<300).map { _ in
            StarView.Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...4),
                brightness: Double.random(in: 0.3...1.0),
                twinkleSpeed: Double.random(in: 1...4)
            )
        }
        
        nebulae = (0..<3).map { _ in
            NebulaView.Nebula(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 100...300),
                opacity: Double.random(in: 0.1...0.3),
                color: baseColor
            )
        }
    }
}
