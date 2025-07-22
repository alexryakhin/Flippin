//
//  RainBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct RainBackground: View {
    @StateObject private var colorManager = ColorManager.shared
    @State private var raindrops: [RaindropView.Raindrop] = []

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    colorManager.userColor.darker(by: 20),
                    colorManager.userColor.darker(by: 40)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Raindrops
            ForEach(raindrops) { raindrop in
                RaindropView(raindrop: raindrop)
            }
        }
        .onAppear {
            createRaindrops()
        }
    }
    
    private func createRaindrops() {
        raindrops = (0..<100).map { _ in
            RaindropView.Raindrop(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.5...1.5),
                length: CGFloat.random(in: 20...60),
                speed: CGFloat.random(in: 1.0...3.0),
                opacity: Double.random(in: 0.2...0.6)
            )
        }
    }
}
