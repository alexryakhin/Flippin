//
//  FinalFeatureRow.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/21/25.
//
import SwiftUI

extension WelcomeSheet {
    struct FinalFeatureRow: View {
        @StateObject private var colorManager: ColorManager = .shared

        let icon: String
        let text: String
        let animateContent: Bool
        let delay: Double

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(colorManager.tintColor)
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)

                Text(text)
                    .font(.body)
                    .offset(x: animateContent ? 0 : -20)
                    .opacity(animateContent ? 1 : 0)

                Spacer()
            }
            .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
        }
    }
}
