//
//  WelcomeSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

enum WelcomeSheet {
    struct ContentView: View {
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.dismiss) var dismiss
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var languageManager = LanguageManager.shared
        @State private var animateContent = false

        var onContinue: () -> Void

        var body: some View {
            NavigationView {
                ZStack {
                    // Animated background
                    AnimatedWelcomeBackground()
                        .ignoresSafeArea()

                    WelcomeStepView(
                        title: LocalizationKeys.welcomeScreenTitle.localized,
                        message: LocalizationKeys.welcomeScreenMessage.localized,
                        onContinue: onContinue
                    )
                }
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
