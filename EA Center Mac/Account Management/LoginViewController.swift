//
//  LoginViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/21.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    @IBOutlet weak var verifyLabel: NSTextField!
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBOutlet weak var rememberMeCheckbox: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Remove unused top button
        let minimizeButton = view.window?.standardWindowButton(.miniaturizeButton)
        minimizeButton?.frame.size = CGSize.zero
        
        let resizeButton = view.window?.standardWindowButton(.zoomButton)
        resizeButton?.frame.size = CGSize.zero
    }
    
    @IBAction func register(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.register()
    }
    
    func setEmail(_ email: String) {
        emailTextField.stringValue = email
        passwordTextField.stringValue = ""
    }
    
    @IBAction func login(_ sender: Any) {
        let email = emailTextField.stringValue
        guard AccountProcessor.validateEmail(email) else {
            verifyLabel.isHidden = false
            verifyLabel.stringValue = "Invalid Email"
            return
        }
        
        let password = passwordTextField.stringValue
        
        guard let passwordEncrypted = AccountProcessor.encrypt(password) else {
            verifyLabel.stringValue = "Can not prepare data. Report bug."
            return
        }
        
        if rememberMeCheckbox.state == .on {
            // Save password
            let passwordData = passwordEncrypted.data(using: .utf8)!
            let success = KeychainHelper.saveKeychain(account: email, password: passwordData)
            if success == true {
                UserDefaults.standard.set(true, forKey: "RememberLogin")
                UserDefaults.standard.set(email, forKey: "LoginEmail")
            }
        }
        
        AccountProcessor.sendLoginRequest(email, passwordEncrypted) { (success, errCode, errString) in
            if success {
                //self.verifyLabel.isHidden = false
                //self.verifyLabel.stringValue = "You are now logged in. Nothing else for now :)"
                
                let notification = NSUserNotification()
                notification.title = "Success"
                notification.informativeText = "You are now logged in as \(email)"
                notification.hasActionButton = false
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.scheduleNotification(notification)
                
                NotificationCenter.default.post(name: LoginSuccessNotification, object: ["email":email])
            } else {
                switch errCode {
                case -1:
                    // Error
                    print("\(errString!)")
                    break
                case -2, -3:
                    // -2: Wrong Status Code
                    // -3: No JSON data
                    print("\(errString!)")
                    break
                case 1, 2, 3:
                    self.verifyLabel.isHidden = false
                    self.verifyLabel.stringValue = errString!
                default:
                    break
                }
            }
        }
    }
}
