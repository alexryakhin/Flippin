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
        HStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
        .foregroundStyle(.primary)
        .overlay(
            Capsule()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
