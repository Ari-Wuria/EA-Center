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

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
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
    
    func registerFinished(withEmail email: String) {
        if contentViewController is RegisterViewController {
            contentViewController = loginView
            loginView!.setEmail(email)
            
            loginView?.verifyLabel.isHidden = false
            loginView?.verifyLabel.stringValue = "Email isn't implemented. WeChat me to activate."
            
            registerView = nil
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return contentViewController?.makeTouchBar()
    }

}
