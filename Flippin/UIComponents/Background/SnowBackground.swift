//
//  SnowBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct SnowBackground: View {
    let baseColor: Color
    @State private var snowflakes: [SnowflakeView.Snowflake] = []

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 30),
                    baseColor.lighter(by: 10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Snowflakes
            ForEach(snowflakes) { snowflake in
                SnowflakeView(snowflake: snowflake)
            }
        }
        .onAppear {
            createSnowflakes()
        }
    }
    
    private func createSnowflakes() {
        snowflakes = (0..<50).map { _ in
            SnowflakeView.Snowflake(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.5...1.5),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.5...2.0),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
}
