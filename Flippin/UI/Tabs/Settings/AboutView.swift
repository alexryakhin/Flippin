//
//  AboutView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import SwiftUI
import StoreKit
import Flow

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    @StateObject private var colorManager = ColorManager.shared
    @State private var safariURL: URL?

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
                appSupportSection
                donationSection
                legalSection
            }
            .padding(16)
            .if(isPad) { view in
                view.frame(maxWidth: 550, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background {
            AnimatedBackground(style: colorManager.backgroundStyle)
                .ignoresSafeArea()
        }
        .navigation(
            title: Loc.AboutApp.about,
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
        .safari(url: $safariURL)
        .onAppear {
            AnalyticsService.trackEvent(.aboutScreenOpened)
        }
    }

    // MARK: - App Info Section
    private var appInfoSection: some View {
        CustomSectionView(
            header: Loc.AboutApp.appInfo
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

                        Text(Loc.AboutApp.tagline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                // Version Info
                VStack(spacing: 8) {
                    Text(Loc.AboutApp.version)
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
            header: Loc.AboutApp.features
        ) {
            VStack(spacing: 12) {
                FeatureRow(
                    icon: .init(.cardStackFill),
                    title: Loc.AboutApp.smartCards,
                    description: Loc.AboutApp.smartCardsDescription
                )

                FeatureRow(
                    icon: .init(systemName: "globe"),
                    title: Loc.AboutApp.languagesTitle,
                    description: Loc.AboutApp.languagesDescription
                )

                FeatureRow(
                    icon: .init(systemName: "chart.line.uptrend.xyaxis"),
                    title: Loc.AboutApp.learningAnalytics,
                    description: Loc.AboutApp.learningAnalyticsDescription
                )

                FeatureRow(
                    icon: .init(systemName: "speaker.wave.2"),
                    title: Loc.AboutApp.tts,
                    description: Loc.AboutApp.ttsDescription
                )
            }
        }
    }

    // MARK: - App Support Section
    private var appSupportSection: some View {
        CustomSectionView(
            header: Loc.AboutApp.appSupport
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Loc.AboutApp.appSupportDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                HFlow(spacing: 12) {
                    HeaderButton(
                        Loc.AboutApp.visitWebsite,
                        icon: "network",
                        style: .borderedProminent
                    ) {
                        openWebsite()
                    }
                    HeaderButton(
                        Loc.AboutApp.contactSupport,
                        icon: "questionmark.circle.fill",
                        style: .borderedProminent
                    ) {
                        openSupport()
                    }
                    HeaderButton(
                        Loc.AboutApp.rateOnAppStore,
                        icon: "star.fill",
                        style: .borderedProminent
                    ) {
                        requestReview()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Donation Section
    private var donationSection: some View {
        CustomSectionView(
            header: Loc.AboutApp.support
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Loc.AboutApp.supportDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)

                HeaderButton(
                    Loc.AboutApp.buyMeACoffee,
                    icon: "cup.and.saucer.fill",
                    style: .borderedProminent
                ) {
                    openDonationLink()
                }

                Text(Loc.AboutApp.followSocialMedia)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8)

                HStack(spacing: 12) {
                    HeaderButton(
                        Loc.AboutApp.instagram,
                        style: .borderedProminent
                    ) {
                        openInstagram()
                    }
                    HeaderButton(
                        Loc.AboutApp.xTwitter,
                        style: .borderedProminent
                    ) {
                        openTwitter()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Legal Section
    private var legalSection: some View {
        CustomSectionView(
            header: Loc.AboutApp.legal
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HeaderButton(
                    Loc.AboutApp.privacyPolicy,
                    icon: "arrow.up.right"
                ) {
                    openPrivacyPolicy()
                }

                HeaderButton(
                    Loc.AboutApp.termsOfService,
                    icon: "arrow.up.right"
                ) {
                    openTermsOfService()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Actions
    private func openWebsite() {
        safariURL = URL(string: PrivateConstants.websiteURL)
    }

    private func openSupport() {
        safariURL = URL(string: PrivateConstants.supportURL)
    }

    private func openDonationLink() {
        safariURL = URL(string: PrivateConstants.buyMeACoffeeURL)
        AnalyticsService.trackEvent(.donationLinkOpened)
    }

    private func openInstagram() {
        safariURL = URL(string: PrivateConstants.instagramURL)
    }

    private func openTwitter() {
        safariURL = URL(string: PrivateConstants.twitterURL)
    }

    private func openPrivacyPolicy() {
        safariURL = URL(string: PrivateConstants.privacyPolicyURL)
    }

    private func openTermsOfService() {
        safariURL = URL(string: PrivateConstants.termsOfServiceURL)
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
