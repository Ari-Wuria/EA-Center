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
        guard isValidEmail(email) && isBCISEmail(email) else {
            verifyLabel.isHidden = false
            verifyLabel.stringValue = "Invalid Email"
            return
        }
        
        let password = passwordTextField.stringValue
        
        guard let passwordEncrypted = encrypt(password) else {
            verifyLabel.stringValue = "Can not prepare data. Report bug."
            return
        }
        
        sendLoginRequest(email, passwordEncrypted)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isBCISEmail(_ testStr: String) -> Bool {
        if testStr.hasSuffix("@mybcis.cn") || testStr.count == 20 {
            return true
        }
        
        if testStr.hasSuffix("@bcis.cn") {
            return true
        }
        
        return false
    }
    
    func encrypt(_ str: String) -> String? {
        return aesEncrypt(str, GlobalAESKey, GlobalAESIV)
    }
    
    func sendLoginRequest(_ email: String, _ passEnc: String) {
        let urlString = MainServerAddress + "/login/login.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "login=1&email=\(email)&password=\(passEnc)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                print("No JSON data")
                return
            }
            
            let failure = responseDict["failure"] as! Bool
            if failure == true {
                // Fail
                let reason = responseDict["error"] as! Int
                DispatchQueue.main.async {
                    self.verifyLabel.isHidden = false
                    if reason == 1 {
                        self.verifyLabel.stringValue = "Wrong Password"
                    } else if reason == 2 {
                        self.verifyLabel.stringValue = "Did you forget to activate?"
                    } else if reason == 3 {
                        self.verifyLabel.stringValue = "Please register first"
                    }
                    return
                }
            }
            
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    self.verifyLabel.isHidden = false
                    self.verifyLabel.stringValue = "You are now logged in. Nothing else for now :)"
                }
            }
        }
        dataTask.resume()
    }
}
