//
//  Tab.swift
//  Flippin
//
//  Created by Alexander Riakhin on 9/22/25.
//

import SwiftUI

enum TabBarItem: Int, CaseIterable {
    case study, practice, analytics, settings

    var title: String {
        switch self {
        case .study:
            return Loc.Navigation.study
        case .practice:
            return Loc.Navigation.practice
        case .analytics:
            return Loc.Navigation.analytics
        case .settings:
            return Loc.Navigation.settings
        }
    }

    var image: Image {
        switch self {
        case .study:
            Image(.icCardStack)
        case .practice:
            Image(systemName: "book")
        case .analytics:
            Image(systemName: "chart.bar")
        case .settings:
            Image(systemName: "gearshape")
        }
    }

    var imageSelected: Image {
        switch self {
        case .study:
            Image(.icCardStackFill)
        case .practice:
            Image(systemName: "book.fill")
        case .analytics:
            Image(systemName: "chart.bar.fill")
        case .settings:
            Image(systemName: "gearshape.fill")
        }
    }

    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
