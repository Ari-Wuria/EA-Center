//
//  HelperFunctions.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/12.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

func delay(_ time: Double, _ block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
}

func randomAlphanumericString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

// String word count
extension String {
    var words: [String] {
        var words: [String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { word,_,_,_ in
            guard let word = word else { return }
            words.append(word)
        }
        return words
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

