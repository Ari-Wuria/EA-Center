//
//  RegisterViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/28.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa
import CommonCrypto

class RegisterViewController: NSViewController {
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var registerButton: NSButton!
    
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var confirmTextField: NSSecureTextField!
    
    var emailValid: Bool = false
    var passwordValid: Bool = false
    var confirmValid: Bool = false
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        statusLabel.stringValue = "Please use valid BCIS email."
        
        //registerButton.isEnabled = false
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        emailTextField.becomeFirstResponder()
        emailTextField.currentEditor()?.insertText("@bcis.cn")
        emailTextField.currentEditor()?.moveToBeginningOfLine(nil)
        
        view.window!.title = "Register"
    }
    
    @IBAction func cancelRegister(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.closeRegister()
    }
    
    @IBAction func register(_ sender: Any) {
        // Validate email
        let email = emailTextField.stringValue
        
        guard AccountProcessor.isValidEmail(email) else {
            statusLabel.stringValue = "Please enter a valid email"
            return
        }
        
        guard AccountProcessor.isBCISEmail(email) else {
            statusLabel.stringValue = "Please use valid BCIS email"
            return
        }
        
        // Validate password
        let password = passwordTextField.stringValue
        
        guard password.count >= 8 else {
            statusLabel.stringValue = "Password length needs to be greater than 8"
            return
        }
        
        guard AccountProcessor.isAlphanumeral(password) else {
            statusLabel.stringValue = "Password must be alphanumeral"
            return
        }
        
        // Validate confirm password
        let confirm = confirmTextField.stringValue
        
        guard confirm == password else {
            statusLabel.stringValue = "Confirm password is incorrect"
            return
        }
        
        // Get account type
        let accountType = getAccountType(from: email)
        
        guard accountType != -1 else {
            statusLabel.stringValue = "Can not confirm account type. Report bug."
            return
        }
        
        // Encrypt password
        guard let passwordEncrypted = AccountProcessor.encrypt(password) else {
            statusLabel.stringValue = "Can not prepare registration data. Report bug."
            return
        }
        
        sendRegistrationData(email, passwordEncrypted, accountType)
    }
    
    func getAccountType(from email: String) -> Int {
        // Only student and teachers can be registered
        // Other types of accounts must be created directly from database
        if email.hasSuffix("@mybcis.cn") {
            // Student
            return 4
        }
        if email.hasSuffix("@bcis.cn") {
            // Teachers
            return 3
        }
        return -1
    }
    
    func sendRegistrationData(_ email: String, _ encryptedPassword: String, _ accountType: Int) {
        statusLabel.stringValue = "Registering..."
        
        AccountProcessor.sendRegistrationData(email, encryptedPassword, accountType) { (success, errStr) in
            if success == true {
                let window = self.view.window?.windowController as! LoginWindowController
                window.registerFinished(withEmail: email)
            } else {
                self.statusLabel.stringValue = errStr
            }
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
