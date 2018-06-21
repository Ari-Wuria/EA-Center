//
//  AppDelegate.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var loginStatusMenu: NSMenuItem!
    @IBOutlet weak var loginMenu: NSMenuItem!
    @IBOutlet weak var userSettingMenu: NSMenuItem!
    
    var loginWindow: NSWindowController? = nil
    
    var loggedIn = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        updateMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func toggleLoginState(_ sender: Any) {
        if let window = loginWindow {
            window.showWindow(sender)
        } else {
            let storyboard = NSStoryboard(name: "UserSettings", bundle: .main)
            //let login = storyboard.instantiateController(withIdentifier: "Login") as! NSWindowController
            let login = storyboard.instantiateInitialController() as! NSWindowController
            login.window?.isMovableByWindowBackground = true
            login.showWindow(sender)
            /*
            // Reprogram the bulletin's close button to this class so that we can
            // deinit it properly.
            let button = login.window?.standardWindowButton(.closeButton)
            button?.target = self
            button?.action = #selector(login)
            */
            loginWindow = login
        }
    }
    
    @IBAction func showUserSettings(_ sender: Any) {
    }
    
    func updateMenu() {
        if loggedIn {
            loginMenu.title = "Logout"
            loginStatusMenu.title = "Logged in as: (user)"
            userSettingMenu.isHidden = false
        } else {
            loginStatusMenu.title = "Not logged in"
            loginMenu.title = "Login"
            userSettingMenu.isHidden = true
        }
    }
}

