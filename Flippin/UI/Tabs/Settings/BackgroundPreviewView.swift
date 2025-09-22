import SwiftUI

struct BackgroundPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var colorManager = ColorManager.shared

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(BgStyle.allCases, id: \.self) { style in
                    BackgroundPreviewCard(
                        style: style,
                        isSelected: colorManager.backgroundStyle == style
                    ) {
                        colorManager.backgroundStyle = style
                        AnalyticsService.trackSettingsEvent(.backgroundStyleChanged, newValue: style.rawValue)
                    }
                }
            }
            .padding(16)
        }
        .groupedBackground()
        .navigation(
            title: Loc.NavigationTitles.backgroundStyles,
            mode: .inline,
            showsBackButton: true
        )
        .ifLet(colorManager.colorScheme) { view, scheme in
            view.colorScheme(scheme)
        }
    }
}

struct BackgroundPreviewCard: View {
    @StateObject private var colorManager = ColorManager.shared

    let style: BgStyle
    let isSelected: Bool
    let onTap: () -> Void

    var foregroundColor: Color {
        guard !style.isAlwaysDark else { return .white }
        return colorManager.userColor.isLight ? .black : .white
    }

    var body: some View {
        VStack {
            ZStack {
                AnimatedBackground(style: style)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(foregroundColor)
                    Text(style.displayName)
                        .font(.caption)
                        .foregroundColor(foregroundColor)
                        .fontWeight(.medium)
                }

                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 4))
                        .foregroundStyle(colorManager.tintColor)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(colorManager.tintColor)
                                .font(.title3)
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(8)
                        }
                }
            }
        }
        .onTapGesture {
            HapticService.shared.settingChanged()
            onTap()
        }
    }
}
