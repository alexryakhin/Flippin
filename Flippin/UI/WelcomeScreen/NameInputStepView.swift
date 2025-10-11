//
//  NameInputStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct NameInputStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var name = ""
        
        let onContinue: () -> Void
        
        var body: some View {
            ZStack {
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        VStack(spacing: 16) {
                            Text(Loc.UserProfile.nameTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Text(Loc.UserProfile.nameSubtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        TextField(Loc.UserProfile.namePlaceholder, text: $name)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .padding(20)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .submitLabel(.continue)
                            .onSubmit {
                                if !name.isEmpty {
                                    saveAndContinue()
                                }
                            }
                            .scaleEffect(animateContent ? 1 : 0.95)
                            .opacity(animateContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.7), value: animateContent)
                    }
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: AgeGroupSelectionStepView(onContinue: onContinue),
                        label: {
                            ActionButton(
                                Loc.WelcomeScreen.continueButton,
                                style: .borderedProminent,
                                action: {}
                            )
                            .allowsHitTesting(false)
                        }
                    )
                    .simultaneousGesture(TapGesture().onEnded {
                        saveAndContinue()
                    })
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    if let existingName = profileService.currentProfile?.name {
                        name = existingName
                    }
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return }
            profileService.updateProfile(name: trimmedName)
            HapticService.shared.buttonTapped()
        }
    }
}

