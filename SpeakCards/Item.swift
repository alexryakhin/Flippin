//
//  Item.swift
//  SpeakCards
//
//  Created by Alexander Riakhin on 6/29/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
