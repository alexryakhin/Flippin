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

struct AnimatedBackground: View {
    let style: BackgroundStyle
    let baseColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            switch style {
            case .gradient:
                GradientBackground(baseColor: baseColor)
            case .lavaLamp:
                LavaLampBackground(baseColor: baseColor)
            case .snow:
                SnowBackground(baseColor: baseColor)
            case .rain:
                RainBackground(baseColor: baseColor)
            case .stars:
                StarsBackground(baseColor: baseColor)
            case .bubbles:
                BubblesBackground(baseColor: baseColor)
            case .waves:
                WavesBackground(baseColor: baseColor)
                        case .particles:
                ParticlesBackground(baseColor: baseColor)
            case .aurora:
                AuroraBackground(baseColor: baseColor)
            case .fireflies:
                FirefliesBackground(baseColor: baseColor)
            case .ocean:
                OceanBackground(baseColor: baseColor)
            case .galaxy:
                GalaxyBackground(baseColor: baseColor)
        }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Individual Background Implementations

struct GradientBackground: View {
    let baseColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        LinearGradient(
            colors: adjustedGradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var adjustedGradientColors: [Color] {
        if colorScheme == .dark && baseColor.isLight {
            return [
                baseColor.darker(by: 40),
                baseColor.darker(by: 60)
            ]
        } else {
            return [
                baseColor.lighter(by: 20),
                baseColor.darker(by: 20)
            ]
        }
    }
}

struct LavaLampBackground: View {
    let baseColor: Color
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince1970
                let phase = time.truncatingRemainder(dividingBy: 4) / 20

                // Create multiple lava blobs
                for i in 0..<5 {
                    let blobPhase = phase + Double(i) * 0.2
                    let x = size.width * (0.2 + 0.6 * sin(blobPhase * 2 * .pi))
                    let y = size.height * (0.3 + 0.4 * sin(blobPhase * 4 * .pi))
                    let radius = 60 + 20 * sin(blobPhase * 3 * .pi)
                    
                    let path = Path { path in
                        path.addEllipse(in: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
                    }
                    
                    let color = baseColor.opacity(0.3 + 0.2 * sin(blobPhase * 2 * .pi))
                    context.fill(path, with: .color(color))
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    baseColor.darker(by: 30),
                    baseColor.darker(by: 50)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct SnowBackground: View {
    let baseColor: Color
    @State private var snowflakes: [Snowflake] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 30),
                    baseColor.lighter(by: 10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Snowflakes
            ForEach(snowflakes) { snowflake in
                SnowflakeView(snowflake: snowflake)
            }
        }
        .onAppear {
            createSnowflakes()
        }
    }
    
    private func createSnowflakes() {
        snowflakes = (0..<50).map { _ in
            Snowflake(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.5...1.5),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.5...2.0),
                opacity: Double.random(in: 0.3...0.8)
            )
        }
    }
}

struct RainBackground: View {
    let baseColor: Color
    @State private var raindrops: [Raindrop] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.darker(by: 20),
                    baseColor.darker(by: 40)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Raindrops
            ForEach(raindrops) { raindrop in
                RaindropView(raindrop: raindrop)
            }
        }
        .onAppear {
            createRaindrops()
        }
    }
    
    private func createRaindrops() {
        raindrops = (0..<100).map { _ in
            Raindrop(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.5...1.5),
                length: CGFloat.random(in: 20...60),
                speed: CGFloat.random(in: 1.0...3.0),
                opacity: Double.random(in: 0.2...0.6)
            )
        }
    }
}

struct StarsBackground: View {
    let baseColor: Color
    @State private var stars: [Star] = []
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
            
            // Stars
            ForEach(stars) { star in
                StarView(star: star)
            }
        }
        .onAppear {
            createStars()
        }
    }
    
    private func createStars() {
        stars = (0..<200).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                brightness: Double.random(in: 0.3...1.0),
                twinkleSpeed: Double.random(in: 1...3)
            )
        }
    }
}

struct BubblesBackground: View {
    let baseColor: Color
    @State private var bubbles: [Bubble] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 40),
                    baseColor.lighter(by: 20)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Bubbles
            ForEach(bubbles) { bubble in
                BubbleView(bubble: bubble)
            }
        }
        .onAppear {
            createBubbles()
        }
    }
    
    private func createBubbles() {
        bubbles = (0..<20).map { _ in
            Bubble(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 20...80),
                speed: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.1...0.3)
            )
        }
    }
}

struct WavesBackground: View {
    let baseColor: Color
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince1970
                let phase = time.truncatingRemainder(dividingBy: 3) / 3
                
                // Create multiple wave layers
                for i in 0..<3 {
                    let wavePhase = phase + Double(i) * 0.3
                    let amplitude = 30.0 + Double(i) * 10
                    let frequency = 0.02 + Double(i) * 0.01
                    
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: size.height))
                        
                        for x in stride(from: 0, through: size.width, by: 2) {
                            let y = size.height * 0.7 + amplitude * sin(x * frequency + wavePhase * 2 * .pi)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.closeSubpath()
                    }
                    
                    let color = baseColor.opacity(0.2 - Double(i) * 0.05)
                    context.fill(path, with: .color(color))
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 20),
                    baseColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct ParticlesBackground: View {
    let baseColor: Color
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    baseColor.darker(by: 10),
                    baseColor.darker(by: 30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Particles
            ForEach(particles) { particle in
                ParticleView(particle: particle)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<80).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...8),
                speed: CGFloat.random(in: 0.5...2.0),
                opacity: Double.random(in: 0.2...0.6),
                direction: Double.random(in: 0...2 * .pi)
            )
        }
    }
}

// MARK: - Supporting Views and Models

struct Snowflake: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let opacity: Double
}

struct SnowflakeView: View {
    let snowflake: Snowflake
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: snowflake.size, height: snowflake.size)
            .opacity(snowflake.opacity)
            .position(
                x: snowflake.x * UIScreen.main.bounds.width,
                y: (snowflake.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.linear(duration: 10 / snowflake.speed).repeatForever(autoreverses: false)) {
                    yOffset = 1.5
                }
            }
    }
}

struct Raindrop: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let length: CGFloat
    let speed: CGFloat
    let opacity: Double
}

struct RaindropView: View {
    let raindrop: Raindrop
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .frame(width: 1, height: raindrop.length)
            .opacity(raindrop.opacity)
            .position(
                x: raindrop.x * UIScreen.main.bounds.width,
                y: (raindrop.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.linear(duration: 2 / raindrop.speed).repeatForever(autoreverses: false)) {
                    yOffset = 1.5
                }
            }
    }
}

struct Star: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let brightness: Double
    let twinkleSpeed: Double
}

struct StarView: View {
    let star: Star
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: star.size, height: star.size)
            .opacity(opacity)
            .position(
                x: star.x * UIScreen.main.bounds.width,
                y: star.y * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.easeInOut(duration: star.twinkleSpeed).repeatForever(autoreverses: true)) {
                    opacity = star.brightness
                }
            }
    }
}

struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let opacity: Double
}

struct BubbleView: View {
    let bubble: Bubble
    @State private var yOffset: CGFloat = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .stroke(.white, lineWidth: 2)
            .frame(width: bubble.size, height: bubble.size)
            .opacity(bubble.opacity)
            .scaleEffect(scale)
            .position(
                x: bubble.x * UIScreen.main.bounds.width,
                y: (bubble.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 8 / bubble.speed).repeatForever(autoreverses: false)) {
                    yOffset = -1.5
                    scale = 1.2
                }
            }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let opacity: Double
    let direction: Double
}

struct ParticleView: View {
    let particle: Particle
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: particle.size, height: particle.size)
            .opacity(particle.opacity)
            .position(
                x: (particle.x + xOffset) * UIScreen.main.bounds.width,
                y: (particle.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                let distance: CGFloat = 0.3
                let targetX = cos(particle.direction) * distance
                let targetY = sin(particle.direction) * distance
                
                withAnimation(.linear(duration: 5 / particle.speed).repeatForever(autoreverses: true)) {
                    xOffset = targetX
                    yOffset = targetY
                }
            }
    }
}

// MARK: - Additional Background Styles

struct AuroraBackground: View {
    let baseColor: Color
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince1970
                let phase = time.truncatingRemainder(dividingBy: 60) / 15

                // Create aurora bands
                for i in 0..<6 {
                    let bandPhase = phase + Double(i) * 0.25
                    let y = size.height * (0.2 + 0.6 * sin(bandPhase * 2 * .pi))
                    let amplitude = 100.0 + 50.0 * sin(bandPhase * 3 * .pi)
                    
                    let path = Path { path in
                        path.move(to: CGPoint(x: -(size.width * 0.2), y: y))

                        for x in stride(from: 0, through: size.width * 1.2, by: 4) {
                            let waveY = y + amplitude * sin(x * 0.01 + bandPhase * 4 * .pi)
                            path.addLine(to: CGPoint(x: x, y: waveY))
                        }
                    }
                    
                    let color = baseColor.opacity(0.3 - Double(i) * 0.05)
                    context.stroke(path, with: .color(color), lineWidth: size.height * 0.1)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    baseColor.darker(by: 60)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct FirefliesBackground: View {
    let baseColor: Color
    @State private var fireflies: [Firefly] = []
    
    var body: some View {
        ZStack {
            // Dark background
            LinearGradient(
                colors: [
                    Color.black,
                    baseColor.darker(by: 70)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Fireflies
            ForEach(fireflies) { firefly in
                FireflyView(firefly: firefly)
            }
        }
        .onAppear {
            createFireflies()
        }
    }
    
    private func createFireflies() {
        fireflies = (0..<30).map { _ in
            Firefly(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 2...6),
                speed: CGFloat.random(in: 0.5...2.0),
                brightness: Double.random(in: 0.4...1.0),
                pulseSpeed: Double.random(in: 1...3)
            )
        }
    }
}

struct OceanBackground: View {
    let baseColor: Color
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince1970
                let phase = time.truncatingRemainder(dividingBy: 4) / 4
                
                // Create ocean waves
                for i in 0..<5 {
                    let wavePhase = phase + Double(i) * 0.2
                    let amplitude = 20.0 + Double(i) * 8
                    let frequency = 0.015 + Double(i) * 0.005
                    
                    let path = Path { path in
                        path.move(to: CGPoint(x: 0, y: size.height))
                        
                        for x in stride(from: 0, through: size.width, by: 2) {
                            let y = size.height * 0.6 + amplitude * sin(x * frequency + wavePhase * 2 * .pi)
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.closeSubpath()
                    }
                    
                    let color = baseColor.opacity(0.3 - Double(i) * 0.05)
                    context.fill(path, with: .color(color))
                }
            }
        }
        .background(
            LinearGradient(
                colors: [
                    baseColor.lighter(by: 30),
                    baseColor,
                    baseColor.darker(by: 30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct GalaxyBackground: View {
    let baseColor: Color
    @State private var stars: [Star] = []
    @State private var nebulae: [Nebula] = []
    
    var body: some View {
        ZStack {
            // Deep space background
            Color.black
            
            // Nebulae
            ForEach(nebulae) { nebula in
                NebulaView(nebula: nebula)
            }
            
            // Stars
            ForEach(stars) { star in
                StarView(star: star)
            }
        }
        .onAppear {
            createGalaxy()
        }
    }
    
    private func createGalaxy() {
        stars = (0..<300).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...4),
                brightness: Double.random(in: 0.3...1.0),
                twinkleSpeed: Double.random(in: 1...4)
            )
        }
        
        nebulae = (0..<3).map { _ in
            Nebula(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 100...300),
                opacity: Double.random(in: 0.1...0.3),
                color: baseColor
            )
        }
    }
}

// MARK: - Additional Supporting Models

struct Firefly: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let speed: CGFloat
    let brightness: Double
    let pulseSpeed: Double
}

struct FireflyView: View {
    let firefly: Firefly
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.4
    
    var body: some View {
        Circle()
            .fill(.yellow)
            .frame(width: firefly.size, height: firefly.size)
            .opacity(opacity)
            .position(
                x: (firefly.x + xOffset) * UIScreen.main.bounds.width,
                y: (firefly.y + yOffset) * UIScreen.main.bounds.height
            )
            .onAppear {
                // Random movement
                let distance: CGFloat = 0.2
                let targetX = CGFloat.random(in: -distance...distance)
                let targetY = CGFloat.random(in: -distance...distance)
                
                withAnimation(.easeInOut(duration: 8 / firefly.speed).repeatForever(autoreverses: true)) {
                    xOffset = targetX
                    yOffset = targetY
                }
                
                // Pulsing brightness
                withAnimation(.easeInOut(duration: firefly.pulseSpeed).repeatForever(autoreverses: true)) {
                    opacity = firefly.brightness
                }
            }
    }
}

struct Nebula: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    let color: Color
}

struct NebulaView: View {
    let nebula: Nebula
    
    var body: some View {
        Circle()
            .fill(nebula.color)
            .frame(width: nebula.size, height: nebula.size)
            .opacity(nebula.opacity)
            .blur(radius: 30)
            .position(
                x: nebula.x * UIScreen.main.bounds.width,
                y: nebula.y * UIScreen.main.bounds.height
            )
    }
} 
