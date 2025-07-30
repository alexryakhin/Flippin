//
//  NavigationManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import Foundation
import SwiftUI

@MainActor
final class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: MainTabView.Tab = .study

    private init() {}
    
    func switchToTab(_ tab: MainTabView.Tab) {
        selectedTab = tab
    }
} 
