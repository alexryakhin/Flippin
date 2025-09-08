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
        case .gradient: return Loc.BackgroundStyles.gradient
        case .lavaLamp: return Loc.BackgroundStyles.lavaLamp
        case .snow: return Loc.BackgroundStyles.snow
        case .rain: return Loc.BackgroundStyles.rain
        case .stars: return Loc.BackgroundStyles.stars
        case .bubbles: return Loc.BackgroundStyles.bubbles
        case .waves: return Loc.BackgroundStyles.waves
        case .particles: return Loc.BackgroundStyles.particles
        case .aurora: return Loc.BackgroundStyles.aurora
        case .fireflies: return Loc.BackgroundStyles.fireflies
        case .ocean: return Loc.BackgroundStyles.ocean
        case .galaxy: return Loc.BackgroundStyles.galaxy
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
