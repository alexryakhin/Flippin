import SwiftUI

/**
 Main TabView for the Flippin app.
 Provides modern tab-based navigation with 5 main sections.
 */
struct MainTabView: View {

    enum Tab: Int, CaseIterable {
        case stack, list, study, analytics, settings

        var title: String {
            switch self {
            case .stack:
                return "Stack"
            case .list:
                return "List"
            case .study:
                return "Study"
            case .analytics:
                return "Analytics"
            case .settings:
                return "Settings"
            }
        }

        var image: Image {
            switch self {
            case .stack:
                Image(.stackCards)
            case .list:
                Image(systemName: "list.bullet")
            case .study:
                Image(systemName: "book")
            case .analytics:
                Image(systemName: "chart.bar.fill")
            case .settings:
                Image(systemName: "gearshape")
            }
        }

        static let allCasesIfEmpty: [Tab] = [.stack, .study, .analytics, .settings]
    }

    // MARK: - State Objects

    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared

    // MARK: - App Storage

    @AppStorage(UserDefaultsKey.didShowWelcomeSheet) private var didShowWelcomeSheet: Bool = false

    // MARK: - State Variables

    @State private var showWelcomeSheet = false
    @State private var selectedTab = Tab.stack
    @State private var premiumFeature: PremiumFeature?

    @Namespace private var animation

    // MARK: - Body

    var body: some View {
        ZStack {
            AnimatedBackground(style: colorManager.backgroundStyle)
            VStack {
                switch selectedTab {
                case .stack:
                    CardStackTab.ContentView()
                case .list:
                    MyCardsListView()
                case .study:
                    StudyTab.ContentView()
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
        .animation(.easeInOut, value: selectedTab)
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
                TabButton(title: tab.title, image: tab.image, isSelected: selectedTab == tab) {
                    selectedTab = tab
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
