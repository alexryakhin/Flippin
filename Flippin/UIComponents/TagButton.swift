//
//  TagButton.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct TagButton: View {
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    let title: LocalizedStringKey
    let imageSystemName: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        imageSystemName: String = "",
        isSelected: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = LocalizedStringKey(title)
        self.imageSystemName = imageSystemName
        self.isSelected = isSelected
        self.isDisabled = isDisabled && !isSelected
        self.action = action
    }
    
    init(
        title: LocalizedStringKey,
        imageSystemName: String = "",
        isSelected: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.imageSystemName = imageSystemName
        self.isSelected = isSelected
        self.isDisabled = isDisabled && !isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if imageSystemName.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(foregroundColor)
            } else {
                Label(title, systemImage: imageSystemName)
                    .font(.subheadline)
                    .foregroundStyle(foregroundColor)
            }
        }
        .buttonStyle(.plain)
        .padding(vertical: 6, horizontal: 12)
        .background(backgroundColor)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .overlay {
            if isSelected {
                Capsule()
                    .stroke(lineWidth: .onePixel)
                    .foregroundColor(colorManager.tintColor.darker())
            }
        }
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color(.systemGray4).opacity(0.5)
        } else if isSelected {
            return colorManager.tintColor
        } else {
            return colorManager.tintColor.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        let isBlackForeground: Bool = colorManager.colorScheme == .dark && colorManager.userColor.isLight

        if isDisabled {
            return Color.gray
        } else if isSelected {
            return isBlackForeground ? .black : .white
        } else {
            return colorManager.tintColor
        }
    }
}
