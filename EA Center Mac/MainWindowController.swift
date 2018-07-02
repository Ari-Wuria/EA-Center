//
//  MainWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    var bulletinController: NSWindowController? = nil
    var manageController: NSWindowController? = nil
    
    var loggedIn = false

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Pretty dumb method. Consider a better one for later
        (NSApp.delegate as! AppDelegate).mainWindow = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(logInSuccess(_:)), name: LoginSuccessNotification, object: nil)
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return (contentViewController as! ViewController).makeTouchBar()
    }
    
    @objc func logInSuccess(_ notification: Notification) {
        loggedIn = true
    }

    @IBAction func showStudentBulletin(_ sender: Any) {
        if let window = bulletinController {
            window.showWindow(sender)
        } else {
            let storyboard = NSStoryboard.main!
            let bulletinWindow = storyboard.instantiateController(withIdentifier: "StudentBulletin") as! NSWindowController
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
    
    @IBAction func showManager(_ sender: Any) {
        if loggedIn {
            // Not logged in
            if let window = manageController {
                window.showWindow(sender)
            } else {
                let storyboard = NSStoryboard.main!
                let manageWindow = storyboard.instantiateController(withIdentifier: "Manage") as! NSWindowController
                manageWindow.showWindow(sender)
                
                // Reprogram the bulletin's close button to this class so that we can
                // deinit it properly.
                let button = manageWindow.window?.standardWindowButton(.closeButton)
                button?.target = self
                button?.action = #selector(manageClosed)
                
                manageController = manageWindow
            }
        } else {
            (NSApp.delegate as! AppDelegate).toggleLoginState(sender)
        }
    }
    
    @objc func manageClosed() {
        manageController?.close()
        manageController = nil
    }
}
