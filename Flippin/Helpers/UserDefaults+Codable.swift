//
//  UserDefaults+Codable.swift
//  Flippin
//
//  Created by Assistant on 12/19/25.
//

import Foundation
import SwiftUI

extension UserDefaults {
    
    // MARK: - Set Codable Objects
    
    /// Sets a Codable object for the specified key
    /// - Parameters:
    ///   - object: The Codable object to store
    ///   - forKey: The key to store the object under
    /// - Throws: EncodingError if the object cannot be encoded
    func setCodable<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        set(data, forKey: key)
    }
    
    /// Sets a Codable object for the specified key, with a default value if encoding fails
    /// - Parameters:
    ///   - object: The Codable object to store
    ///   - forKey: The key to store the object under
    ///   - default: The default value to use if encoding fails
    func setCodable<T: Codable>(_ object: T, forKey key: String, default: T) {
        do {
            try setCodable(object, forKey: key)
        } catch {
            print("Failed to encode object for key '\(key)': \(error)")
            // Try to encode the default value as fallback
            do {
                try setCodable(`default`, forKey: key)
            } catch {
                print("Failed to encode default object for key '\(key)': \(error)")
            }
        }
    }
    
    // MARK: - Get Codable Objects
    
    /// Retrieves a Codable object for the specified key
    /// - Parameter key: The key to retrieve the object from
    /// - Returns: The decoded object, or nil if not found or decoding fails
    func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Failed to decode object of type \(type) for key '\(key)': \(error)")
            return nil
        }
    }
    
    /// Retrieves a Codable object for the specified key, with a default value if not found or decoding fails
    /// - Parameters:
    ///   - type: The type of the object to retrieve
    ///   - key: The key to retrieve the object from
    ///   - default: The default value to return if not found or decoding fails
    /// - Returns: The decoded object or the default value
    func getCodable<T: Codable>(_ type: T.Type, forKey key: String, default: T) -> T {
        return getCodable(type, forKey: key) ?? `default`
    }
    
    // MARK: - Convenience Methods for Common Types
    
    /// Sets a Color as RGBAColor for the specified key
    /// - Parameters:
    ///   - color: The Color to store
    ///   - forKey: The key to store the color under
    func setColor(_ color: Color, forKey key: String) {
        let rgbaColor = RGBAColor(color: color)
        setCodable(rgbaColor, forKey: key, default: .blue)
    }
    
    /// Retrieves a Color for the specified key
    /// - Parameters:
    ///   - key: The key to retrieve the color from
    ///   - default: The default color to return if not found
    /// - Returns: The stored color or the default color
    func getColor(forKey key: String, default: Color = .blue) -> Color {
        let rgbaColor: RGBAColor = getCodable(RGBAColor.self, forKey: key, default: RGBAColor(color: `default`))
        return rgbaColor.color
    }
    
    // MARK: - Remove Methods
    
    /// Removes a Codable object for the specified key
    /// - Parameter key: The key to remove
    func removeCodable(forKey key: String) {
        removeObject(forKey: key)
    }
    
    // MARK: - Check Methods
    
    /// Checks if a Codable object exists for the specified key
    /// - Parameter key: The key to check
    /// - Returns: True if the object exists and can be decoded, false otherwise
    func hasCodable<T: Codable>(_ type: T.Type, forKey key: String) -> Bool {
        return getCodable(type, forKey: key) != nil
    }
} 