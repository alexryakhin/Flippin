//
//  HeaderButtonMenu.swift
//  My Dictionary
//
//  Created by Alexander Riakhin on 8/9/25.
//

import SwiftUI

struct HeaderButtonMenu<Content: View>: View {

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

    @Environment(\.isEnabled) var isEnabled
    @StateObject private var colorManager = ColorManager.shared

    var text: String
    var icon: String?
    var size: Size
    var style: Style
    var content: () -> Content

    init(
        _ text: String = "",
        icon: String? = nil,
        size: Size = .medium,
        style: Style = .bordered,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.text = text
        self.icon = icon
        self.size = size
        self.style = style
        self.content = content
    }

    var body: some View {
        Menu {
            content()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(size.font)
                        .frame(width: size.imageSize, height: size.imageSize)
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
        }
        .clipShape(Capsule())
        .buttonStyle(.plain)
        .animation(.easeInOut, value: style)
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return Color(.systemGray4).opacity(0.5)
        } else {
            switch style {
            case .borderedProminent: return colorManager.tintColor
            case .bordered: return colorManager.tintColor.opacity(0.2)
            }
        }
    }

    private var foregroundColor: Color {
        let isBlackForeground: Bool = colorManager.colorScheme == .dark && colorManager.userColor.isLight

        if !isEnabled {
            return Color.gray
        } else {
            switch style {
            case .borderedProminent: return isBlackForeground ? .black : .white
            case .bordered: return colorManager.tintColor
            }
        }
    }
}
