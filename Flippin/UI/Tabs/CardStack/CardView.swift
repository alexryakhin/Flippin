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
    @State private var cardRotation = 0.0
    @State private var contentRotation = 0.0
    @State private var showingDeleteAlert = false

    @StateObject private var card: CardItem

    // MARK: - Initialization
    
    init(card: CardItem) {
        self._card = .init(wrappedValue: card)
    }

    // MARK: - Body
    
    var body: some View {
        ZStack {
            if isFlipped {
                CardBackView(card: card)
            } else {
                CardFrontView(card: card)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect(cornerRadius: 20))
        .glassBackgroundEffectIfAvailableWithBackup(.regular, in: .rect(cornerRadius: 20))
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            if #unavailable(iOS 26.0) {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.separator, lineWidth: 1)
            }
        }
        .rotation3DEffect(.degrees(contentRotation), axis: (x: 0, y: 1, z: 0))
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            flipCard()
        }
        .contextMenu {
            Button {
                HapticService.shared.buttonTapped()
                editCard()
            } label: {
                Label(Loc.Buttons.edit, systemImage: "pencil")
            }
            Button {
                HapticService.shared.buttonTapped()
                showingDeleteAlert = true
            } label: {
                Label(Loc.Buttons.delete, systemImage: "trash")
            }
            .tint(.red)
        }
        .alert(Loc.Buttons.deleteCard, isPresented: $showingDeleteAlert) {
            Button(Loc.Buttons.delete, role: .destructive) {
                deleteCard()
            }
            Button(Loc.Buttons.cancel, role: .cancel) { }
        } message: {
            Text(Loc.Buttons.deleteCardConfirmation)
        }
    }
    
    // MARK: - Actions
    
    private func flipCard() {
        let animationTime = 0.5

        withAnimation(.easeInOut(duration: animationTime)) {
            if isFlipped { cardRotation += 180 } else { cardRotation -= 180 }
        }
        
        withAnimation(.easeInOut(duration: 0.001).delay(animationTime / 2)) {
            if isFlipped { contentRotation += 180 } else { contentRotation -= 180 }
            isFlipped.toggle()
        }

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
    
    private func editCard() {
        NavigationManager.shared.navigate(to: .editCard(card))
    }
    
    private func deleteCard() {
        cardsProvider.deleteCard(card)
    }
}
