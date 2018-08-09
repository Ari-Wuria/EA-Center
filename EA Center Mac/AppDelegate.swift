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
    @IBOutlet weak var coordinatorSecrets: NSMenuItem!
    
    var loginWindow: NSWindowController? = nil
    var userSettingsWindow: NSWindowController? = nil
    var coordinatorSettingsWindow: NSWindowController? = nil
    
    var loggedIn = false
    var currentEmail: String?
    var currentAccount: UserAccount?
    
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
            
            loginMenu.isEnabled = false
            loginMenu.title = "Logging in..."
            
            AccountProcessor.sendLoginRequest(email, password!) { (success, errCode, errString) in
                // I don't think we need error handling here
                // If the login fails then nothing will happen
                // Just directly post the notification if it succeeded
                if success == true {
                    AccountProcessor.retriveUserAccount(from: errCode!) { (account, errCode, errString) in
                        if let userAccount = account {
                            NotificationCenter.default.post(name: LoginSuccessNotification, object: ["account":userAccount])
                        } else {
                            self.loginStatusMenu.title = "Auto login failed"
                            self.loginMenu.isEnabled = true
                            self.loginMenu.title = "Login"
                        }
                    }
                } else {
                    if errCode == 1 {
                        let alert = NSAlert()
                        alert.messageText = "Password change detected!"
                        alert.informativeText = "Please login manually."
                        alert.runModal()
                        
                        self.loginStatusMenu.title = "Password Changed"
                        self.loginMenu.isEnabled = true
                        self.loginMenu.title = "Login"
                        return
                    }
                    
                    self.loginStatusMenu.title = "Auto login failed"
                    self.loginMenu.isEnabled = true
                    self.loginMenu.title = "Login"
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
        let account = object["account"] as! UserAccount
        currentEmail = account.userEmail
        currentAccount = account
        
        updateMenu()
        
        if currentAccount?.username == "" {
            userSettings(notification)
        }
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
                showModalAlert(withTitle: "Can not log out", message: "Please save all your changes and close the Manage EA window before logging out")
            } else if userSettingsWindow != nil {
                showModalAlert(withTitle: "Can not log out", message: "Please save all your changes and close the User Settings window before logging out")
            } else {
                // Logout. Clean up user session
                NotificationCenter.default.post(name: LogoutNotification, object: nil)
                loggedIn = false
                updateMenu()
                
                let email = UserDefaults.standard.value(forKey: "LoginEmail") as! String
                let _ = KeychainHelper.deleteKeychain(account: email)
                UserDefaults.standard.set("", forKey: "LoginEmail")
                UserDefaults.standard.set(false, forKey: "RememberLogin")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    func updateMenu() {
        loginMenu.isEnabled = true
        if loggedIn {
            loginMenu.title = "Logout"
            loginStatusMenu.title = "Logged in as: \(currentEmail!)"
            userSettingMenu.isHidden = false
            if currentAccount?.accountType == 2 || currentAccount?.accountType == 1 {
                // Admin and supervisor
                coordinatorSecrets.isHidden = false
            }
        } else {
            loginStatusMenu.title = "Not logged in"
            loginMenu.title = "Login"
            userSettingMenu.isHidden = true
            coordinatorSecrets.isHidden = true
        }
    }
    
    @IBAction func userSettings(_ sender: Any) {
        if let window = userSettingsWindow {
            let content = window.contentViewController as! AccountSettingsViewController
            content.userAccount = currentAccount
            window.showWindow(sender)
        } else {
            let userStoryboard = NSStoryboard(name: "UserSettings", bundle: .main)
            let controller = userStoryboard.instantiateController(withIdentifier: "AccountSettings") as! NSWindowController
            let content = controller.contentViewController as! AccountSettingsViewController
            content.userAccount = currentAccount
            let button = controller.window?.standardWindowButton(.closeButton)
            button?.target = self
            button?.action = #selector(settingsClosed)
            controller.showWindow(sender)
            userSettingsWindow = controller
        }
    }
    
    @IBAction func showMainWindow(_ sender: Any) {
        mainWindow?.showWindow(sender)
    }
    
    @objc func settingsClosed() {
        userSettingsWindow?.close()
        userSettingsWindow = nil
    }
    
    func showModalAlert(withTitle title: String, message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "Close")
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    @IBAction func showCoordinatorOptions(_ sender: Any) {
        if coordinatorSettingsWindow == nil {
            let storyboard = NSStoryboard(name: "CoordinatorSettings", bundle: .main)
            let window = storyboard.instantiateInitialController() as! NSWindowController
            coordinatorSettingsWindow = window
            window.showWindow(sender)
        } else {
            coordinatorSettingsWindow?.showWindow(sender)
        }
    }
    
    @IBAction func viewGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/TomShen1234/EA-Center")!)
    }
    
    @IBAction func reportABug(_ sender: Any) {
        //NSWorkspace.shared.open(URL(string: "https://github.com/TomShen1234/EA-Center/issues")!)
    }
}

