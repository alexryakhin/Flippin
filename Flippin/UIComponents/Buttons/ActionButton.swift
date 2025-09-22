//
//  ActionButton.swift
//  My Dictionary
//
//  Created by Alexander Riakhin on 8/9/25.
//

import SwiftUI

struct ActionButton: View {

    enum Style {
        case bordered
        case borderedProminent
    }

    @Environment(\.isEnabled) var isEnabled
    @StateObject private var colorManager = ColorManager.shared

    var text: String
    var systemImage: String?
    var style: Style
    var isLoading: Bool
    var action: VoidHandler

    init(
        _ text: String,
        systemImage: String? = nil,
        style: Style = .bordered,
        isLoading: Bool = false,
        action: @escaping VoidHandler
    ) {
        self.text = text
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            HapticService.shared.mediumImpact()
            action()
        } label: {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(font)
                        .frame(width: 20, height: 20)
                }
                Text(text)
                    .font(font)
                    .multilineTextAlignment(systemImage == nil ? .center : .leading)
            }
            .padding(vertical: 12, horizontal: 16)
            .foregroundStyle(foregroundColor)
            .opacity(isLoading ? 0 : 1)
            .frame(maxWidth: .infinity)
            .background(backgroundColor.gradient)
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
            .glassEffectIfAvailable(.regular, in: .rect(cornerRadius: 16))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isLoading)
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

    var font: Font {
        switch style {
        case .borderedProminent: .headline
        case .bordered: .subheadline
        }
    }
}
