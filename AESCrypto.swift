//
//  AESCrypto.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/28.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation
import CommonCrypto

func aesEncrypt(_ str:String, _ key:String, _ iv:String, _ options:Int = kCCOptionPKCS7Padding) -> String? {
    if let keyData = key.data(using: String.Encoding.utf8),
        let data = str.data(using: String.Encoding.utf8),
        let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) {
        
        
        let keyLength              = size_t(kCCKeySizeAES128)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(options)
        
        
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (keyData as NSData).bytes, keyLength,
                                  iv,
                                  (data as NSData).bytes, data.count,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
            return base64cryptString
            
            
        }
        else {
            return nil
        }
    }
    return nil
}

func aesDecrypt(_ str:String, _ key:String, _ iv:String, _ options:Int = kCCOptionPKCS7Padding) -> String? {
    if let keyData = key.data(using: String.Encoding.utf8),
        let data = NSData(base64Encoded: str, options: .ignoreUnknownCharacters),
        let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {
        
        let keyLength              = size_t(kCCKeySizeAES128)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:   CCOptions   = UInt32(options)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (keyData as NSData).bytes, keyLength,
                                  iv,
                                  data.bytes, data.length,
                                  cryptData.mutableBytes, cryptData.length,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
            return unencryptedMessage
        }
        else {
            return nil
        }
    }
    return nil
}
