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
        if #available(iOS 26, *) {
            nativeTabBarContent
        } else {
            tabBarImitationContent
        }
    }
    
    // MARK: - Native TabBar Content (iOS 26+)
    
    @available(iOS 26, *)
    private var nativeTabBarContent: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            TabView(selection: $navigationManager.selectedTab) {
                CardStackTab.ContentView()
                    .tabItem {
                        TabBarItem.study.image
                        Text(TabBarItem.study.title)
                    }
                    .tag(TabBarItem.study)

                PracticeTab.ContentView()
                    .tabItem {
                        TabBarItem.practice.image
                        Text(TabBarItem.practice.title)
                    }
                    .tag(TabBarItem.practice)

                AnalyticsTab.ContentView()
                    .tabItem {
                        TabBarItem.analytics.image
                        Text(TabBarItem.analytics.title)
                    }
                    .tag(TabBarItem.analytics)

                SettingsView()
                    .tabItem {
                        TabBarItem.settings.image
                        Text(TabBarItem.settings.title)
                    }
                    .tag(TabBarItem.settings)
            }
            .tint(colorManager.tintColor)
            .ifLet(colorManager.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
            .environment(\.horizontalSizeClass, .compact)
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
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
        }
    }
    
    // MARK: - TabBar Imitation (iOS 18 and below)

    private var tabBarImitationContent: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            ZStack {
                Color.clear
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
                .animation(.easeInOut, value: navigationManager.selectedTab)
            }
            .safeAreaBarIfAvailable {
                tabBarView
                    .padding(.bottom, 8)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .ignoresSafeArea()
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
    }

    private var tabBarView: some View {
        GlassTabBar(activeTab: $navigationManager.selectedTab)
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
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
        case .aiCoachDetail:
            AICoachDetailView()
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

#Preview {
    MainTabView()
}
