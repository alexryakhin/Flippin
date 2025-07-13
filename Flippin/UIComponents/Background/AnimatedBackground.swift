//
//  AnimatedBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct AnimatedBackground: View {
    let style: BackgroundStyle
    let baseColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            switch style {
            case .gradient:
                GradientBackground(baseColor: baseColor)
            case .lavaLamp:
                LavaLampBackground(baseColor: baseColor)
            case .snow:
                SnowBackground(baseColor: baseColor)
            case .rain:
                RainBackground(baseColor: baseColor)
            case .stars:
                StarsBackground(baseColor: baseColor)
            case .bubbles:
                BubblesBackground(baseColor: baseColor)
            case .waves:
                WavesBackground(baseColor: baseColor)
                        case .particles:
                ParticlesBackground(baseColor: baseColor)
            case .aurora:
                AuroraBackground(baseColor: baseColor)
            case .fireflies:
                FirefliesBackground(baseColor: baseColor)
            case .ocean:
                OceanBackground(baseColor: baseColor)
            case .galaxy:
                GalaxyBackground(baseColor: baseColor)
        }
        }
        .ignoresSafeArea()
    }
}
