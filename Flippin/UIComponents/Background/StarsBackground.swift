//
//  StarsBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct StarsBackground: View {
    @State private var stars: [StarView.Star] = []

    var body: some View {
        ZStack {
            // Dark background
            Color.black
            
            // Stars
            ForEach(stars) { star in
                StarView(star: star)
            }
        }
        .onAppear {
            createStars()
        }
    }
    
    private func createStars() {
        stars = (0..<200).map { _ in
            StarView.Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                brightness: Double.random(in: 0.3...1.0),
                twinkleSpeed: Double.random(in: 1...3)
            )
        }
    }
}
