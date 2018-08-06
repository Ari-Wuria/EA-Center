//
//  AboutWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        window?.isMovableByWindowBackground = true
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return contentViewController?.makeTouchBar()
    }

}
