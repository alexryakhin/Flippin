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
    
    func saturated(by percentage: CGFloat = 20.0) -> Color {
        Color(uiColor: self.uiColor.saturated(by: abs(percentage)))
    }
    
    func desaturated(by percentage: CGFloat = 20.0) -> Color {
        Color(uiColor: self.uiColor.desaturated(by: abs(percentage)))
    }
    
    var isLight: Bool {
        let uiColor = UIColor(self)
        
        // Get RGB values
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Get HSV values
        var hue: CGFloat = 0, saturation: CGFloat = 0, value: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &value, alpha: &alpha)
        
        // Calculate perceived brightness (luminance)
        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        
        // More sophisticated classification based on multiple factors
        return shouldTreatAsLight(luminance: luminance, saturation: saturation, value: value, hue: hue)
    }
    
    private func shouldTreatAsLight(luminance: CGFloat, saturation: CGFloat, value: CGFloat, hue: CGFloat) -> Bool {
        // 1. Very high luminance = definitely light
        if luminance > 0.75 {
            return true
        }
        
        // 2. Very low luminance = definitely dark
        if luminance < 0.25 {
            return false
        }
        
        // 3. Medium luminance: use more sophisticated logic
        
        // High saturation colors need higher luminance to be considered "light"
        let saturationFactor = saturation > 0.8 ? 0.7 : (saturation > 0.5 ? 0.6 : 0.5)
        
        // Different hues have different perceived brightness
        let hueFactor: CGFloat
        switch hue {
        case 0.0...0.1: // Red
            hueFactor = 0.6
        case 0.1...0.2: // Orange
            hueFactor = 0.65
        case 0.2...0.3: // Yellow
            hueFactor = 0.7
        case 0.3...0.4: // Green
            hueFactor = 0.55
        case 0.4...0.5: // Cyan
            hueFactor = 0.6
        case 0.5...0.6: // Blue
            hueFactor = 0.5
        case 0.6...0.7: // Magenta
            hueFactor = 0.55
        case 0.7...1.0: // Pink/Red
            hueFactor = 0.6
        default:
            hueFactor = 0.55
        }
        
        // Combine factors for final threshold
        let threshold = max(saturationFactor, hueFactor)
        
        return luminance > threshold
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
    
    func saturated(by percentage: CGFloat = 20.0) -> UIColor {
        return self.adjustSaturation(by: abs(percentage))
    }
    
    func desaturated(by percentage: CGFloat = 20.0) -> UIColor {
        return self.adjustSaturation(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        let newBrightness = min(max(brightness + (percentage/100.0), 0.0), 1.0)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
    
    private func adjustSaturation(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        let newSaturation = min(max(saturation + (percentage/100.0), 0.0), 1.0)
        return UIColor(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
} 
