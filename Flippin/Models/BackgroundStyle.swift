import SwiftUI

enum BackgroundStyle: String, CaseIterable {
    case gradient = "Gradient"
    case lavaLamp = "Lava Lamp"
    case snow = "Snow"
    case rain = "Rain"
    case stars = "Stars"
    case bubbles = "Bubbles"
    case waves = "Waves"
    case particles = "Particles"
    case aurora = "Aurora"
    case fireflies = "Fireflies"
    case ocean = "Ocean"
    case galaxy = "Galaxy"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .gradient: return "paintbrush"
        case .lavaLamp: return "drop.fill"
        case .snow: return "snowflake"
        case .rain: return "cloud.rain"
        case .stars: return "sparkles"
        case .bubbles: return "circle.fill"
        case .waves: return "waveform.path"
        case .particles: return "atom"
        case .aurora: return "light.max"
        case .fireflies: return "lightbulb"
        case .ocean: return "water.waves"
        case .galaxy: return "sparkles.rectangle.stack"
        }
    }

    var isAlwaysDark: Bool {
        switch self {
        case .stars, .aurora, .fireflies, .galaxy:
            return true
        default:
            return false
        }
    }
}
