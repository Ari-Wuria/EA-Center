//
//  BugReportViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/11.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class BugReportViewController: NSViewController {
    var currentAccount: UserAccount?
    
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var emailTextField: NSTextField!
    @IBOutlet weak var systemPopup: NSPopUpButton!
    @IBOutlet weak var issueTextField: NSTextField!
    @IBOutlet weak var charCountLabel: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        issueTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: LogoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(login(_:)), name: LoginSuccessNotification, object: nil)
    }
    
    @objc func logout() {
        currentAccount = nil
        
        updateAccountField()
    }
    
    @objc func login(_ notification: Notification) {
        let obj = notification.object as! [String:Any]
        let account = obj["account"] as! UserAccount
        currentAccount = account
        
        updateAccountField()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        updateAccountField()
        
        view.window?.isMovableByWindowBackground = true
    }
    
    func updateAccountField() {
        if let account = currentAccount {
            emailTextField.isHidden = true
            emailLabel.isHidden = false
            emailLabel.stringValue = account.userEmail
        } else {
            emailLabel.isHidden = true
            emailTextField.isHidden = false
            emailTextField.stringValue = ""
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        let email: String
        if let account = currentAccount {
            email = account.userEmail
        } else {
            let emailText = emailTextField.stringValue
            guard emailText.count > 0 else {
                showAlert(withTitle: "Please enter an email", message: nil)
                return
                
            }
            guard AccountProcessor.isValidEmail(emailText) else {
                showAlert(withTitle: "Please use valid email", message: nil)
                return
            }
            email = emailText
        }
        
        let message = issueTextField.stringValue
        guard message.count > 0 else {
            showAlert(withTitle: "Please enter your issue", message: nil)
            return
        }
        
        guard message.count < 1000 else {
            showAlert(withTitle: "Please keep the length of bug report under 1000 characters", message: nil)
            return
        }
        
        let system = systemPopup.indexOfSelectedItem == 0 ? "macOS" : "iOS"
        
        // TODO: Send data
        
        spinner.startAnimation(sender)
        
        let serverURL = MainServerAddress + "/reportbug.php"
        var request = URLRequest(url: URL(string: serverURL)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "issue=\(message)&email=\(email)&system=\(system)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(nil)
                }
            }
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    //completion(false, -1, error!.localizedDescription)
                    self.showAlert(withTitle: "Error", message: error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                    self.showAlert(withTitle: "Can not retrive EA", message: "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let output = String(data: data!, encoding: .utf8)
            if output == "1" {
                // Success
                //print("Bug Report Uploaded")
                DispatchQueue.main.async {
                    self.showAlert(withTitle: "Bug report uploaded", message: "I will make the completion screen later")
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(withTitle: "Error uploading bug report", message: output)
                }
            }
        }
        dataTask.resume()
    }
    
    func showAlert(withTitle title: String, message: String?) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message ?? ""
        alert.runModal()
    }
}

extension BugReportViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        if textField == issueTextField {
            let count = issueTextField.stringValue.count
            charCountLabel.stringValue = "\(abs(1000 - count))"
            if count > 1000 {
                charCountLabel.textColor = .red
            } else {
                charCountLabel.textColor = .labelColor
            }
        }
    }
}
