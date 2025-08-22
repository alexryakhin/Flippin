import SwiftUI

/**
 Main TabView for the Flippin app.
 Provides modern tab-based navigation with 4 main sections.
 */
struct MainTabView: View {

    enum Tab: Int, CaseIterable {
        case study, practice, analytics, settings

        var title: String {
            switch self {
            case .study:
                return LocalizationKeys.Navigation.study.localized
            case .practice:
                return LocalizationKeys.Navigation.practice.localized
            case .analytics:
                return LocalizationKeys.Navigation.analytics.localized
            case .settings:
                return LocalizationKeys.Navigation.settings.localized
            }
        }

        var image: Image {
            switch self {
            case .study:
                Image(.icCardStack)
            case .practice:
                Image(systemName: "book")
            case .analytics:
                Image(systemName: "chart.bar")
            case .settings:
                Image(systemName: "gearshape")
            }
        }

        var imageSelected: Image {
            switch self {
            case .study:
                Image(.icCardStackFill)
            case .practice:
                Image(systemName: "book.fill")
            case .analytics:
                Image(systemName: "chart.bar.fill")
            case .settings:
                Image(systemName: "gearshape.fill")
            }
        }
    }

    // MARK: - State Objects

    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @StateObject private var navigationManager = NavigationManager.shared

    // MARK: - App Storage

    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    // MARK: - State Variables

    @State private var showWelcomeSheet = false
    @State private var premiumFeature: PremiumFeature?

    @Namespace private var animation

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            ZStack {
                AnimatedBackground(style: colorManager.backgroundStyle)
                VStack {
                    switch navigationManager.selectedTab {
                    case .study:
                        CardStackTab.ContentView()
                    case .practice:
                        PracticeTab.ContentView()
                    case .analytics:
                        AnalyticsTab.ContentView()
                    case .settings:
                        SettingsView()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                tabBarView
            }
            .animation(.easeInOut, value: navigationManager.selectedTab)
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .tint(colorManager.tintColor)
            .onAppear {
                if !didShowWelcomeSheet {
                    showWelcomeSheet = true
                    AnalyticsService.trackEvent(.welcomeScreenOpened)
                }
            }
            .sheet(isPresented: $showWelcomeSheet) {
                WelcomeSheet.ContentView(
                    onContinue: {
                        didShowWelcomeSheet = true
                        showWelcomeSheet = false
                    }
                )
                .interactiveDismissDisabled()
            }
            .premiumAlert(feature: $premiumFeature)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .addCard:
                    AddCardSheet()
                case .editCard(let card):
                    EditCardSheet(card: card)
                case .cardManagement:
                    MyCardsListView()
                case .presetCollections:
                    PresetCollectionsView()
                case .detailedAnalytics:
                    DetailedAnalytics.ContentView()
                case .backgroundPreview:
                    BackgroundPreviewView()
                case .backgroundDemo:
                    BackgroundDemoView()
                case .about:
                    AboutView()
                }
            }
        }
    }

    private var tabBarView: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabButton(
                    title: tab.title,
                    image: tab.image,
                    imageSelected: tab.imageSelected,
                    isSelected: navigationManager.selectedTab == tab
                ) {
                    navigationManager.selectedTab = tab
                }
            }
        }
        .padding(vertical: 12, horizontal: 16)
        .clippedWithBackgroundMaterial(.thinMaterial, cornerRadius: 32, showShadow: true)
        .padding(8)
    }
}

#Preview {
    MainTabView()
}
