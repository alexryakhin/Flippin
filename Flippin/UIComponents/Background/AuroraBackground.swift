//
//  AuroraBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct AuroraBackground: View {
    @StateObject private var colorManager = ColorManager.shared

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince1970
                let phase = time.truncatingRemainder(dividingBy: 60) / 15

                // Create aurora bands
                for i in 0..<6 {
                    let bandPhase = phase + Double(i) * 0.25
                    let y = size.height * (0.2 + 0.6 * sin(bandPhase * 2 * .pi))
                    let amplitude = 100.0 + 50.0 * sin(bandPhase * 3 * .pi)
                    
                    let path = Path { path in
                        path.move(to: CGPoint(x: -(size.width * 0.2), y: y))

                        for x in stride(from: 0, through: size.width * 1.2, by: 4) {
                            let waveY = y + amplitude * sin(x * 0.01 + bandPhase * 4 * .pi)
                            path.addLine(to: CGPoint(x: x, y: waveY))
                        }
                    }
                    
                    let color = colorManager.userColor.opacity(0.3 - Double(i) * 0.05)
                    context.stroke(path, with: .color(color), lineWidth: size.height * 0.1)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    adjustedAuroraBackgroundColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // Additional dark overlay for extra darkness in dark mode
            Group {
                if shouldShowExtraDarkOverlay {
                    Color.black.opacity(0.2)
                }
            }
        )
    }
    
    private var adjustedAuroraBackgroundColor: Color {
        let colorScheme = colorManager.colorScheme
        let baseColor = colorManager.userColor
        
        switch (colorScheme, baseColor.isLight) {
        case (.dark, true):
            // Dark mode with light color - darker, more muted
            return baseColor.darker(by: 60).desaturated(by: 15)
        case (.dark, false):
            // Dark mode with dark color - lighter, more vibrant
            return baseColor.lighter(by: 20).saturated(by: 25)
        case (.light, true):
            // Light mode with light color - much darker for visibility
            return baseColor.darker(by: 70).saturated(by: 20)
        case (.light, false):
            // Light mode with dark color - lighter for contrast
            return baseColor.lighter(by: 30).saturated(by: 30)
        default:
            return baseColor.darker(by: 60)
        }
    }
    
    private var shouldShowExtraDarkOverlay: Bool {
        let colorScheme = colorManager.colorScheme
        let baseColor = colorManager.userColor
        // Show extra overlay if the user color is light in dark mode
        return colorScheme == .dark && baseColor.isLight
    }
}
