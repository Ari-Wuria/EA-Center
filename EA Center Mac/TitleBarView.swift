//
//  TitleBarView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/11.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class TitleBarView: NSView {
    var gradientLayer: CAGradientLayer!
    
    var forceLayer: CAGradientLayer?
    
    var isFocused: Bool = true {
        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        //print("Draw gradient: \(isFocused)")
        
        wantsLayer = true
        
        layer?.backgroundColor = NSColor(named: "Titlebar Unfocused")?.cgColor
        
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
        }
        
        // Drawing code here.
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let color1 = NSColor(named: "Titlebar Gradient 1")!
        let color2 = NSColor(named: "Titlebar Gradient 2")!
        let color3 = NSColor(named: "Titlebar Gradient 3")!
        
        let colors = [color3.cgColor, color2.cgColor, color1.cgColor]
        gradientLayer.colors = colors
        
        gradientLayer.opacity = isFocused ? 1 : 0
        gradientLayer.removeAllAnimations()
        
        if gradientLayer.superlayer == nil {
            layer!.insertSublayer(gradientLayer, at: 0)
        }
    }
}

