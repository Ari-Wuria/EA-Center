//
//  HelperFunctions.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/12.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(Cocoa)
import Cocoa
#else
#error("Unsupported platform")
#endif

import SystemConfiguration

func delay(_ time: Double, _ block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: block)
}

func randomAlphanumericString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    //let len = UInt32(letters.length)
    let len = letters.length
    
    var randomString = ""
    
    for _ in 0 ..< length {
        //let rand = arc4random_uniform(len)
        let rand = Int.random(in: 0..<len)
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

// String subscript
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

// UIImage rotate for iOS
#if os(iOS)
extension UIImage {
    func rotate(byDegrees degree: Double) -> UIImage {
        let radians = CGFloat(degree*Double.pi)/180.0 as CGFloat
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        
        bitmap.rotate(by: radians);
        
        bitmap.scaleBy(x: 1.0, y: -1.0);
        //CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2 , self.size.width, self.size.height), self.CGImage );
        bitmap.draw(cgImage!, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        return newImage
    }
    
}
#endif

#if os(OSX)
extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}
#endif

// Old system wrapper for catalog
#if os(OSX)
// NSColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
func color(name: String) -> NSColor {
    switch name {
    case "Titlebar Gradient 1":
        return rgbaColor(144, 207, 255, 1)
    case "Titlebar Gradient 2":
        return rgbaColor(144, 195, 255, 1)
    case "Titlebar Gradient 3":
        return rgbaColor(133, 180, 255, 1)
    case "Table Cell Color 0":
        return NSColor.white
    case "Table Cell Color 1":
        return rgbaColor(216, 240, 255, 1)
    case "Table Cell Color 2":
        return rgbaColor(205, 220, 255, 1)
    case "Table Cell Color 3":
        return rgbaColor(180, 195, 240, 1)
    case "Table Cell Color 4":
        return rgbaColor(255, 255, 204, 1)
    case "Table Cell Color 5":
        return rgbaColor(255, 204, 204, 1)
    case "Table Cell Color 6":
        return rgbaColor(255, 204, 153, 1)
    case "Titlebar Unfocused":
        return rgbaColor(176, 224, 255, 1)
    case "Table Selection Color":
        return rgbaColor(46, 152, 226, 1)
    case "Table Color":
        return rgbaColor(170, 218, 255, 1)
    default:
        return NSColor.black
    }
}

fileprivate func rgbaColor(_ red: CGFloat, _ blue: CGFloat, _ green: CGFloat, _ alpha: CGFloat) -> NSColor {
    return NSColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}
#endif
