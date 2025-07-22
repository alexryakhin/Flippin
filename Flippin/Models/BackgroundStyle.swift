import SwiftUI

enum BackgroundStyle: String, CaseIterable, Codable {
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
        switch self {
        case .gradient: return LocalizationKeys.gradient.localized
        case .lavaLamp: return LocalizationKeys.lavaLamp.localized
        case .snow: return LocalizationKeys.snow.localized
        case .rain: return LocalizationKeys.rain.localized
        case .stars: return LocalizationKeys.stars.localized
        case .bubbles: return LocalizationKeys.bubbles.localized
        case .waves: return LocalizationKeys.waves.localized
        case .particles: return LocalizationKeys.particles.localized
        case .aurora: return LocalizationKeys.aurora.localized
        case .fireflies: return LocalizationKeys.fireflies.localized
        case .ocean: return LocalizationKeys.ocean.localized
        case .galaxy: return LocalizationKeys.galaxy.localized
        }
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
