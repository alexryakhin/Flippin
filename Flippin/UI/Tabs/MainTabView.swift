import SwiftUI

/**
 Main TabView for the Flippin app.
 Provides modern tab-based navigation with 4 main sections.
 */
struct MainTabView: View {

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
                case .ttsDashboard:
                    TTSDashboardView()
                }
            }
        }
    }

    private var tabBarView: some View {
        GlassTabBar(activeTab: $navigationManager.selectedTab)
    }
}

#Preview {
    MainTabView()
}
