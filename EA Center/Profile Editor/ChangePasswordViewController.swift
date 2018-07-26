//
//  ChangePasswordViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UITableViewController {
    @IBOutlet weak var oldPassTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    
    var saving: Bool = false
    
    var currentAccount: UserAccount?
    
    @IBOutlet weak var saveLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
        
        oldPassTextField.delegate = self
        newPassTextField.delegate = self
        confirmTextField.delegate = self
    }

    // MARK: - Table view data source and delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 && !saving {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Save
        login()
    }
    
    func login() {
        if newPassTextField.text! == "" || oldPassTextField.text! == "" || confirmTextField.text! == "" {
            showAlert("Error", "Please fill out the form.")
            return
        }
        
        let oldPass = oldPassTextField.text!
        let newPass = newPassTextField.text!
        guard newPass.count >= 8 else {
            showAlert("Error", "New password length must be greater than 8.")
            return
        }
        
        guard AccountProcessor.isAlphanumeral(newPass) else {
            showAlert("Error", "New password must be alphanumeral.")
            return
        }
        
        let confirmNewPass = confirmTextField.text!
        guard confirmNewPass == newPass else {
            showAlert("Error", "Confirm password is invalid.")
            return
        }
        
        let newPassEnc = AccountProcessor.encrypt(newPass)!
        let oldPassEnc = AccountProcessor.encrypt(oldPass)!
        
        saving = true
        saveLabel.text = "Saving..."
        
        currentAccount!.updatePassword(oldPassEnc, newPassEnc) { (success, errStr) in
            if success {
                self.saving = false
                
                let email = UserDefaults.standard.string(forKey: "loginemail")
                
                let passwordData = newPass.data(using: .utf8)!
                let _ = KeychainHelper.deleteKeychain(account: email!)
                let success = KeychainHelper.saveKeychain(account: email!, password: passwordData)
                if success == true {
                    //UserDefaults.standard.set(email, forKey: "LoginEmail")
                    // Save Password Good :)
                } else {
                    UserDefaults.standard.set(false, forKey: "rememberlogin")
                }
                
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert("Can not update password", errStr!)
                
                self.saveLabel.text = "Save"
                
                return
            }
        }
        
        saving = true
    }
    
    func showAlert(_ title: String, _ message: String) {
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

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPassTextField && oldPassTextField.text!.count > 0 {
            newPassTextField.becomeFirstResponder()
        } else if textField == newPassTextField && newPassTextField.text!.count > 0 {
            confirmTextField.becomeFirstResponder()
        } else if textField == confirmTextField && confirmTextField.text!.count > 0 {
            login()
        }
        return true
    }
}
