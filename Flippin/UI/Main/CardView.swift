//
//  CardView.swift
//  Flippin
//
//  Created by Alexander Riakhin on 6/30/25.
//

import SwiftUI

/**
 Interactive card view with 3D flip animation.
 Displays card content on front and back with smooth rotation animation.
 Supports tap gesture to flip between front and back views.
 */
struct CardView: View {
    // MARK: - State Objects
    
    @StateObject private var cardsProvider = CardsProvider.shared
    @StateObject private var colorManager = ColorManager.shared

    // MARK: - State Variables
    
    @State private var isFlipped = false
    @State private var animationStart: Date? = nil
    @State private var animationDirection: CGFloat = 1 // 1 for forward, -1 for backward

    // MARK: - Constants
    
    private let animationDuration: Double = 0.5 // seconds
    
    // MARK: - Properties
    
    private let card: CardItem

    // MARK: - Initialization
    
    init(card: CardItem) {
        self.card = card
    }

    // MARK: - Body
    
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
                    CardFrontView(card: card)
                } else {
                    CardBackView(card: card)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .rotation3DEffect(.degrees(animatedAngle), axis: (x: 0, y: 1, z: 0))
            .shadow(radius: 1)
            .onTapGesture {
                if animationStart == nil {
                    animationDirection = isFlipped ? -1 : 1
                    animationStart = now
                    
                    // Haptic feedback for card flip
                    HapticService.shared.cardFlipped()
                    
                    // Track card flip event
                    AnalyticsService.trackCardEvent(
                        .cardFlipped,
                        cardLanguage: card.frontLanguage?.rawValue,
                        hasTags: !card.tagNames.isEmpty,
                        tagCount: card.tagNames.count
                    )
                    
                    // Start study session if not already started
                    if LearningAnalyticsService.shared.currentSession == nil {
                        LearningAnalyticsService.shared.startStudySession()
                    }
                }
            }
            .onChange(of: progress) { _, newProgress in
                if newProgress >= 1, animationStart != nil {
                    isFlipped.toggle()
                    animationStart = nil
                }
            }
        }
    }
}
