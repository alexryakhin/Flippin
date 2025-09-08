import SwiftUI

struct BackgroundDemoView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var colorManager = ColorManager.shared
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(BgStyle.allCases, id: \.self) { style in
                    VStack {
                        ZStack {
                            AnimatedBackground(style: style)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))

                            var foregroundColor: Color {
                                guard !style.isAlwaysDark else { return .white }
                                return colorManager.userColor.isLight ? .black : .white
                            }

                            VStack {
                                Image(systemName: style.icon)
                                    .font(.title2)
                                    .foregroundColor(foregroundColor)
                                Text(style.displayName)
                                    .font(.caption)
                                    .foregroundColor(foregroundColor)
                                    .fontWeight(.medium)
                            }

                            // Premium overlay for free users
                            if !purchaseService.hasPremiumAccess && !style.isFree {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.clear)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text(Loc.PremiumFeatures.premium)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(.thinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .padding(8)
                                    }
                            }
                        }
                    }
                    .onTapGesture {
                        if purchaseService.hasPremiumAccess || style.isFree {
                            // This would show the full background in a sheet
                            print("Selected: \(style.displayName)")
                        } else {
                            showPaywall = true
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigation(
            title: Loc.NavigationTitles.backgroundDemo,
            mode: .inline(withBackButton: true)
        )
        .sheet(isPresented: $showPaywall) {
            Paywall.ContentView()
        }
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
    }
}
