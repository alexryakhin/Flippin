//
//  HeaderButton.swift
//  My Dictionary
//
//  Created by Alexander Riakhin on 8/9/25.
//

import SwiftUI

struct HeaderButton: View {

    enum Size {
        case small
        case medium
        case large

        var hPadding: CGFloat {
            switch self {
            case .small: 8
            case .medium: 10
            case .large: 12
            }
        }

        var vPadding: CGFloat {
            switch self {
            case .small: 4
            case .medium: 6
            case .large: 8
            }
        }

        var font: Font {
            switch self {
            case .small: .system(.caption, design: .rounded, weight: .medium)
            case .medium: .system(.subheadline, design: .rounded, weight: .medium)
            case .large: .system(.headline, design: .rounded, weight: .bold)
            }
        }

        var imageSize: CGFloat {
            switch self {
            case .small: 12
            case .medium: 16
            case .large: 20
            }
        }
    }

    enum Style {
        case bordered
        case borderedProminent
    }

    enum Role {
        case regular
        case destructive
    }

    @Environment(\.isEnabled) var isEnabled
    @StateObject private var colorManager = ColorManager.shared

    var text: String
    var icon: String?
    var size: Size
    var style: Style
    var role: Role
    var action: VoidHandler

    init(
        _ text: String = "",
        icon: String? = nil,
        size: Size = .medium,
        style: Style = .bordered,
        role: Role = .regular,
        action: @escaping VoidHandler
    ) {
        self.text = text
        self.icon = icon
        self.size = size
        self.style = style
        self.role = role
        self.action = action
    }

    var body: some View {
        Button {
            HapticService.shared.mediumImpact()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size.imageSize, height: size.imageSize)
                        .font(size.font)
                }
                if !text.isEmpty {
                    Text(text)
                        .font(size.font)
                }
            }
            .padding(.horizontal, size.hPadding)
            .padding(.vertical, size.vPadding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor.gradient)
            .glassEffectIfAvailable(.regular, in: .capsule)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut, value: style)
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return Color(.systemGray4).opacity(0.5)
        } else {
            switch (style, role) {
            case (.borderedProminent, .regular): return colorManager.tintColor
            case (.bordered, .regular): return colorManager.tintColor.opacity(0.2)
            case (.borderedProminent, .destructive): return .red
            case (.bordered, .destructive): return .red.opacity(0.2)
            }
        }
    }

    private var foregroundColor: Color {
        let isBlackForeground: Bool = colorManager.colorScheme == .dark && colorManager.userColor.isLight

        if !isEnabled {
            return Color.gray
        } else {
            switch (style, role) {
            case (.borderedProminent, .regular): return isBlackForeground ? .black : .white
            case (.bordered, .regular): return colorManager.tintColor
            case (.borderedProminent, .destructive): return .white
            case (.bordered, .destructive): return .red
            }
        }
    }
}
