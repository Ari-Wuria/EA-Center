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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        statusLabel.stringValue = "Please use valid BCIS email."
        
        //registerButton.isEnabled = false
    }
    
    @IBAction func cancelRegister(_ sender: Any) {
        let window = view.window?.windowController as! LoginWindowController
        window.closeRegister()
    }
    
    @IBAction func register(_ sender: Any) {
        // Validate email
        let email = emailTextField.stringValue
        
        guard isValidEmail(email) else {
            statusLabel.stringValue = "Please enter a valid email"
            return
        }
        
        guard isBCISEmail(email) else {
            statusLabel.stringValue = "Please use valid BCIS email"
            return
        }
        
        // Validate password
        let password = passwordTextField.stringValue
        
        guard password.count >= 8 else {
            statusLabel.stringValue = "Password length needs to be greater than 8"
            return
        }
        
        guard isAlphanumeral(password) else {
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
        guard let passwordEncrypted = encrypt(password) else {
            statusLabel.stringValue = "Can not prepare registration data. Report bug."
            return
        }
        
        sendRegistrationData(email, passwordEncrypted, accountType)
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
    
    func isAlphanumeral(_ testStr: String) -> Bool {
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        
        if testStr.rangeOfCharacter(from: letters) != nil && testStr.rangeOfCharacter(from: digits) != nil {
            return true
        } else {
            return false
        }
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
    
    func encrypt(_ str: String) -> String? {
        return aesEncrypt(str, GlobalAESKey, GlobalAESIV)
    }
    
    func sendRegistrationData(_ email: String, _ encryptedPassword: String, _ accountType: Int) {
        statusLabel.stringValue = "Registering..."
        
        let urlString = MainServerAddress + "/login/register.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "register=1&type=\(accountType)&password=\(encryptedPassword)&email=\(email)"
        //let postStringEscaped = postString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        //request.httpBody = postStringEscaped?.data(using: .utf8)
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
                    if reason == 1 {
                        self.statusLabel.stringValue = "Account already exist"
                    } else if reason == 2 {
                        self.statusLabel.stringValue = "Please activate account. Don't register again."
                    }
                    return
                }
            }
            
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    let window = self.view.window?.windowController as! LoginWindowController
                    window.registerFinished(withEmail: email)
                }
            }
        }
        dataTask.resume()
    }
}
