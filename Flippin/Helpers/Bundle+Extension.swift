//
//  Bundle+Extension.swift
//  Flippin
//
//  Created by Alexander Riakhin on 12/19/25.
//

import Foundation

enum BundleDecodeError: Error, LocalizedError {
    case fileNotFound(String)
    case dataLoadFailed(String)
    case decodeFailed(String, Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Failed to locate \(fileName) in bundle"
        case .dataLoadFailed(let fileName):
            return "Failed to load \(fileName) from bundle"
        case .decodeFailed(let fileName, let error):
            return "Failed to decode \(fileName) from bundle: \(error.localizedDescription)"
        }
    }
}

extension Bundle {
    // Generic type T to decode anything from JSON Data files
    func decode<T: Codable>(_ file: String) throws -> T {
        // Getting location of the file in our bundle and set temporary url constant
        guard let url = self.url(forResource: file, withExtension: nil) else {
            throw BundleDecodeError.fileNotFound(file)
        }
        
        // Setting temporary data constant with Data from the file found in the bundle
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BundleDecodeError.dataLoadFailed(file)
        }
        
        // Decoder instance
        let decoder = JSONDecoder()

        // Loading data from data constant
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw BundleDecodeError.decodeFailed(file, error)
        }
    }
} 
