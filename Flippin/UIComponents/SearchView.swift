//
//  SearchView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/27/25.
//

import SwiftUI

public struct SearchView: View {

    @StateObject private var colorManager: ColorManager = .shared

    let placeholder: String
    @Binding public var searchText: String

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $searchText)
        }
        .padding(vertical: 8, horizontal: 8)
        .background(colorManager.tintColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
