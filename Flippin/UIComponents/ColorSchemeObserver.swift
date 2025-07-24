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
                guard colorManager.userColorSchemePreference == .system else { return }
                colorManager.updateColorsForColorScheme(colorScheme)
            }
            .onChange(of: colorScheme) { _, newColorScheme in
                // Update colors when color scheme changes
                guard colorManager.userColorSchemePreference == .system else { return }
                colorManager.updateColorsForColorScheme(newColorScheme)
            }
            .onChange(of: colorManager.userColorSchemePreference) { _, newColorScheme in
                if newColorScheme == .system {
                    colorManager.updateColorsForColorScheme(nil)
                }
            }
    }
}

extension View {
    /// Automatically observes color scheme changes and updates ColorManager
    func observeColorScheme() -> some View {
        modifier(ColorSchemeObserver())
    }
} 
