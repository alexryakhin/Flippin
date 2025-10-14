//
//  NavigationTitleModifier.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI

enum NavigationTitleMode: Hashable {
    case inline
    case large

    var font: Font {
        switch self {
        case .inline:
            return .system(.headline, design: .rounded, weight: .semibold)
        case .large:
            return .system(.largeTitle, design: .rounded, weight: .bold)
        }
    }

    var spacing: CGFloat {
        switch self {
        case .inline:
            return 8
        case .large:
            return 12
        }
    }
}

struct NavigationTitleModifier<TrailingContent: View, BottomContent: View>: ViewModifier {

    @Environment(\.dismiss) var dismiss
    @StateObject private var colorManager: ColorManager = .shared

    let title: String
    let mode: NavigationTitleMode
    let showsBackButton: Bool
    let vPadding: CGFloat
    let hPadding: CGFloat

    @ViewBuilder let trailingContent: () -> TrailingContent
    @ViewBuilder let bottomContent: () -> BottomContent

    func body(content: Content) -> some View {
        content
            .toolbar(.hidden)
            .safeAreaBarIfAvailable(edge: .top) {
                VStack(spacing: mode.spacing) {
                    HStack(spacing: mode.spacing) {
                        if showsBackButton {
                            HeaderButton(icon: "chevron.left") {
                                dismiss()
                                HapticService.shared.buttonTapped()
                            }
                        }
                        Text(title)
                            .font(mode.font)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 6) {
                            trailingContent()
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }

                    bottomContent()
                }
                .padding(vertical: 12, horizontal: 16)
                .glassBackgroundEffectIfAvailable(
                    .tint(Color(.systemBackground).opacity(0.5)),
                    in: RoundedRectangle(cornerRadius: 32)
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .if(isGlassAvailable == false) {
                    $0
                        .clippedWithBackgroundMaterial(
                            .regular,
                            in: .rect(cornerRadius: 32)
                        )
                }
                .shadow(radius: 2)
                .padding(vertical: vPadding, horizontal: hPadding)
            }
    }
}

extension View {
    func navigation<TrailingContent: View, BottomContent: View>(
        title: String,
        mode: NavigationTitleMode = .large,
        showsBackButton: Bool = false,
        vPadding: CGFloat = 8,
        hPadding: CGFloat = 8,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() },
        @ViewBuilder bottomContent: @escaping () -> BottomContent = { EmptyView() }
    ) -> some View {
        modifier(
            NavigationTitleModifier(
                title: title,
                mode: mode,
                showsBackButton: showsBackButton,
                vPadding: vPadding,
                hPadding: hPadding,
                trailingContent: trailingContent,
                bottomContent: bottomContent
            )
        )
    }
} 
