//
//  TagButton.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct TagButton: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(title: String, isSelected: Bool, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled && !isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(foregroundColor)
        }
        .buttonStyle(.borderedProminent)
        .tint(tintColor)
        .clipShape(Capsule())
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var tintColor: Color {
        if isDisabled {
            return Color(.systemGray4).opacity(0.5)
        } else if isSelected {
            return colorManager.adjustedTintColor(colorScheme)
        } else {
            return Color(.systemGray4).opacity(0.8)
        }
    }
    
    private var foregroundColor: Color {
        let isBlackForeground: Bool = colorScheme == .dark && colorManager.userGradientColor.isLight

        if isDisabled {
            return Color.gray
        } else if isSelected {
            return isBlackForeground ? .black : .white
        } else {
            return Color.primary
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.2)
        } else if isSelected {
            return Color.accentColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}
