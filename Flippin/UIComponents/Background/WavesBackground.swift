//
//  WavesBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct WavesBackground: View {
    @StateObject private var colorManager = ColorManager.shared
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSince1970
                    let phase = time.truncatingRemainder(dividingBy: 3) / 3
                    
                    // Create multiple wave layers
                    for i in 0..<3 {
                        let wavePhase = phase + Double(i) * 0.3
                        let amplitude = 30.0 + Double(i) * 10
                        let frequency = 0.02 + Double(i) * 0.01
                        
                        let path = Path { path in
                            path.move(to: CGPoint(x: 0, y: size.height))
                            
                            for x in stride(from: 0, through: size.width, by: 2) {
                                let y = size.height * 0.7 + amplitude * sin(x * frequency + wavePhase * 2 * .pi)
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            
                            path.addLine(to: CGPoint(x: size.width, y: size.height))
                            path.closeSubpath()
                        }
                        
                        let color = adjustedWaveColor.opacity(0.2 - Double(i) * 0.05)
                        context.fill(path, with: .color(color))
                    }
                }
            }
            .background(GradientBackground())
            
            // Dark overlay for dark mode
            if shouldShowDarkOverlay {
                Color.black.opacity(0.15)
            }
        }
    }
    
    private var adjustedWaveColor: Color {
        let colorScheme = colorManager.colorScheme
        let baseColor = colorManager.userColor
        
        switch (colorScheme, baseColor.isLight) {
        case (.dark, true):
            // Dark mode with light color - darker, more muted
            return baseColor.darker(by: 30).desaturated(by: 10)
        case (.dark, false):
            // Dark mode with dark color - lighter, more vibrant
            return baseColor.lighter(by: 20).saturated(by: 20)
        case (.light, true):
            // Light mode with light color - darker for visibility
            return baseColor.darker(by: 50).saturated(by: 15)
        case (.light, false):
            // Light mode with dark color - lighter for contrast
            return baseColor.lighter(by: 20).saturated(by: 25)
        default:
            return baseColor
        }
    }
    
    private var shouldShowDarkOverlay: Bool {
        let colorScheme = colorManager.colorScheme
        return colorScheme == .dark
    }
}
