//
//  TabButton.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//

import SwiftUI

struct TabButton: View {

    // MARK: - State Objects
    
    @StateObject private var tagManager = TagManager.shared
    @StateObject private var colorManager = ColorManager.shared

    // MARK: - Properties
    
    let title: String
    let image: Image
    let imageSelected: Image
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    // MARK: - Initialization
    
    init(
        title: String,
        image: Image,
        imageSelected: Image,
        isSelected: Bool,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.imageSelected = imageSelected
        self.isSelected = isSelected
        self.isDisabled = isDisabled && !isSelected
        self.action = action
    }

    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                (isSelected ? imageSelected : image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .foregroundStyle(foregroundColor)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // MARK: - Computed Properties
    
    private var foregroundColor: Color {
        if isDisabled {
            return Color.gray
        } else if isSelected {
            return colorManager.tintColor
        } else {
            return Color.secondary
        }
    }
}
