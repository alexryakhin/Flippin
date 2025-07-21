//
//  SettingsTagButton.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct SettingsTagButton: View {
    let title: String
    let onDelete: () -> Void
    
    var body: some View {
        Menu {
            Button(role: .destructive, action: onDelete) {
                Label(LocalizationKeys.delete.localized, systemImage: "trash")
            }
        } label: {
            Text(title)
                .font(.subheadline)
        }
        .buttonStyle(.bordered)
        .clipShape(Capsule())
    }
}
