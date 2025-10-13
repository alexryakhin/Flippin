//
//  InterestsSelectionStepView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 10/11/25.
//

import SwiftUI

extension WelcomeSheet {
    struct InterestsSelectionStepView: View {
        @StateObject private var colorManager = ColorManager.shared
        @StateObject private var profileService = UserProfileService.shared
        @State private var animateContent = false
        @State private var selectedInterests: Set<PresetModel.Category> = []

        let onContinue: () -> Void

        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(animateContent ? 1 : 0.5)
                            .opacity(animateContent ? 1 : 0)

                        Image(systemName: "star.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.white)
                            .scaleEffect(animateContent ? 1 : 0.8)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateContent)

                    VStack(spacing: 16) {
                        Text(Loc.UserProfile.interestsTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)

                        Text(Loc.UserProfile.interestsSubtitle)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .offset(y: animateContent ? 0 : 20)
                            .opacity(animateContent ? 1 : 0)
                    }
                    .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateContent)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(PresetModel.Category.allCases.enumerated()), id: \.element) { index, category in
                            InterestCard(
                                icon: category.icon,
                                title: category.displayTitle,
                                isSelected: selectedInterests.contains(category),
                                animateContent: animateContent,
                                delay: 0.7 + Double(index) * 0.05
                            ) {
                                toggleInterest(category)
                            }
                        }
                    }
                }
                .padding(vertical: 12, horizontal: 16)
            }
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                NavigationLink(
                    destination: WeeklyGoalStepView(onContinue: onContinue),
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
                .disabled(selectedInterests.isEmpty)
                .opacity(selectedInterests.isEmpty ? 0.5 : 1)
                .padding(vertical: 12, horizontal: 16)
            }
            .onAppear {
                if let interests = profileService.currentProfile?.selectedInterests {
                    selectedInterests = Set(interests)
                }
                withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                    animateContent = true
                }
            }
            .background {
                AnimatedBackground()
                    .ignoresSafeArea()
            }
            .navigationBarBackButtonHidden(false)
        }

        private func toggleInterest(_ category: PresetModel.Category) {
            if selectedInterests.contains(category) {
                selectedInterests.remove(category)
            } else {
                selectedInterests.insert(category)
            }
            HapticService.shared.selection()
        }

        private func saveAndContinue() {
            guard !selectedInterests.isEmpty else { return }
            profileService.updateProfile(interests: Array(selectedInterests))
            HapticService.shared.buttonTapped()
        }
    }

    // MARK: - Interest Card Component

    struct InterestCard: View {
        @StateObject private var colorManager: ColorManager = .shared

        let icon: String
        let title: String
        let isSelected: Bool
        let animateContent: Bool
        let delay: Double
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundStyle(isSelected ? .white : colorManager.tintColor)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal, 12)
                .background(
                    isSelected
                    ? colorManager.tintColor.gradient
                    : Color.clear.gradient
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
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .padding(8)
                    }
                }
                .scaleEffect(animateContent ? 1 : 0.9)
                .opacity(animateContent ? 1 : 0)
                .animation(.easeInOut(duration: 0.3).delay(delay), value: animateContent)
            }
            .buttonStyle(.plain)
        }
    }
}

