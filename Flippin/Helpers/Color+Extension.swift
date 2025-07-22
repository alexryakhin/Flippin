import SwiftUI
import UIKit

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
    
    func lighter(by percentage: CGFloat = 20.0) -> Color {
        Color(uiColor: self.uiColor.lighter(by: abs(percentage)))
    }
    func darker(by percentage: CGFloat = 20.0) -> Color {
        Color(uiColor: self.uiColor.darker(by: abs(percentage)))
    }
    
    var isLight: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate perceived brightness using the formula:
        // (0.299 * R + 0.587 * G + 0.114 * B)
        let brightness = (0.299 * red + 0.587 * green + 0.114 * blue)
        return brightness > 0.6
    }

    var contrastColor: Color {
        return isLight ? .black : .white
    }
}

extension UIColor {
    func lighter(by percentage: CGFloat = 20.0) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    func darker(by percentage: CGFloat = 20.0) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }
    private func adjust(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        let newBrightness = min(max(brightness + (percentage/100.0), 0.0), 1.0)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
} 
