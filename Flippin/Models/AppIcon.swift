//
//  AppIcon.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import SwiftUI

enum AppIcon: String, CaseIterable, Identifiable {
    case blue = "IconBlue"
    case green = "IconGreen"
    case purple = "IconPurple"
    case red = "IconRed"
    case ukraine = "IconUkraine"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .blue:
            return "Blue"
        case .green:
            return "Green"
        case .purple:
            return "Purple"
        case .red:
            return "Red"
        case .ukraine:
            return "Ukraine"
        }
    }

    var image: Image {
        switch self {
        case .blue: .init(.iconRoundedBlue)
        case .green: .init(.iconRoundedGreen)
        case .purple: .init(.iconRoundedPurple)
        case .red: .init(.iconRoundedRed)
        case .ukraine: .init(.iconRoundedUkraine)
        }
    }

    /// Get the current app icon
    static var current: AppIcon {
        guard let currentIconName = UIApplication.shared.alternateIconName else {
            return .blue
        }
        
        // Extract the icon name from the bundle name
        let iconName = currentIconName.replacingOccurrences(of: ".icon", with: "")
        return AppIcon(rawValue: iconName) ?? .blue
    }
    
    /// Set the app icon
    @MainActor
    func set() {
        guard UIApplication.shared.supportsAlternateIcons else {
            debugPrint("❌ [AppIcon] Alternate icons not supported")
            return
        }
        
        UIApplication.shared.setAlternateIconName(self == .blue ? nil : rawValue)
        debugPrint("✅ [AppIcon] Icon changed to: \(displayName)")
    }
}
