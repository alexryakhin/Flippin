import SwiftUI

/**
 Main TabView for the Flippin app.
 Provides modern tab-based navigation with 5 main sections.
 */
struct MainTabView: View {

    enum Tab: Int, CaseIterable {
        case stack, list, practice, analytics, settings

        var title: String {
            switch self {
            case .stack:
                return LocalizationKeys.Navigation.stack.localized
            case .list:
                return LocalizationKeys.Navigation.list.localized
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
            case .stack:
                Image(.icCardStack)
            case .list:
                Image(systemName: "list.bullet.rectangle")
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
            case .stack:
                Image(.icCardStackFill)
            case .list:
                Image(systemName: "list.bullet.rectangle.fill")
            case .practice:
                Image(systemName: "book.fill")
            case .analytics:
                Image(systemName: "chart.bar.fill")
            case .settings:
                Image(systemName: "gearshape.fill")
            }
        }

        static let allCasesIfEmpty: [Tab] = [.stack, .practice, .analytics, .settings]
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
        ZStack {
            AnimatedBackground(style: colorManager.backgroundStyle)
            VStack {
                switch navigationManager.selectedTab {
                case .stack:
                    CardStackTab.ContentView()
                case .list:
                    MyCardsListView()
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
    }

    private var tabBarView: some View {
        HStack {
            ForEach(cardsProvider.cards.isEmpty ? Tab.allCasesIfEmpty : Tab.allCases, id: \.self) { tab in
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
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(radius: 2)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

#Preview {
    MainTabView()
}
