//
//  LavaLampBackground.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/13/25.
//
import SwiftUI

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
