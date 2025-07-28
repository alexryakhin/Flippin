//
//  TimeInterval+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import Foundation

extension TimeInterval {
    
    /// Format time interval for study sessions (shows minutes and seconds)
    var formattedStudyTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: self) ?? "0s"
    }
    
    /// Format time interval for analytics display (shows hours and minutes)
    var formattedAnalyticsTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: self) ?? "0m"
    }
    
    /// Format time interval for detailed display (shows hours, minutes, and seconds)
    var formattedDetailedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: self) ?? "0s"
    }
    
    /// Format time interval for session results (shows minutes and seconds with full words)
    var formattedSessionTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: self) ?? "0 seconds"
    }
} 