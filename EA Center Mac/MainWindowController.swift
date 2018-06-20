//
//  MainWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    var bulletinController: BulletinWindowController? = nil

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return (contentViewController as! ViewController).makeTouchBar()
    }

    @IBAction func showStudentBulletin(_ sender: Any) {
        if let window = bulletinController {
            window.showWindow(sender)
        } else {
            let storyboard = NSStoryboard(name: "Main", bundle: .main)
            let bulletinWindow = storyboard.instantiateController(withIdentifier: "StudentBulletin") as! BulletinWindowController
            bulletinWindow.showWindow(sender)
            
            // Reprogram the bulletin's close button to this class so that we can
            // deinit it properly.
            let button = bulletinWindow.window?.standardWindowButton(.closeButton)
            button?.target = self
            button?.action = #selector(bulletinClosed)
            
            bulletinController = bulletinWindow
        }
    }
    
    @objc func bulletinClosed() {
        bulletinController?.close()
        bulletinController = nil
    }
}
