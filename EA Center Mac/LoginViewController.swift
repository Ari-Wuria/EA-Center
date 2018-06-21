//
//  LoginViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/21.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Remove unused top button
        let minimizeButton = view.window?.standardWindowButton(.miniaturizeButton)
        minimizeButton?.frame.size = CGSize.zero
        
        let resizeButton = view.window?.standardWindowButton(.zoomButton)
        resizeButton?.frame.size = CGSize.zero
    }
    
}
