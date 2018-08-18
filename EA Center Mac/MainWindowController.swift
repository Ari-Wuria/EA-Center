//
//  MainWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    //var bulletinController: NSWindowController? = nil
    var manageController: NSWindowController? = nil
    
    var loggedIn = false
    
    var currentEmail: String = ""
    
    var requestedManager = false

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Pretty dumb method. Consider a better one for later
        (NSApp.delegate as! AppDelegate).mainWindow = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: LogoutNotification, object: nil)
        
        window?.delegate = self
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return (contentViewController as! ViewController).makeTouchBar()
    }
    
    @objc func loginSuccess(_ notification: Notification) {
        loggedIn = true
        let object = notification.object as! [String:Any]
        let account = object["account"] as! UserAccount
        currentEmail = account.userEmail
        
        if requestedManager {
            showManager(notification)
            requestedManager = false
        }
    }
    
    @objc func logout(_ notification: Notification) {
        loggedIn = false
        currentEmail = ""
    }

    @IBAction func showStudentBulletin(_ sender: Any) {
        // Managed by storyboard now
        /*
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
 */
    }
    
    @objc func bulletinClosed() {
        //bulletinController?.close()
        //bulletinController = nil
    }
    
    @IBAction func showManager(_ sender: Any) {
        if loggedIn {
            if let window = manageController {
                // Set email
                let manageViewController = window.contentViewController as! EAManagerViewController
                manageViewController.loggedInEmail = currentEmail
                
                window.showWindow(sender)
            } else {
                let storyboard = NSStoryboard.main!
                let manageWindow = storyboard.instantiateController(withIdentifier: "Manage") as! NSWindowController
                
                let manageViewController = manageWindow.contentViewController as! EAManagerViewController
                manageViewController.loggedInEmail = currentEmail
                
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
            requestedManager = true
        }
    }
    
    @IBAction func showCampusMap(_ sender: Any) {
        
    }
    
    @objc func manageClosed() {
        manageController?.close()
        manageController = nil
    }
    
    func windowDidBecomeMain(_ notification: Notification) {
        //print("Window did become main")
        let titlebarView = (contentViewController as! ViewController).titlebarView
        titlebarView?.isFocused = true
    }
    
    func windowDidResignMain(_ notification: Notification) {
        //print("Window did resign main")
        let titlebarView = (contentViewController as! ViewController).titlebarView
        titlebarView?.isFocused = false
    }
}
