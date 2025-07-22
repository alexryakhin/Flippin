//
//  AdaptiveGradientStyleModifier.swift
//  RepsCount
//
//  Created by Aleksandr Riakhin on 3/16/25.
//

import SwiftUI

public struct AdaptiveGradientStyleModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    private let gradientStyle: GradientStyle

    public init(gradientStyle: GradientStyle) {
        self.gradientStyle = gradientStyle
    }

    public func body(content: Content) -> some View {
        let colors = gradientStyle.colors
        let gradient: LinearGradient

        gradient = LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: gradientStyle.startPoint,
            endPoint: gradientStyle.endPoint
        )

        return content.background(gradient)
    }
}

public extension View {
    @inlinable func gradientStyle(_ style: GradientStyle) -> some View {
        modifier(AdaptiveGradientStyleModifier(gradientStyle: style))
    }
}

public enum GradientStyle {
    case bottomButton
    case bottomButtonOnList

    var colors: [Color] {
        switch self {
        case .bottomButton:
            return [
                Color(.systemBackground).opacity(0),
                Color(.systemBackground),
                Color(.systemBackground)
            ]
        case .bottomButtonOnList:
            return [
                Color(.systemGroupedBackground).opacity(0),
                Color(.systemGroupedBackground),
                Color(.systemGroupedBackground)
            ]
        }
    }

    var startPoint: UnitPoint {
        switch self {
        case .bottomButton, .bottomButtonOnList:
            return .top
        }
    }

    var endPoint: UnitPoint {
        switch self {
        case .bottomButton, .bottomButtonOnList:
            return .bottom
        }
    }
}
