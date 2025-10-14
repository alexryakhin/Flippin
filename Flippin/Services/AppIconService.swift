//
//  AppIconService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
final class AppIconService: ObservableObject {
    static let shared = AppIconService()
    
    @Published var currentIcon: AppIcon = .current
    
    private init() {
        currentIcon = AppIcon.current
    }
    
    /// Change the app icon
    func changeIcon(to icon: AppIcon) {
        icon.set()
        currentIcon = AppIcon.current
    }
    
    /// Check if alternate icons are supported
    var supportsAlternateIcons: Bool {
        return UIApplication.shared.supportsAlternateIcons
    }
}
