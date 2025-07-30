//
//  NavigationTitleModifier.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI

enum NavigationTitleMode {
    case inline
    case large
}

struct NavigationTitleModifier<TrailingContent: View, BottomContent: View>: ViewModifier {
    let title: String
    let mode: NavigationTitleMode
    let vPadding: CGFloat
    let hPadding: CGFloat

    @ViewBuilder let trailingContent: () -> TrailingContent
    @ViewBuilder let bottomContent: () -> BottomContent

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                VStack(spacing: mode == .large ? 12 : 8) {
                    HStack(spacing: 2) {
                        Text(title)
                            .font(mode == .inline ? .headline : .largeTitle)
                            .bold()
                            .foregroundStyle(.secondary)

                        Spacer()

                        trailingContent()
                    }

                    bottomContent()
                }
                .clippedWithPaddingAndBackgroundMaterial(.regularMaterial, showShadow: true)
                .padding(vertical: vPadding, horizontal: hPadding)
            }
    }
}

extension View {
    func navigation<TrailingContent: View, BottomContent: View>(
        title: String,
        mode: NavigationTitleMode = .large,
        vPadding: CGFloat = 8,
        hPadding: CGFloat = 8,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        @ViewBuilder bottomContent: @escaping () -> BottomContent = { EmptyView() }
    ) -> some View {
        modifier(
            NavigationTitleModifier(
                title: title,
                mode: mode,
                vPadding: vPadding,
                hPadding: hPadding,
                trailingContent: trailingContent,
                bottomContent: bottomContent
            )
        )
    }
} 
