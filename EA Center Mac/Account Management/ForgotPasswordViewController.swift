//
//  ForgotPasswordViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/9.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ForgotPasswordViewController: NSViewController {
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var newPassTextField: NSSecureTextField!
    @IBOutlet weak var confirmNewPassTextField: NSSecureTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        emailTextField.becomeFirstResponder()
        emailTextField.currentEditor()?.insertText("@bcis.cn")
        emailTextField.currentEditor()?.moveToBeginningOfLine(nil)
        
        view.window!.title = "Forgot Password"
    }
    
    @IBAction func reset(_ sender: Any) {
        statusLabel.isHidden = false
        statusLabel.stringValue = ""
        
        let email = emailTextField.stringValue
        
        guard AccountProcessor.isValidEmail(email) && AccountProcessor.isBCISEmail(email) else {
            statusLabel.stringValue = "Please enter valid BCIS email!"
            return
        }
        
        let password = newPassTextField.stringValue
        
        guard password.count >= 8 else {
            statusLabel.stringValue = "Password length must be greater than 8"
            return
        }
        
        let confirmPass = confirmNewPassTextField.stringValue
        
        guard password == confirmPass else {
            statusLabel.stringValue = "Invalid confirm password!"
            return
        }
        
        guard let encryptedPass = AccountProcessor.encrypt(password) else {
            statusLabel.stringValue = "Can not prepare password!"
            return
        }
        
        AccountProcessor.sendForgotPasswordRequest(email, encryptedPass) { (success, errStringOrEmail) in
            if success {
                let window = self.view.window!.windowController! as! LoginWindowController
                window.forgotPassFinished(withEmail: errStringOrEmail)
            } else {
                self.statusLabel.stringValue = errStringOrEmail
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.closeForgotPassword()
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
