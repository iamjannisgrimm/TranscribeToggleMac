//
//  KeychainManager.swift
//  TranscribeToggle
//
//  Secure storage utilities for API keys and sensitive data
//
//  Created by Jannis Grimm on 9/14/25.
//

import Foundation
import Security

/// Utility class for secure keychain storage operations
class KeychainManager {
    private static let service = "TranscribeToggle"
    private static let account = "OpenAI-API-Key"

    /// Retrieve API key from keychain
    static func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess,
           let data = item as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }

        return nil
    }

    /// Save API key to keychain
    static func saveAPIKey(_ apiKey: String) {
        guard let data = apiKey.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
}