//
//  HapticService.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation
import UIKit

final class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    // MARK: - Haptic Feedback Types
    
    /// Light impact feedback for subtle interactions
    func lightImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// Medium impact feedback for standard interactions
    func mediumImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// Heavy impact feedback for significant interactions
    func heavyImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// Rigid impact feedback for rigid interactions
    func rigidImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .rigid)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// Soft impact feedback for soft interactions
    func softImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    /// Success notification feedback
    func success() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning notification feedback
    func warning() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error notification feedback
    func error() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Selection feedback for picker changes
    func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - App-Specific Haptic Feedback
    
    /// Card flip haptic feedback
    func cardFlipped() {
        mediumImpact()
    }
    
    /// Card shuffle haptic feedback
    func cardsShuffled() {
        heavyImpact()
    }
    
    /// Favorite toggle haptic feedback
    func favoriteToggled(isFavorite: Bool) {
        if isFavorite {
            success()
        } else {
            lightImpact()
        }
    }
    
    /// Card added haptic feedback
    func cardAdded() {
        success()
    }
    
    /// Card deleted haptic feedback
    func cardDeleted() {
        error()
    }
    
    /// Card edited haptic feedback
    func cardEdited() {
        mediumImpact()
    }
    
    /// Tag added haptic feedback
    func tagAdded() {
        lightImpact()
    }
    
    /// Tag deleted haptic feedback
    func tagDeleted() {
        mediumImpact()
    }
    
    /// Filter applied haptic feedback
    func filterApplied() {
        selection()
    }
    
    /// Filter cleared haptic feedback
    func filterCleared() {
        lightImpact()
    }
    
    /// Button tap haptic feedback
    func buttonTapped() {
        lightImpact()
    }
    
    /// Menu opened haptic feedback
    func menuOpened() {
        softImpact()
    }
    
    /// Settings changed haptic feedback
    func settingChanged() {
        selection()
    }
    
    /// Language changed haptic feedback
    func languageChanged() {
        mediumImpact()
    }
    
    /// Background style changed haptic feedback
    func backgroundStyleChanged() {
        softImpact()
    }
    
    /// TTS started haptic feedback
    func ttsStarted() {
        lightImpact()
    }
    
    /// Translation completed haptic feedback
    func translationCompleted() {
        lightImpact()
    }
    
    /// Search performed haptic feedback
    func searchPerformed() {
        softImpact()
    }
    
    /// Swipe action haptic feedback
    func swipeAction() {
        mediumImpact()
    }
    
    /// Sheet presented haptic feedback
    func sheetPresented() {
        softImpact()
    }
    
    /// Sheet dismissed haptic feedback
    func sheetDismissed() {
        lightImpact()
    }
    
    /// Alert shown haptic feedback
    func alertShown() {
        warning()
    }
    
    /// Purchase success haptic feedback
    func purchaseSuccess() {
        success()
    }
    
    /// Purchase failed haptic feedback
    func purchaseFailed() {
        error()
    }
} 
