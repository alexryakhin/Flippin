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
            Color.clear.background(colorManager.userColor.gradient)

            // Dark overlay for dark mode to ensure readability
            if shouldShowDarkOverlay {
                Color.black.opacity(0.4)
            }
        }
    }

    private var shouldShowDarkOverlay: Bool {
        let colorScheme = colorManager.colorScheme ?? self.colorScheme
        return colorScheme == .dark
    }
}
