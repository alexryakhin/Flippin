//
//  StarView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct StarView: View {

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let brightness: Double
        let twinkleSpeed: Double
    }

    let star: Star

    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: star.size, height: star.size)
            .opacity(opacity)
            .position(
                x: star.x * UIScreen.main.bounds.width,
                y: star.y * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.easeInOut(duration: star.twinkleSpeed).repeatForever(autoreverses: true)) {
                    opacity = star.brightness
                }
            }
    }
}
