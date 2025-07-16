//
//  TagButton.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct TagButton: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(title: String, isSelected: Bool, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(backgroundColor)
                )
                .foregroundStyle(foregroundColor)
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color.gray.opacity(0.05)
        } else if isSelected {
            return Color.accentColor
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        if isDisabled {
            return Color.gray
        } else if isSelected {
            return Color.white
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
