//
//  WelcomeSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

enum WelcomeSheet {
    struct ContentView: View {
            @Environment(\.dismiss) var dismiss
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var languageManager = LanguageManager.shared
        @State private var animateContent = false

        var onContinue: () -> Void

        var body: some View {
            NavigationView {
                WelcomeStepView(
                    title: LocalizationKeys.Welcome.welcomeScreenTitle.localized,
                    message: LocalizationKeys.Welcome.welcomeScreenMessage.localized,
                    onContinue: onContinue
                )
                .navigationBarHidden(true)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
        }
    }
}
