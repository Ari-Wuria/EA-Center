//
//  ChecboxBGView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/13.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

@IBDesignable
class CheckboxBGView: NSView {
    @IBInspectable var background: NSColor!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        let context = NSGraphicsContext.current?.cgContext
        let path = NSBezierPath(roundedRect: bounds, xRadius: bounds.size.width / 2, yRadius: bounds.size.height / 2)
        path.addClip()
        
        let color = background.cgColor
        context?.setFillColor(color)
        context?.fill(bounds)
    }
    
}
