//
//  View+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/11/25.
//
import SwiftUI

extension View {
    @ViewBuilder func `if`<Result: View>(_ condition: Bool, transform: (Self) -> Result) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
