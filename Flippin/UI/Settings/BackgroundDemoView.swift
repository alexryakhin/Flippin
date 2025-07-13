import SwiftUI

struct BackgroundDemoView: View {
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = Constant.defaultColorHex
    
    var userGradientColor: Color {
        Color(hexString: userGradientColorHex) ?? .blue
    }
    
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
                                AnimatedBackground(style: style, baseColor: userGradientColor)
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
                            
                            Text("Tap to see full screen")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            // This would show the full background in a sheet
                            print("Selected: \(style.displayName)")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Background Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BackgroundDemoView()
} 
