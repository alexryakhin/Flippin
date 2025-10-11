//
//  AgeGroupSelectionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct AgeGroupSelectionStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedAgeGroup: AgeGroup?
        
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
                                        colors: [.green, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .scaleEffect(animateContent ? 1 : 0.5)
                                .opacity(animateContent ? 1 : 0)
                            
                            Image(systemName: "calendar")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.white)
                                .scaleEffect(animateContent ? 1 : 0.8)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        VStack(spacing: 16) {
                            Text(Loc.UserProfile.ageGroupTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                            
                            Text(Loc.UserProfile.ageGroupSubtitle)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .offset(y: animateContent ? 0 : 20)
                                .opacity(animateContent ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)
                    }
                    
                    Spacer()
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(AgeGroup.allCases.enumerated()), id: \.element) { index, ageGroup in
                                SelectionCard(
                                    icon: ageGroup.icon,
                                    title: ageGroup.displayName,
                                    isSelected: selectedAgeGroup == ageGroup,
                                    animateContent: animateContent,
                                    delay: 0.7 + Double(index) * 0.1
                                ) {
                                    selectedAgeGroup = ageGroup
                                    HapticService.shared.selection()
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(
                        destination: GenderSelectionStepView(onContinue: onContinue),
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
                    .disabled(selectedAgeGroup == nil)
                    .opacity(selectedAgeGroup == nil ? 0.5 : 1)
                }
                .padding(vertical: 12, horizontal: 16)
                .onAppear {
                    selectedAgeGroup = profileService.currentProfile?.ageGroup
                    withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                        animateContent = true
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
        }
        
        private func saveAndContinue() {
            guard let ageGroup = selectedAgeGroup else { return }
            profileService.updateProfile(ageGroup: ageGroup)
            HapticService.shared.buttonTapped()
        }
    }
    
    // MARK: - Selection Card Component
    
    struct SelectionCard: View {
        let icon: String
        let title: String
        let description: String?
        let isSelected: Bool
        let animateContent: Bool
        let delay: Double
        let action: () -> Void
        
        init(
            icon: String,
            title: String,
            description: String? = nil,
            isSelected: Bool,
            animateContent: Bool,
            delay: Double,
            action: @escaping () -> Void
        ) {
            self.icon = icon
            self.title = title
            self.description = description
            self.isSelected = isSelected
            self.animateContent = animateContent
            self.delay = delay
            self.action = action
        }
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .accentColor)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        if let description = description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .padding(20)
                .background(
                    isSelected
                        ? LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.clear, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? Color.clear : Color(.systemGray5),
                            lineWidth: 1
                        )
                )
                .scaleEffect(animateContent ? 1 : 0.95)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.4).delay(delay), value: animateContent)
            }
            .buttonStyle(.plain)
        }
    }
}

