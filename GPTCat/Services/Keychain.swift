//
//  Keychain.swift
//  GPTCat
//
//  Created by Polina Sergeyenko on 10/1/25.
//

import Foundation
import Security

class Keychain {
    
    static private let account = NSUserName() as String
    static private let service = Bundle.main.bundleIdentifier ?? "myservice"
    static private let keyClass = kSecClassGenericPassword
    
    @discardableResult
    class func save(key: String, value: String) -> Bool {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: keyClass,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data,
                kSecAttrLabel as String: makeKeyLabel(key)
            ]
            
            // Delete existing item if any
            SecItemDelete(query as CFDictionary)
            
            // Add new item
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        return false
    }
    
    class func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: keyClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrLabel as String: makeKeyLabel(key),
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    @discardableResult
    class func delete(key:String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: keyClass,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrLabel as String: makeKeyLabel(key)
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    class func makeKeyLabel(_ key: String) -> String {
        return "\(service).\(key)"
    }
}
