import SwiftUI
import TipKit

struct PremiumPresetsTip: Tip {
    var title: Text {
        Text("Upgrade to Premium")
    }
    
    var message: Text? {
        Text("Access all preset collections and unlock unlimited language learning potential")
    }
    
    var image: Image? {
        Image(systemName: "crown.fill")
    }
    
    var actions: [Action] {
        [
            Action(id: "upgrade", title: "Upgrade Now") {
                // This will be handled by the view
            }
        ]
    }
} 