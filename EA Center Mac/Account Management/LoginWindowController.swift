//
//  LoginWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/28.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {
    var loginView: LoginViewController?
    var registerView: RegisterViewController?
    var forgotView: ForgotPasswordViewController?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        // Remove unused top button
        let minimizeButton = window?.standardWindowButton(.miniaturizeButton)
        //minimizeButton?.frame.size = CGSize.zero
        minimizeButton?.removeFromSuperview()
        
        let resizeButton = window?.standardWindowButton(.zoomButton)
        //resizeButton?.frame.size = CGSize.zero
        resizeButton?.removeFromSuperview()
        
        window?.isMovableByWindowBackground = true
    }
    
    func register() {
        if loginView == nil {
            loginView = contentViewController as? LoginViewController
        }
        
        let userStoryboard = NSStoryboard(name: "UserSettings", bundle: .main)
        let controller = userStoryboard.instantiateController(withIdentifier: "RegisterView") as! RegisterViewController
        registerView = controller
        contentViewController = controller
    }
    
    func closeRegister() {
        if contentViewController is RegisterViewController {
            contentViewController = loginView
            registerView = nil
        }
    }
    
    func forgotPassword() {
        if loginView == nil {
            loginView = contentViewController as? LoginViewController
        }
        
        let userStoryboard = NSStoryboard(name: "UserSettings", bundle: .main)
        let controller = userStoryboard.instantiateController(withIdentifier: "ForgotView") as! ForgotPasswordViewController
        forgotView = controller
        contentViewController = controller
    }
    
    func closeForgotPassword() {
        if contentViewController is ForgotPasswordViewController {
            contentViewController = loginView
            forgotView = nil
        }
    }
    
    func registerFinished(withEmail email: String) {
        if contentViewController is RegisterViewController {
            contentViewController = loginView
            loginView!.setEmail(email)
            
            loginView?.verifyLabel.isHidden = false
            loginView?.verifyLabel.stringValue = "A confirmation email has been sent to your inbox."
            //loginView?.verifyLabel.stringValue = "Email isn't implemented. WeChat me to activate."
            
            loginView?.finishedRegister = true
            
            registerView = nil
        }
    }
    
    func forgotPassFinished(withEmail email: String) {
        if contentViewController is ForgotPasswordViewController {
            contentViewController = loginView
            
            loginView?.verifyLabel.isHidden = false
            loginView?.verifyLabel.stringValue = "A confirmation email has been sent to your inbox."
            //loginView?.verifyLabel.stringValue = "Email isn't implemented. WeChat me to activate."
            
            loginView?.finishedRegister = true
            
            forgotView = nil
        }
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        return contentViewController?.makeTouchBar()
    }

}
