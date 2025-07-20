//
//  Optional+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/20/25.
//

import Foundation

extension Optional<String> {
    var orEmpty: String {
        self ?? ""
    }
}

extension Optional<Date> {
    var orNow: Date {
        self ?? .now
    }
}

extension Optional where Wrapped: RangeReplaceableCollection {
    var orEmpty: Wrapped {
        return self ?? Wrapped()
    }
}
