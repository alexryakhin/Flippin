//
//  SnowflakeView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct SnowflakeView: View {

    struct Snowflake: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let speed: CGFloat
        let opacity: Double
    }

    let snowflake: Snowflake

    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: snowflake.size, height: snowflake.size)
            .opacity(snowflake.opacity)
            .position(
                x: snowflake.x * UIScreen.main.bounds.width,
                y: (snowflake.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.linear(duration: 10 / snowflake.speed).repeatForever(autoreverses: false)) {
                    yOffset = 1.5
                }
            }
    }
}
