//
//  TagFilterView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI

struct TagFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var tagManager: TagManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("Show All Cards") {
                        tagManager.clearFilter()
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
                
                if !tagManager.availableTags.isEmpty {
                    Section("Available Tags") {
                        ForEach(tagManager.availableTags, id: \.self) { tag in
                            Button {
                                tagManager.currentFilterTag = tag
                                dismiss()
                            } label: {
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    if tagManager.currentFilterTag == tag {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                } else {
                    Section {
                        Text("No tags available")
                            .foregroundStyle(.secondary)
                    }
                }
            }
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
