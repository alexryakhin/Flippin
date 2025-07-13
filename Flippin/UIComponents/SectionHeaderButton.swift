//
//  SectionHeaderButton.swift
//  My Dictionary
//
//  Created by Aleksandr Riakhin on 3/23/25.
//

import SwiftUI

struct SectionHeaderButton: View {

    private let titleKey: LocalizedStringKey
    private let systemImage: String
    private let action: () -> Void

    init(
        _ titleKey: LocalizedStringKey,
        systemImage: String = "",
        action: @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.action = action
    }

    init(
        _ titleKey: String,
        systemImage: String = "",
        action: @escaping () -> Void
    ) {
        self.titleKey = LocalizedStringKey(titleKey)
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            if !systemImage.isEmpty {
                Label(titleKey, systemImage: systemImage)
                    .textCase(.uppercase)
                    .font(.footnote)
            } else {
                Text(titleKey)
                    .textCase(.uppercase)
                    .font(.footnote)
            }
        }
    }
}
