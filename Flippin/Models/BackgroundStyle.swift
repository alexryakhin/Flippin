import SwiftUI

enum BgStyle: String, CaseIterable, Codable {
    case gradient
    case lavaLamp
    case snow
    case rain
    case stars
    case bubbles
    case waves
    case particles
    case aurora
    case fireflies
    case ocean
    case galaxy
    
    var displayName: String {
        switch self {
        case .gradient: return LocalizationKeys.BackgroundStyles.gradient.localized
        case .lavaLamp: return LocalizationKeys.BackgroundStyles.lavaLamp.localized
        case .snow: return LocalizationKeys.BackgroundStyles.snow.localized
        case .rain: return LocalizationKeys.BackgroundStyles.rain.localized
        case .stars: return LocalizationKeys.BackgroundStyles.stars.localized
        case .bubbles: return LocalizationKeys.BackgroundStyles.bubbles.localized
        case .waves: return LocalizationKeys.BackgroundStyles.waves.localized
        case .particles: return LocalizationKeys.BackgroundStyles.particles.localized
        case .aurora: return LocalizationKeys.BackgroundStyles.aurora.localized
        case .fireflies: return LocalizationKeys.BackgroundStyles.fireflies.localized
        case .ocean: return LocalizationKeys.BackgroundStyles.ocean.localized
        case .galaxy: return LocalizationKeys.BackgroundStyles.galaxy.localized
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

    var isFree: Bool {
        switch self {
        case .gradient:
            return true
        default:
            return false
        }
    }
}
