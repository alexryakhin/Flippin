//
//  StoreProduct+Extension.swift
//  Flippin
//
//  Created by AI Assistant
//

import Foundation
import RevenueCat

extension StoreProduct {
    /// Returns a localized string representation of the subscription period unit
    var localizedPeriod: String {
        switch self.subscriptionPeriod?.unit {
        case .day:
            return Loc.Paywall.daily
        case .week:
            return Loc.Paywall.weekly
        case .month:
            return Loc.Paywall.monthlyPeriod
        case .year:
            return Loc.Paywall.yearly
        default:
            return ""
        }
    }

    var localizedPrice: String? {
        switch self.subscriptionPeriod?.unit {
        case .day:
            return self.localizedPricePerDay
        case .week:
            return self.localizedPricePerWeek
        case .month:
            return self.localizedPricePerMonth
        case .year:
            return self.localizedPricePerYear
        default:
            return nil
        }
    }
}

