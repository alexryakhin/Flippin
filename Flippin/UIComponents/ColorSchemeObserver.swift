//
//  ColorSchemeObserver.swift
//  Flippin
//
//  Created by Assistant on 12/19/25.
//

import SwiftUI

/// A view modifier that automatically observes color scheme changes
/// and updates the ColorManager's published properties
struct ColorSchemeObserver: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Update colors when view appears
                colorManager.updateColorsForColorScheme(colorScheme)
            }
            .onChange(of: colorScheme) { _, newColorScheme in
                // Update colors when color scheme changes
                colorManager.updateColorsForColorScheme(newColorScheme)
            }
    }
}

extension View {
    /// Automatically observes color scheme changes and updates ColorManager
    func observeColorScheme() -> some View {
        modifier(ColorSchemeObserver())
    }
} 