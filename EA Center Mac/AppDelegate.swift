//
//  AppDelegate.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    @IBOutlet weak var loginStatusMenu: NSMenuItem!
    @IBOutlet weak var loginMenu: NSMenuItem!
    @IBOutlet weak var userSettingMenu: NSMenuItem!
    
    var loginWindow: NSWindowController? = nil
    
    var loggedIn = false
    var currentEmail: String?
    
    // Pretty dumb method
    var mainWindow: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        updateMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess(_:)), name: LoginSuccessNotification, object: nil)
        
        NSUserNotificationCenter.default.delegate = self
        
        let defaults = ["RememberLogin":false, "LoginEmail":""] as [String : Any]
        UserDefaults.standard.register(defaults: defaults)
        
        if UserDefaults.standard.bool(forKey: "RememberLogin") {
            let email = UserDefaults.standard.value(forKey: "LoginEmail") as! String
            guard let passwordData = KeychainHelper.loadKeychain(account: email) else { return }
            let password = String(data: passwordData, encoding: .utf8)
            AccountProcessor.sendLoginRequest(email, password!) { (success, errCode, errString) in
                // I don't think we need error handling here
                // If the login fails then nothing will happen
                // Just directly post the notification if it succeeded
                if success == true {
                    NotificationCenter.default.post(name: LoginSuccessNotification, object: ["email":email])
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    @objc func loginSuccess(_ notification: Notification) {
        loginWindow?.window?.close()
        loginWindow = nil
        
        loggedIn = true
        
        let object = notification.object as! [String: AnyObject]
        currentEmail = object["email"] as? String
        
        updateMenu()
    }
    
    @IBAction func toggleLoginState(_ sender: Any) {
        if loggedIn == false {
            // Not logged in
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
        } else {
            if mainWindow?.manageController != nil {
                // Still on manage EA, can't logout
                let alert = NSAlert()
                alert.addButton(withTitle: "Close")
                alert.messageText = "Can not log out"
                alert.informativeText = "Please save all your changes and close the Manage EA window before logging out"
                alert.runModal()
            } else {
                // Logout. Clean up user session
                NotificationCenter.default.post(name: LogoutNotification, object: nil)
                loggedIn = false
                updateMenu()
                
                let email = UserDefaults.standard.value(forKey: "LoginEmail") as! String
                let _ = KeychainHelper.deleteKeychain(account: email)
                UserDefaults.standard.set("", forKey: "LoginEmail")
                UserDefaults.standard.set(false, forKey: "RememberLogin")
            }
        }
    }
    
    @IBAction func showUserSettings(_ sender: Any) {
    }
    
    func updateMenu() {
        if loggedIn {
            loginMenu.title = "Logout"
            loginStatusMenu.title = "Logged in as: \(currentEmail!)"
            userSettingMenu.isHidden = false
        } else {
            loginStatusMenu.title = "Not logged in"
            loginMenu.title = "Login"
            userSettingMenu.isHidden = true
        }
    }
}

