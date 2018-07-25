//
//  ChangePasswordViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/22.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ChangePasswordViewController: NSViewController {
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var currentPassTextField: NSSecureTextField!
    @IBOutlet weak var newPassTextField: NSSecureTextField!
    @IBOutlet weak var confirmTextField: NSSecureTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    var currentAccount: UserAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        statusLabel.isHidden = true
    }
    
    @IBAction func update(_ sender: Any) {
        if currentPassTextField.stringValue == "" || newPassTextField.stringValue == "" || confirmTextField.stringValue == "" {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Please fill out the form."
            return
        }
        
        if newPassTextField.stringValue != confirmTextField.stringValue {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Comfirm password invalid."
            return
        }
        
        let newPass = newPassTextField.stringValue
        
        guard newPass.count >= 8 else {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Password too short."
            return
        }
        
        guard AccountProcessor.isAlphanumeral(newPass) else {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Password must be alphanumeral."
            return
        }
        
        let oldPass = currentPassTextField.stringValue
        
        let oldPassEnc = AccountProcessor.encrypt(oldPass)!
        let newPassEnc = AccountProcessor.encrypt(newPass)!
        
        spinner.startAnimation(sender)
        
        currentAccount!.updatePassword(oldPassEnc, newPassEnc) { (success, errStr) in
            if success {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = "Success. Dismissing."
                delay(1) {
                    self.dismiss(nil)
                }
            } else {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = errStr!
            }
            
            self.spinner.stopAnimation(nil)
        }
    }
}
