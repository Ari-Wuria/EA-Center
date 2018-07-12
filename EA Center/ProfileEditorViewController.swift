//
//  ProfileEditorViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class ProfileEditorViewController: UITableViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var classTextField: UITextField!
    
    var userAccount: UserAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailLabel.text = userAccount?.userEmail
        nameTextField.text = userAccount?.username
        if userAccount?.grade != 0 {
            classTextField.text = "\(userAccount!.grade)\(userAccount!.classInitial)"
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && indexPath.row == 0 {
            return indexPath
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 {
            // Save
            let username = nameTextField.text!
            if username.count == 0 {
                presentAlert("Error", "Please enter your name")
                return
            }
            
            let advisory = classTextField.text!.uppercased().filter{"01234567890QWERTYUIOPASDFGHJKLZXCVBNM".contains($0)}
            classTextField.text = advisory
            if validateClass(advisory) == false {
                presentAlert("Error", "Invalid Advisory")
                return
            }
            
            let stringArray = advisory.components(separatedBy: CharacterSet.decimalDigits.inverted)
            var numberArray: [Int] = []
            for item in stringArray {
                if let number = Int(item) {
                    numberArray.append(number)
                }
            }
            let grade = numberArray[0]
            let classInitial = advisory.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789"))
            userAccount?.updateInfo(username, grade, classInitial) { (success, errString) in
                if self.presentingViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                if success {
                    self.presentAlert("Success!", "Account info updated") { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.presentAlert("Can not update info", errString!)
                }
                tableView.deselectRow(at: indexPath, animated: true)
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
    
    func presentAlert(_ title: String, _ message: String, _ handler: @escaping (UIAlertAction) -> () = {_ in}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
