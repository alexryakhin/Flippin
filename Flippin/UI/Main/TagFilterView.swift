//
//  TagFilterView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI
import Flow

struct TagFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tagManager: TagManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Show All Cards button
                Button("Show All Cards") {
                    tagManager.clearFilter()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                if !tagManager.availableTags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Tags")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HFlow(spacing: 8) {
                            ForEach(tagManager.availableTags, id: \.self) { tag in
                                TagButton(
                                    title: tag,
                                    isSelected: tagManager.currentFilterTag == tag
                                ) {
                                    tagManager.currentFilterTag = tag
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    VStack {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No tags available")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Filter by Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .tint(.secondary)
                }
            }
        }
    }
}

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
            return Color.blue
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
            return Color.blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}
