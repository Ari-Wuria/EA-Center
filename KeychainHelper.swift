//
//  KeychainHelper.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/2.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation
import Security

class KeychainHelper {
    @discardableResult class func saveKeychain(account: String, password: Data) -> Bool {
        let query = [kSecClass as String:kSecClassGenericPassword as String,
                     kSecAttrAccount as String: account,
                     kSecValueData as String: password] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        if status != noErr {
            return false
        }
        return true
    }
    
    @discardableResult class func deleteKeychain(account: String) -> Bool {
        let query = [kSecClass as String:kSecClassGenericPassword as String,
                     kSecAttrAccount as String: account] as [String : Any]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        if status != noErr {
            return false
        }
        return true
    }
    
    @discardableResult class func loadKeychain(account: String) -> Data? {
        let query = [kSecClass as String:kSecClassGenericPassword,
            kSecAttrAccount as String:account,
            kSecReturnData as String:kCFBooleanTrue,
            kSecMatchLimit as String:kSecMatchLimitOne] as [String:Any]
        
        var data: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &data)
        if status == noErr {
            return (data as! Data)
        } else {
            return nil
        }
    }
}
