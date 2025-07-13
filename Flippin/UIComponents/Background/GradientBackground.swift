//
//  GradientBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct GradientBackground: View {
    let baseColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LinearGradient(
            colors: adjustedGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var adjustedGradientColors: [Color] {
        if colorScheme == .dark && baseColor.isLight {
            return [
                baseColor.darker(by: 40),
                baseColor.darker(by: 60)
            ]
        } else {
            return [
                baseColor.lighter(by: 20),
                baseColor.darker(by: 20)
            ]
        }
    }
}
