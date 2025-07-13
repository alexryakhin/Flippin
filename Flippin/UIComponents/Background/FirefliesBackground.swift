//
//  FirefliesBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct FirefliesBackground: View {
    let baseColor: Color
    @State private var fireflies: [FireflyView.Firefly] = []

    var body: some View {
        ZStack {
            // Dark background
            LinearGradient(
                colors: [
                    Color.black,
                    baseColor.darker(by: 70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Fireflies
            ForEach(fireflies) { firefly in
                FireflyView(firefly: firefly)
            }
        }
        .onAppear {
            createFireflies()
        }
    }
    
    private func createFireflies() {
        fireflies = (0..<30).map { _ in
            FireflyView.Firefly(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.5...2.0),
                brightness: Double.random(in: 0.4...1.0),
                pulseSpeed: Double.random(in: 1...3)
            )
        }
    }
}
