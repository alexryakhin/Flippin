//
//  WelcomeSheet.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct WelcomeSheet: View {
    @Binding var userLanguageRaw: String
    @Binding var targetLanguageRaw: String
    var onContinue: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Text("Welcome to Flippin!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                        .multilineTextAlignment(.center)
                    Text("Flippin helps you learn and practice new languages using flashcards. Select your native language and the language you want to learn.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    VStack(spacing: 20) {
                        HStack {
                            Text("My language")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("My language", selection: $userLanguageRaw) {
                                ForEach(Language.allCases) { lang in
                                    Text(lang.displayName).tag(lang.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack {
                            Text("I'm learning")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker("I'm learning", selection: $targetLanguageRaw) {
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
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
