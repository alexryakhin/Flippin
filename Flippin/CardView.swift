//
//  CardView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//
import SwiftUI

struct CardView: View {
    let item: CardItem
    @State private var isFlipped = false
    @State private var animationStart: Date? = nil
    @State private var animationDirection: CGFloat = 1 // 1 for forward, -1 for backward
    let animationDuration: Double = 0.5 // seconds

    var body: some View {
        TimelineView(.animation) { context in
            let now = context.date
            let start = animationStart ?? now
            let progress = min(max(now.timeIntervalSince(start) / animationDuration, 0), 1)
            let baseAngle: CGFloat = isFlipped ? 180 : 0
            let direction = animationDirection
            var animatedAngle: CGFloat {
                if animationStart != nil && progress < 1 {
                    baseAngle + direction * 180 * CGFloat(progress)
                } else {
                    isFlipped ? 180 : 0
                }
            }

            ZStack {
                if animatedAngle <= 90 {
                    CardFrontView(item: item)
                } else {
                    CardBackView(item: item)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .rotation3DEffect(.degrees(animatedAngle), axis: (x: 0, y: 1, z: 0))
            .shadow(radius: 1)
            .onTapGesture {
                if animationStart == nil {
                    animationDirection = isFlipped ? -1 : 1
                    animationStart = now
                }
            }
            .onChange(of: progress) { newProgress in
                if newProgress >= 1, animationStart != nil {
                    isFlipped.toggle()
                    animationStart = nil
                }
            }
        }
    }
}
