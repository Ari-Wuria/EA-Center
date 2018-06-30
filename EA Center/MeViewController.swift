//
//  MeViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/30.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class MeViewController: UITableViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.deleteSections(IndexSet(integer: 1), with: .none)
    }

    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 && indexPath.row == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 1 {
            // Login
            let email = emailTextField.text!
            guard AccountProcessor.validateEmail(email) else {
                presentAlert("Invalid Email", "Please use valid BCIS Email")
                return
            }
            
            let password = passwordTextField.text!
            let encryptedPass = AccountProcessor.encrypt(password)!
            
            AccountProcessor.sendLoginRequest(email, encryptedPass) { (success, errCode, errStr) in
                if success == true {
                    self.presentAlert("You're now logged in", "Nothing else for now :)")
                } else {
                    switch errCode {
                    case -1:
                        // Error
                        self.presentAlert("Error", errStr!)
                    case -2, -3:
                        // -2: Wrong Status Code
                        // -3: No JSON data
                        self.presentAlert("Error", "Reason: \(errStr!)")
                    case 1, 3:
                        // 1: Wrong password
                        // 3: Account don't exist
                        self.presentAlert("Invalid Username or Password", "Please try again.")
                    case 2:
                        // No activation
                        self.presentAlert("Not Activated", "Did you forgot to activate your account?")
                        
                    default: break
                    }
                }
            }
        } else if indexPath.section == 0 && indexPath.row == 2 {
            // Register
            let alert = UIAlertController(title: "Error Registering Account", message: "Reason: This feature haven't been implemented by the developer yet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.presentAlert("Hahahaha", "Did I tried to make that error really serious? Lol")
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func presentAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
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
