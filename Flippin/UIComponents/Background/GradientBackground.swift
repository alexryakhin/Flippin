//
//  GradientBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: adjustedGradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Dark overlay for dark mode to ensure readability
            if shouldShowDarkOverlay {
                Color.black.opacity(0.3)
            }
        }
    }
    
    private var adjustedGradientColors: [Color] {
        let colorScheme = colorManager.colorScheme ?? self.colorScheme
        let baseColor = colorManager.userColor

        switch (colorScheme, baseColor.isLight) {
        case (.dark, true):
            // Dark mode with light color - darker, more muted
            return [baseColor.darker(by: 40).desaturated(by: 10), baseColor.darker(by: 60).desaturated(by: 15)]
        case (.dark, false):
            // Dark mode with dark color - lighter, more vibrant
            return [baseColor.lighter(by: 30).saturated(by: 20), baseColor.darker(by: 20).saturated(by: 15)]
        case (.light, true):
            // Light mode with light color - darker for visibility
            return [baseColor.darker(by: 40).saturated(by: 15), baseColor.darker(by: 60).saturated(by: 20)]
        case (.light, false):
            // Light mode with dark color - lighter for contrast
            return [baseColor.lighter(by: 30).saturated(by: 25), baseColor.darker(by: 20).saturated(by: 20)]
        default:
            return [baseColor.lighter(by: 20), baseColor.darker(by: 20)]
        }
    }
    
    private var shouldShowDarkOverlay: Bool {
        let colorScheme = colorManager.colorScheme ?? self.colorScheme
        return colorScheme == .dark
    }
}
