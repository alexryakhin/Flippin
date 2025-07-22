import UIKit
import SwiftUI

extension UIColor {
    var swiftUIColor: Color {
        Color(uiColor: self)
    }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {

        func validated(component value: Int) -> CGFloat {
            guard value > 0 else {
                return 0
            }
            guard value < 256 else {
                return 255
            }
            return CGFloat(value) / 255.0
        }

        func validated(alphaComponent value: CGFloat) -> CGFloat {
            return max(min(value, 1.0), 0)
        }

        let redValidated = validated(component: red)
        let greenValidated = validated(component: green)
        let blueValidated = validated(component: blue)
        let alphaValidated = validated(alphaComponent: alpha)
        self.init(red: redValidated, green: greenValidated, blue: blueValidated, alpha: alphaValidated)
    }
}
