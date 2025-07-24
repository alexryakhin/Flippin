//
//  ColorScheme.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/24/25.
//

import SwiftUI

enum ColorSchemeInternal: String, Codable, CaseIterable {
    case light
    case dark
    case system

    var systemColorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }

    var localizedName: String {
        switch self {
        case .dark: return LocalizationKeys.colorSchemeDark.localized
        case .light: return LocalizationKeys.colorSchemeLight.localized
        case .system: return LocalizationKeys.colorSchemeSystem.localized
        }
    }
}
