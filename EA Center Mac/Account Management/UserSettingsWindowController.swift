//
//  UserSettingsWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/22.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class UserSettingsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Remove unused top button
        let minimizeButton = window?.standardWindowButton(.miniaturizeButton)
        //minimizeButton?.frame.size = CGSize.zero
        minimizeButton?.removeFromSuperview()
        
        let resizeButton = window?.standardWindowButton(.zoomButton)
        //resizeButton?.frame.size = CGSize.zero
        resizeButton?.removeFromSuperview()
    }

}
