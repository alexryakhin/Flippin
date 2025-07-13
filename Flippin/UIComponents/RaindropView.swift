//
//  RaindropView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct RaindropView: View {

    struct Raindrop: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let length: CGFloat
        let speed: CGFloat
        let opacity: Double
    }

    let raindrop: Raindrop

    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 1, height: raindrop.length)
            .opacity(raindrop.opacity)
            .position(
                x: raindrop.x * UIScreen.main.bounds.width,
                y: (raindrop.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.linear(duration: 2 / raindrop.speed).repeatForever(autoreverses: false)) {
                    yOffset = 1.5
                }
            }
    }
}
