//
//  TagFilterView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI
import Flow

struct TagFilterView: View {
    @ObservedObject var tagManager: TagManager

    var onToSettings: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            if !tagManager.availableTags.isEmpty {
                VStack(alignment: .center, spacing: 24) {
                    Text(LocalizationKeys.availableTags.localized)
                        .font(.headline)
                        .padding(.horizontal)

                    HFlow(spacing: 8) {
                        ForEach(tagManager.availableTags, id: \.self) { tag in
                            TagButton(
                                title: tag,
                                isSelected: tagManager.currentFilterTag == tag
                            ) {
                                if tagManager.currentFilterTag == tag {
                                    tagManager.currentFilterTag = ""
                                } else {
                                    tagManager.currentFilterTag = tag
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                }
            } else {
                ContentUnavailableView {
                    VStack {
                        Image(systemName: "tag")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.init(degrees: 90))
                        Text(LocalizationKeys.noTagsAvailable.localized)
                    }
                } description: {
                    Text(LocalizationKeys.manageTagsInSettings.localized)
                } actions: {
                    Button(LocalizationKeys.toSettings.localized) {
                        onToSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
