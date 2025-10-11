//
//  NavigationManager.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import Foundation
import SwiftUI

// MARK: - Navigation Destination Enum
enum NavigationDestination: Hashable {
    case addCard
    case editCard(CardItem)
    case cardManagement
    case presetCollections
    case detailedAnalytics
    case aiCoachDetail(CoachInsight)
    case backgroundPreview
    case backgroundDemo
    case about
    case ttsDashboard
}

@MainActor
final class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var selectedTab: TabBarItem = .study
    @Published var navigationPath = NavigationPath()

    private init() {}
    
    func switchToTab(_ tab: TabBarItem) {
        selectedTab = tab
    }
    
    func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func clearNavigationPath() {
        navigationPath = NavigationPath()
    }
} 
