import SwiftUI

struct BackgroundPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(UserDefaultsKey.userGradientColor) private var userGradientColorHex: String = "#4B9FF8"
    @Binding var selectedStyle: String
    
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
                        BackgroundPreviewCard(
                            style: style,
                            baseColor: userGradientColor,
                            isSelected: selectedStyle == style.rawValue
                        ) {
                            selectedStyle = style.rawValue
                        }
                    }
                }
                .padding()
            }
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
    
    var body: some View {
        VStack {
            ZStack {
                AnimatedBackground(style: style, baseColor: baseColor)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack {
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    Text(style.displayName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                }
            }
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    BackgroundPreviewView(selectedStyle: .constant(BackgroundStyle.gradient.rawValue))
} 