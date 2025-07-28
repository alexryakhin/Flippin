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
        LinearGradient(
            colors: adjustedGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var adjustedGradientColors: [Color] {
        let colorScheme = colorManager.colorScheme ?? self.colorScheme
        let baseColor = colorManager.userColor

        switch (colorScheme, baseColor.isLight) {
        case (.dark, true):
            return [baseColor.darker(by: 40), baseColor.darker(by: 60)]
        case (.dark, false):
            return [baseColor.lighter(by: 30), baseColor.darker(by: 20)]
        case (.light, true):
            return [baseColor.lighter(by: 30), baseColor.darker(by: 20)]
        case (.light, false):
            return [baseColor.lighter(by: 30), baseColor.darker(by: 20)]
        default:
            return [baseColor.lighter(by: 20), baseColor.darker(by: 20)]
        }
    }
}
