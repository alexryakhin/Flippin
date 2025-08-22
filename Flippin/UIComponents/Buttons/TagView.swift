//
//  TagView.swift
//  My Dictionary
//
//  Created by Alexander Riakhin on 8/13/25.
//

import SwiftUI

struct TagView: View {

    enum Size {
        case mini
        case small
        case regular
        case medium
        case large

        var hPadding: CGFloat {
            switch self {
            case .mini: 6
            case .small: 8
            case .regular: 12
            case .medium: 12
            case .large: 16
            }
        }

        var vPadding: CGFloat {
            switch self {
            case .mini: 2
            case .small: 4
            case .regular: 6
            case .medium: 8
            case .large: 12
            }
        }

        var font: Font {
            switch self {
            case .mini: .caption2
            case .small: .system(.caption, design: .rounded, weight: .medium)
            case .regular: .system(.caption, design: .rounded, weight: .medium)
            case .medium: .headline
            case .large: .system(.title2, design: .rounded, weight: .bold)
            }
        }
    }

    @Environment(\.isEnabled) var isEnabled
    @StateObject private var colorManager = ColorManager.shared

    private let title: String
    private let imageSystemName: String?
    private let isSelected: Bool
    private let isMaterialBackground: Bool
    private let size: Size

    init(
        title: String,
        imageSystemName: String? = nil,
        isSelected: Bool,
        isMaterialBackground: Bool = false,
        size: Size = .regular
    ) {
        self.title = title
        self.imageSystemName = imageSystemName
        self.isSelected = isSelected
        self.isMaterialBackground = isMaterialBackground
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            if let imageSystemName {
                Image(systemName: imageSystemName)
                    .font(size.font)
            }
            Text(title)
                .font(size.font)
        }
        .padding(.horizontal, size.hPadding)
        .padding(.vertical, size.vPadding)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor.gradient)
        .if(isMaterialBackground) {
            $0.background(.thinMaterial)
        }
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        if !isEnabled {
            return Color(.systemGray4).opacity(0.5)
        } else if isSelected {
            return colorManager.tintColor
        } else {
            return colorManager.tintColor.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        let isBlackForeground: Bool = colorManager.colorScheme == .dark && colorManager.userColor.isLight

        if !isEnabled {
            return Color.gray
        } else if isSelected {
            return isBlackForeground ? .black : .white
        } else {
            return colorManager.tintColor
        }
    }
}
