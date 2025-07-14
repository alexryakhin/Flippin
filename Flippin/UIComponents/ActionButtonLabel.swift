//
//  ActionButtonLabel.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI

struct ActionButtonLabel: View {

    private let titleKey: LocalizedStringKey
    private let systemImageName: String

    init(
        _ titleKey: LocalizedStringKey,
        systemImage name: String
    ) {
        self.titleKey = titleKey
        self.systemImageName = name
    }

    init(
        _ titleKey: String,
        systemImage name: String
    ) {
        self.titleKey = LocalizedStringKey(titleKey)
        self.systemImageName = name
    }

    var body: some View {
        if isPad {
            Label(titleKey, systemImage: systemImageName)
                .padding(20)
                .lineLimit(1)
        } else {
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(20)
        }
    }
}
