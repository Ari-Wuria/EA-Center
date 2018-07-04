//
//  AccountSettingsViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AccountSettingsViewController: NSViewController {
    var userAccount: UserAccount?

    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var classTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var emailLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        emailLabel.stringValue = userAccount!.userEmail
        if userAccount!.grade >= 6 && userAccount!.grade <= 12 && userAccount!.classInitial != "" {
            classTextField.stringValue = "\(userAccount!.grade)\(userAccount!.classInitial)"
        }
        usernameTextField.stringValue = userAccount!.username
        statusLabel.isHidden = true
    }
    
    @IBAction func updateInfo(_ sender: Any) {
        let newUsername = usernameTextField.stringValue
        if newUsername.count == 0 {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Please enter a valid name"
            return
        }
        
        let newClass = classTextField.stringValue.uppercased().filter{"01234567890QWERTYUIOPASDFGHJKLZXCVBNM".contains($0)}
        //let newClass = classTextField.stringValue
        classTextField.stringValue = newClass
        if validateClass(newClass) == false {
            statusLabel.isHidden = false
            statusLabel.stringValue = "Invalid class"
            return
        }
        
        let stringArray = newClass.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var numberArray: [Int] = []
        for item in stringArray {
            if let number = Int(item) {
                numberArray.append(number)
            }
        }
        let grade = numberArray[0]
        let classInitial = newClass.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789"))
        
        userAccount?.updateInfo(newUsername, grade, classInitial) { (success, errString) in
            if success {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = "Success!"
            } else {
                self.statusLabel.isHidden = false
                self.statusLabel.stringValue = "Error!"
                print(errString!)
            }
        }
    }
    
    func validateClass(_ str: String) -> Bool {
        // Check length
        guard str.count == 3 || str.count == 4 || str.count == 5 else {
            return false
        }
        // Check character position
        let digits = NSCharacterSet.decimalDigits
        var count = 0
        for ch in str.unicodeScalars {
            if digits.contains(ch) {
                if count != 0 && count != 1 {
                    return false
                }
            } else {
                if count != 1 && count != 2 && count != 3 && count != 4 {
                    return false
                }
            }
            count += 1
        }
        // Check grade number and class format
        let stringArray = str.components(separatedBy: CharacterSet.decimalDigits.inverted)
        var numberArray: [Int] = []
        var letterArray: [String] = []
        for item in stringArray {
            if let number = Int(item) {
                numberArray.append(number)
            } else {
                letterArray.append(item)
            }
        }
        guard numberArray.count == 1 && numberArray[0] >= 6 && numberArray[0] <= 12 && letterArray.count <= 3 else {
            return false
        }
        
        return true
    }
}
