//
//  LavaLampBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct LavaLampBackground: View {
    @StateObject private var colorManager = ColorManager.shared
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSince1970
                    let phase = time.truncatingRemainder(dividingBy: 4) / 20

                    // Create multiple lava blobs
                    for i in 0..<5 {
                        let blobPhase = phase + Double(i) * 0.2
                        let x = size.width * (0.2 + 0.6 * sin(blobPhase * 2 * .pi))
                        let y = size.height * (0.3 + 0.4 * sin(blobPhase * 4 * .pi))
                        let radius = 60 + 20 * sin(blobPhase * 3 * .pi)
                        
                        let path = Path { path in
                            path.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                        }
                        
                        let color = colorManager.userColor.opacity(0.3 + 0.2 * sin(blobPhase * 2 * .pi))
                        context.fill(path, with: .color(color))
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        adjustedLavaLampTopColor,
                        adjustedLavaLampBottomColor
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Dark overlay for dark mode
            if shouldShowDarkOverlay {
                Color.black.opacity(0.2)
            }
        }
    }
    
    private var adjustedLavaLampTopColor: Color {
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
            return baseColor.darker(by: 30)
        }
    }
    
    private var adjustedLavaLampBottomColor: Color {
        let colorScheme = colorManager.colorScheme
        let baseColor = colorManager.userColor
        
        switch (colorScheme, baseColor.isLight) {
        case (.dark, true):
            // Dark mode with light color - darker, more muted
            return baseColor.darker(by: 50).desaturated(by: 15)
        case (.dark, false):
            // Dark mode with dark color - darker, more vibrant
            return baseColor.darker(by: 20).saturated(by: 15)
        case (.light, true):
            // Light mode with light color - much darker for visibility
            return baseColor.darker(by: 70).saturated(by: 20)
        case (.light, false):
            // Light mode with dark color - darker for contrast
            return baseColor.darker(by: 20).saturated(by: 20)
        default:
            return baseColor.darker(by: 50)
        }
    }
    
    private var shouldShowDarkOverlay: Bool {
        let colorScheme = colorManager.colorScheme
        return colorScheme == .dark
    }
}
