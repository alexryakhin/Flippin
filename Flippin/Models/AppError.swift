//
//  AppError.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/23/25.
//

import Foundation

enum AppError: Error, LocalizedError {
    case invalidJSONData

    var errorDescription: String? {
        switch self {
        case .invalidJSONData:
            return "JSON data is invalid"
        }
    }
}
