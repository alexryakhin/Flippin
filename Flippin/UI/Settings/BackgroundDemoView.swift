import SwiftUI

struct BackgroundDemoView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var colorManager = ColorManager()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(BackgroundStyle.allCases, id: \.self) { style in
                        VStack {
                            ZStack {
                                AnimatedBackground(style: style, baseColor: colorManager.userGradientColor)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                VStack {
                                    Image(systemName: style.icon)
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                    Text(style.displayName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Text(LocalizationKeys.tapToSeeFullScreen.localized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            // This would show the full background in a sheet
                            print("Selected: \(style.displayName)")
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizationKeys.backgroundDemo.localized)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
