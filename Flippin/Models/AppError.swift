//
//  AppError.swift
//  Flippin
//
//  Created by Alexander Riakhin on 7/23/25.
//

import Foundation

enum AppError: Error, LocalizedError {
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidJSON:
            return LocalizationKeys.General.invalidJSON.localized
        }
    }
}
