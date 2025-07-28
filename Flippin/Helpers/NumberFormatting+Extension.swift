//
//  NumberFormatting+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/28/25.
//

import Foundation

extension Double {
    
    /// Format as percentage with no decimal places
    var formattedPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }
    
    /// Format as percentage with one decimal place
    var formattedPercentageWithDecimal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }
    
    /// Format as percentage with two decimal places
    var formattedPercentageWithTwoDecimals: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0%"
    }
    
    /// Format as percentage from decimal (0.0 to 1.0) to percentage string
    var asPercentage: String {
        return (self * 100).formattedPercentage
    }
    
    /// Format as percentage from decimal (0.0 to 1.0) to percentage string with decimal
    var asPercentageWithDecimal: String {
        return (self * 100).formattedPercentageWithDecimal
    }
}

extension Float {
    
    /// Format as percentage with no decimal places
    var formattedPercentage: String {
        return Double(self).formattedPercentage
    }
    
    /// Format as percentage with one decimal place
    var formattedPercentageWithDecimal: String {
        return Double(self).formattedPercentageWithDecimal
    }
    
    /// Format as percentage from decimal (0.0 to 1.0) to percentage string
    var asPercentage: String {
        return Double(self).asPercentage
    }
    
    /// Format as percentage from decimal (0.0 to 1.0) to percentage string with decimal
    var asPercentageWithDecimal: String {
        return Double(self).asPercentageWithDecimal
    }
}

extension Int {
    
    /// Format as percentage
    var formattedPercentage: String {
        return Double(self).formattedPercentage
    }
    
    /// Format as percentage from integer (0 to 100) to percentage string
    var asPercentage: String {
        return "\(self)%"
    }
} 