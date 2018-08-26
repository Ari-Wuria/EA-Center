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
        spinner.isHidden = true
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
        
        spinner.isHidden = false
        spinner.startAnimation(sender)
        
        currentAccount!.updatePassword(oldPassEnc, newPassEnc) { (success, errStr) in
            if success {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = "Success. Dismissing."
                
                let passwordData = newPassEnc.data(using: .utf8)!
                let _ = KeychainHelper.deleteKeychain(account: self.currentAccount!.userEmail)
                let success = KeychainHelper.saveKeychain(account: self.currentAccount!.userEmail, password: passwordData)
                if success == true {
                    //UserDefaults.standard.set(email, forKey: "LoginEmail")
                    // Save Password Good :)
                } else {
                    UserDefaults.standard.set(false, forKey: "RememberLogin")
                }
                UserDefaults.standard.synchronize()
                
                delay(1) {
                    self.dismiss(nil)
                }
            } else {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = errStr!
            }
            
            self.spinner.isHidden = true
            self.spinner.stopAnimation(nil)
        }
    }
}

// Custom view for popover
class PopoverRootView: NSView {
    override func viewDidMoveToWindow() {
        
        guard let frameView = window?.contentView?.superview else {
            return
        }
        
        let backgroundView = PopoverBackgroundView(frame: frameView.bounds)
        backgroundView.autoresizingMask = [.width, .height]
        
        frameView.addSubview(backgroundView, positioned: .below, relativeTo: frameView)
    }
}

class PopoverBackgroundView:NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor(named: "Manage Background")!.set()
        bounds.fill()
    }
}
