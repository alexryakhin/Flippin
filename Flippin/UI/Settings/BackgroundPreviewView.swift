import SwiftUI

struct BackgroundPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var colorManager = ColorManager()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                        BackgroundPreviewCard(
                            style: style,
                            baseColor: colorManager.userGradientColor,
                            isSelected: colorManager.backgroundStyle == style
                        ) {
                            colorManager.setBackgroundStyle(style)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Background Styles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BackgroundPreviewCard: View {
    let style: BackgroundStyle
    let baseColor: Color
    let isSelected: Bool
    let onTap: () -> Void

    var foreGroundColor: Color {
        guard !style.isAlwaysDark else { return .white }
        return baseColor.isLight ? .black : .white
    }

    var body: some View {
        VStack {
            ZStack {
                AnimatedBackground(style: style, baseColor: baseColor)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(foreGroundColor)
                    Text(style.displayName)
                        .font(.caption)
                        .foregroundColor(foreGroundColor)
                        .fontWeight(.medium)
                }

                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 4))
                        .foregroundStyle(.accent)
                        .overlay(alignment: .topTrailing) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.accent)
                                .font(.title3)
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(8)
                        }
                }
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
