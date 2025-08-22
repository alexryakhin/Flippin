//
//  AboutView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var colorManager = ColorManager.shared
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                appInfoSection
                featuresSection
                donationSection
                legalSection
            }
            .padding(16)
            .if(isPad) { view in
                view.frame(maxWidth: 500, alignment: .center)
                    .frame(maxWidth: .infinity)
            }
        }
        .background {
            AnimatedBackground(style: colorManager.backgroundStyle)
                .ignoresSafeArea()
        }
        .navigation(
            title: LocalizationKeys.AboutApp.about.localized,
            mode: .inline(withBackButton: true)
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .onAppear {
            AnalyticsService.trackEvent(.aboutScreenOpened)
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        CustomSectionView(
            header: LocalizationKeys.AboutApp.appInfo.localized
        ) {
            VStack(spacing: 16) {
                // App Icon and Name
                VStack(spacing: 12) {
                    Image(.iconRounded)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(spacing: 4) {
                        Text("Flippin")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(LocalizationKeys.AboutApp.tagline.localized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Version Info
                VStack(spacing: 8) {
                    Text(LocalizationKeys.AboutApp.version.localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(appVersion)
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        CustomSectionView(
            header: LocalizationKeys.AboutApp.features.localized
        ) {
            VStack(spacing: 12) {
                FeatureRow(
                    icon: .init(.icCardStackFill),
                    title: LocalizationKeys.AboutApp.smartCards.localized,
                    description: LocalizationKeys.AboutApp.smartCardsDescription.localized
                )
                
                FeatureRow(
                    icon: .init(systemName: "globe"),
                    title: LocalizationKeys.AboutApp.languagesTitle.localized,
                    description: LocalizationKeys.AboutApp.languagesDescription.localized
                )
                
                FeatureRow(
                    icon: .init(systemName: "chart.line.uptrend.xyaxis"),
                    title: LocalizationKeys.AboutApp.learningAnalytics.localized,
                    description: LocalizationKeys.AboutApp.learningAnalyticsDescription.localized
                )
                
                FeatureRow(
                    icon: .init(systemName: "speaker.wave.2"),
                    title: LocalizationKeys.AboutApp.tts.localized,
                    description: LocalizationKeys.AboutApp.ttsDescription.localized
                )
            }
        }
    }
    
    // MARK: - Donation Section
    private var donationSection: some View {
        CustomSectionView(
            header: LocalizationKeys.AboutApp.support.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationKeys.AboutApp.supportDescription.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                HeaderButton(
                    LocalizationKeys.AboutApp.buyMeACoffee.localized,
                    icon: "cup.and.saucer.fill",
                    style: .borderedProminent
                ) {
                    openDonationLink()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        CustomSectionView(
            header: LocalizationKeys.AboutApp.legal.localized
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HeaderButton(
                    LocalizationKeys.AboutApp.privacyPolicy.localized,
                    icon: "arrow.up.right"
                ) {
                    openPrivacyPolicy()
                }

                HeaderButton(
                    LocalizationKeys.AboutApp.termsOfService.localized,
                    icon: "arrow.up.right"
                ) {
                    openTermsOfService()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Actions
    private func openDonationLink() {
        if let url = URL(string: "https://buymeacoffee.com/xander1100001") {
            UIApplication.shared.open(url)
            AnalyticsService.trackEvent(.donationLinkOpened)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.flippin.app/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.flippin.app/terms-of-use") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: Image
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            icon
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AboutView()
}
