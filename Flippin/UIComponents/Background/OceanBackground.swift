//
//  OceanBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

struct OceanBackground: View {
    @StateObject private var colorManager = ColorManager.shared

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
                    
                    let color = colorManager.userColor.opacity(0.3 - Double(i) * 0.05)
                    context.fill(path, with: .color(color))
                }
            }
        }
        .background(GradientBackground())
    }
}
