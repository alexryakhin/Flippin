//
//  WelcomeSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct WelcomeSheet: View {
    @EnvironmentObject private var languageManager: LanguageManager
    var onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text(LocalizationKeys.welcomeScreenTitle.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .multilineTextAlignment(.center)
                    Text(LocalizationKeys.welcomeScreenMessage.localized)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    VStack(spacing: 20) {
                        HStack {
                            Text(LocalizationKeys.myLanguage.localized)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(LocalizationKeys.myLanguage.localized, selection: $languageManager.userLanguageRaw) {
                                ForEach(Language.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack {
                            Text(LocalizationKeys.imLearning.localized)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(LocalizationKeys.imLearning.localized, selection: $languageManager.targetLanguageRaw) {
                                ForEach(Language.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .navigationBarHidden(true)
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                Button(action: {
                    HapticService.shared.buttonTapped()
                    onContinue()
                }) {
                    Text(LocalizationKeys.continueButton.localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(vertical: 12, horizontal: 16)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
