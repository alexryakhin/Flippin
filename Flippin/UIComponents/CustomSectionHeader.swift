//
//  CustomSectionHeader.swift
//  RepsCount
//
//  Created by Aleksandr Riakhin on 3/19/25.
//

import SwiftUI

struct CustomSectionHeader: View {

    @StateObject private var colorManager = ColorManager.shared

    private let text: LocalizedStringKey

    init(text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .textCase(.uppercase)
            .font(.footnote)
            .foregroundStyle(colorManager.foregroundColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
