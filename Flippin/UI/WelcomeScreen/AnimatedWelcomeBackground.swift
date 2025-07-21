//
//  AnimatedWelcomeBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

struct AnimatedWelcomeBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Floating particles
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: CGFloat.random(in: 4...12))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}
