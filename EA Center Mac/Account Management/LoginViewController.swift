//
//  LoginViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/21.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa
import UserNotifications

class LoginViewController: NSViewController {
    @IBOutlet weak var verifyLabel: NSTextField!
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    @IBOutlet weak var rememberMeCheckbox: NSButton!
    
    @IBOutlet var registerButton: NSButton!
    @IBOutlet var loginButton: NSButton!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    @IBOutlet var touchRegisterButton: NSButton!
    @IBOutlet var touchLoginButton: NSButton!
    
    var finishedRegister = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if emailTextField.stringValue == "" {
            emailTextField.becomeFirstResponder()
            emailTextField.currentEditor()?.insertText("@bcis.cn")
            emailTextField.currentEditor()?.moveToBeginningOfLine(nil)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window!.title = "Login"
        
        if finishedRegister == true {
            view.window?.makeFirstResponder(passwordTextField)
        }
    }
    
    @IBAction func emailReturn(_ sender: Any) {
        view.window?.makeFirstResponder(passwordTextField)
    }
    
    @IBAction func passwordReturn(_ sender: Any) {
        if passwordTextField.stringValue != "" {
            login(sender)
        }
    }
    
    @IBAction func register(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.register()
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.forgotPassword()
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
            verifyLabel.isHidden = false
            verifyLabel.stringValue = "Can not prepare data. Report bug."
            return
        }
        
        loginButton.isEnabled = false
        registerButton.isEnabled = false
        touchLoginButton.isEnabled = false
        touchRegisterButton.isEnabled = false
        verifyLabel.isHidden = false
        verifyLabel.stringValue = "Logging in..."
        
        AccountProcessor.sendLoginRequest(email, passwordEncrypted) { (success, errCode, errString) in
            if success {
                //self.verifyLabel.isHidden = false
                //self.verifyLabel.stringValue = "You are now logged in. Nothing else for now :)"
                
                AccountProcessor.retriveUserAccount(from: errCode!) { (account, errCode, errString) in
                    if let userAccount = account {
                        if self.rememberMeCheckbox.state == .on {
                            // Save password
                            let passwordData = passwordEncrypted.data(using: .utf8)!
                            let success = KeychainHelper.saveKeychain(account: email, password: passwordData)
                            if success == true {
                                UserDefaults.standard.set(true, forKey: "RememberLogin")
                                UserDefaults.standard.set(email, forKey: "LoginEmail")
                                UserDefaults.standard.synchronize()
                            }
                        }
                        
                        let loginMessageDetail = (userAccount.username != "") ? userAccount.username : email
                        if #available(OSX 10.14, *) {
                            let content = UNMutableNotificationContent()
                            content.title = "Success"
                            content.body = "You are now logged in as \(loginMessageDetail)"
                            content.sound = UNNotificationSound.default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            
                            let request = UNNotificationRequest(identifier: "LoginSuccess", content: content, trigger: trigger)
                            let center = UNUserNotificationCenter.current()
                            center.add(request, withCompletionHandler: { (error) in
                                if error != nil {
                                    print("\(error!)")
                                }
                            })
                        } else {
                            let notification = NSUserNotification()
                            notification.title = "Success"
                            
                            notification.informativeText = "You are now logged in as \(loginMessageDetail)"
                            notification.hasActionButton = false
                            notification.soundName = NSUserNotificationDefaultSoundName
                            NSUserNotificationCenter.default.scheduleNotification(notification)
                        }
                        
                        NotificationCenter.default.post(name: LoginSuccessNotification, object: ["account":userAccount])
                    } else {
                        self.loginButton.isEnabled = true
                        self.registerButton.isEnabled = true
                        self.touchLoginButton.isEnabled = true
                        self.touchRegisterButton.isEnabled = true
                        self.verifyLabel.stringValue = "Failed!"
                        switch errCode {
                        case -1:
                            // Error
                            //print("\(errString!)")
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = errString!
                            alert.runModal()
                            break
                        case -2, -3:
                            // -2: Wrong Status Code
                            // -3: No JSON data
                            //print("\(errString!)")
                            let alert = NSAlert()
                            alert.messageText = "Error"
                            alert.informativeText = errString!
                            alert.runModal()
                            break
                        default:
                            break
                        }
                    }
                }
            } else {
                self.loginButton.isEnabled = true
                self.registerButton.isEnabled = true
                self.touchLoginButton.isEnabled = true
                self.touchRegisterButton.isEnabled = true
                self.verifyLabel.stringValue = "Failed!"
                switch errCode {
                case -1:
                    // Error
                    //print("\(errString!)")
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = errString!
                    alert.runModal()
                    break
                case -2, -3:
                    // -2: Wrong Status Code
                    // -3: No JSON data
                    //print("\(errString!)")
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = errString!
                    alert.runModal()
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
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    @IBAction func touchRegister(_ sender: Any) {
        register(sender)
    }
    
    @IBAction func touchLogin(_ sender: Any) {
        login(sender)
    }
}
