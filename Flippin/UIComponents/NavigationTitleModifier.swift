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

enum NavigationTitleClipMode {
    case rectangle
    case capsule
}

struct NavigationTitleModifier<TrailingContent: View, BottomContent: View>: ViewModifier {
    let title: String
    let mode: NavigationTitleMode
    let clipMode: NavigationTitleClipMode
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
                .if(clipMode == .rectangle) { view in
                    view.clippedWithPaddingAndBackgroundMaterial(.regularMaterial, showShadow: true)
                }
                .if(clipMode == .capsule) { view in
                    view.padding(vertical: 12, horizontal: 16)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .shadow(color: Color(.separator), radius: 2)
                }
                .padding(vertical: vPadding, horizontal: hPadding)
            }
    }
}

extension View {
    func navigation<TrailingContent: View, BottomContent: View>(
        title: String,
        mode: NavigationTitleMode = .large,
        clipMode: NavigationTitleClipMode = .capsule,
        vPadding: CGFloat = 12,
        hPadding: CGFloat = 12,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        @ViewBuilder bottomContent: @escaping () -> BottomContent = { EmptyView() }
    ) -> some View {
        modifier(
            NavigationTitleModifier(
                title: title,
                mode: mode,
                clipMode: clipMode,
                vPadding: vPadding,
                hPadding: hPadding,
                trailingContent: trailingContent,
                bottomContent: bottomContent
            )
        )
    }
} 
