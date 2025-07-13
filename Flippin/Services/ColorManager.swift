//
//  ColorManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

@MainActor
final class ColorManager: ObservableObject {
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = Constant.defaultColorHex // Default blue
    @AppStorage(UserDefaultsKey.backgroundStyle) private var backgroundStyleRaw: String = BackgroundStyle.gradient.rawValue

    var backgroundStyle: BackgroundStyle {
        BackgroundStyle(rawValue: backgroundStyleRaw) ?? .gradient
    }

    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }

    var adjustedTintColor: Color {
        let baseColor = userGradientColor

        switch (UITraitCollection.current.userInterfaceStyle, baseColor.isLight) {
        case (.dark, false): return userGradientColor.lighter(by: 50)
        case (.light, true): return userGradientColor.darker(by: 50)
        default: return userGradientColor
        }
    }

    var adjustedForegroundColor: Color {
        guard !backgroundStyle.isAlwaysDark else { return Color(.white) }
        switch (UITraitCollection.current.userInterfaceStyle, userGradientColor.isLight) {
        case (.light, false): return Color(.systemBackground)
        default: return Color(.label)
        }
    }

    func setUserGradientColor(_ newColor: Color) {
        userGradientColorHex = newColor.uiColor.toHexString()
    }

    func setBackgroundStyle(_ newStyle: BackgroundStyle) {
        backgroundStyleRaw = newStyle.rawValue
    }
}
