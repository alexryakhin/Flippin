//
//  AnimatedBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct AnimatedBackground: View {

    let style: BackgroundStyle

    var body: some View {
        ZStack {
            switch style {
            case .gradient:
                GradientBackground()
            case .lavaLamp:
                LavaLampBackground()
            case .snow:
                SnowBackground()
            case .rain:
                RainBackground()
            case .stars:
                StarsBackground()
            case .bubbles:
                BubblesBackground()
            case .waves:
                WavesBackground()
            case .particles:
                ParticlesBackground()
            case .aurora:
                AuroraBackground()
            case .fireflies:
                FirefliesBackground()
            case .ocean:
                OceanBackground()
            case .galaxy:
                GalaxyBackground()
            }
        }
        .ignoresSafeArea()
    }
}
