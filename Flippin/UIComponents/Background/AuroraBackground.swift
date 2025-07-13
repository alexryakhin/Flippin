//
//  AuroraBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

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
