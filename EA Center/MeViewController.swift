//
//  MeViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/30.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol MeSplitViewControlling: class {
    // Mode:
    // 1: Profile
    // 2: Settings
    // 3: Student Bulletin
    // 4: My EAs
    // 5: Register (Coming soon...)
    func meViewRequestSplitViewDetail(_ controller: MeViewController, mode: Int)
    func currentSplitViewDetail(_ controller: MeViewController) -> UIViewController
}

class MeViewController: UITableViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentUserAccount: UserAccount?
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    
    var loggedIn: Bool = false
    
    weak var splitViewControllingDelegate: MeSplitViewControlling?
    
    weak var splitViewDetail: UIViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let rememberLogin = UserDefaults.standard.bool(forKey: "rememberlogin")
        let passwordChanged = UserDefaults.standard.bool(forKey: "passwordchanged")
        if rememberLogin && !passwordChanged {
            // Retrive email from keyhain
            let email = UserDefaults.standard.object(forKey: "loginemail") as? String
            if let email = email, email != "" {
                let password = KeychainHelper.loadKeychain(account: email)
                if password != nil {
                    let passwordString = String(data: password!, encoding: .utf8)!
                    login(withEmail: email, password: passwordString, automatic: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.isHidden = true
        classLabel.isHidden = true
        
        let profileCell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
        profileCell.isHidden = true
        updateTableView()
        
        if loggedIn {
            updateLoginUI(account: currentUserAccount!)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //tableView.deleteSections(IndexSet(integer: 1), with: .none)
    }
    
    @objc func endEditing() {
        view.endEditing(true)
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
        if indexPath.section == 0 && indexPath.row == 1 {
            if currentUserAccount == nil {
                login(withEmail: emailTextField.text!, password: passwordTextField.text!)
            } else {
                // Logout
                NotificationCenter.default.post(name: LogoutNotification, object: nil)
                
                let loginCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
                loginCell.textLabel?.text = "Login"
                let registerCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 2, section: 0))
                registerCell.isHidden = false
                let profileCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 0, section: 1))
                profileCell.isHidden = true
                self.updateTableView()
                
                self.usernameLabel.isHidden = true
                self.classLabel.isHidden = true
                self.emailTextField.isHidden = false
                self.passwordTextField.isHidden = false
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.emailTextField.becomeFirstResponder()
                
                UserDefaults.standard.set("", forKey: "loginemail")
                UserDefaults.standard.synchronize()
                let _ = KeychainHelper.deleteKeychain(account: currentUserAccount!.userEmail)
                
                currentUserAccount = nil
                
                if let settingsWindow = splitViewControllingDelegate?.currentSplitViewDetail(self) as? SettingsViewController {
                    settingsWindow.loggedIn = false
                    settingsWindow.userAccount = nil
                    settingsWindow.updateUI()
                }
            }
        } else if indexPath.section == 0 && indexPath.row == 2 {
            // Register
            let alert = UIAlertController(title: "Error Registering Account", message: "Reason: This feature haven't been implemented by the developer yet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.presentAlert("Hahahaha", "Did I tried to make that error really serious? Lol")
            }))
            present(alert, animated: true, completion: nil)
            
            let email = emailTextField.text!
            guard AccountProcessor.validateEmail(email) else {
                presentAlert("Invalid Email", "Please use valid BCIS Email")
                return
            }
            
            // TODO: Complete register
            //let password = passwordTextField.text!
        } else if indexPath.section == 1 && indexPath.row == 0 {
            // Profile
            if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
                performSegue(withIdentifier: "EditProfile", sender: nil)
            } else {
                performSegue(withIdentifier: "EditProfileReplace", sender: nil)
                splitViewControllingDelegate?.meViewRequestSplitViewDetail(self, mode: 1)
                (splitViewDetail as! ProfileEditorViewController).userAccount = currentUserAccount
                
                if splitViewController!.displayMode != .allVisible {
                    // Temporary fix for segue animation
                    delay(0.01) {
                        self.hideMasterPane()
                    }
                }
                return
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
                performSegue(withIdentifier: "ViewSettings", sender: nil)
            } else {
                performSegue(withIdentifier: "ViewSettingsReplace", sender: nil)
                splitViewControllingDelegate?.meViewRequestSplitViewDetail(self, mode: 2)
                (splitViewDetail as! SettingsViewController).userAccount = currentUserAccount
                (splitViewDetail as! SettingsViewController).loggedIn = loggedIn
                
                if splitViewController!.displayMode != .allVisible {
                    // Temporary fix for segue animation
                    delay(0.01) {
                        self.hideMasterPane()
                    }
                }
                return
            }
        } else if indexPath.section == 2 && indexPath.row == 0 {
            if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
                performSegue(withIdentifier: "ShowSB", sender: nil)
            } else {
                performSegue(withIdentifier: "ShowSBReplace", sender: nil)
                splitViewControllingDelegate?.meViewRequestSplitViewDetail(self, mode: 3)
                
                if splitViewController!.displayMode != .allVisible {
                    // Temporary fix for segue animation
                    delay(0.01) {
                        self.hideMasterPane()
                    }
                }
                return
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func presentAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: UITableViewCell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell.isHidden ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
    }

    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func login(withEmail email: String, password: String, automatic: Bool = false) {
        guard AccountProcessor.validateEmail(email) else {
            presentAlert("Invalid Email", "Please use valid BCIS Email")
            return
        }
        
        let encryptedPass = AccountProcessor.encrypt(password)!
        
        AccountProcessor.sendLoginRequest(email, encryptedPass) { (success, errCode, errStr) in
            if success == true {
                //self.presentAlert("You're now logged in", "Nothing else for now :)")
                let userID = errCode
                AccountProcessor.retriveUserAccount(from: userID!, completion: { (account, errCode, errString) in
                    if let resultAccount = account {
                        self.loggedIn = true
                        
                        self.currentUserAccount = resultAccount
                        
                        if self.viewIfLoaded != nil {
                            self.updateLoginUI(account: account!)
                        }
                        
                        UserDefaults.standard.set(false, forKey: "passwordchanged")
                        
                        NotificationCenter.default.post(name: LoginSuccessNotification, object: ["account":resultAccount])
                        
                        let rememberLogin = UserDefaults.standard.bool(forKey: "rememberlogin")
                        if rememberLogin {
                            let success = KeychainHelper.saveKeychain(account: email, password: password.data(using: .utf8)!)
                            if success {
                                UserDefaults.standard.set(true, forKey: "rememberlogin")
                                UserDefaults.standard.set(email, forKey: "loginemail")
                            }
                        }
                        UserDefaults.standard.synchronize()
                        
                        if let settingsWindow = self.splitViewControllingDelegate?.currentSplitViewDetail(self) as? SettingsViewController {
                            settingsWindow.loggedIn = true
                            settingsWindow.userAccount = self.currentUserAccount
                            settingsWindow.updateUI()
                        }
                    } else {
                        switch errCode {
                        case -1:
                            // Error
                            self.presentAlert("Error logging in", errStr!)
                        case -2, -3:
                            // -2: Wrong Status Code
                            // -3: No JSON data
                            self.presentAlert("Error logging in", "Reason: \(errStr!)")
                        default: break
                        }
                    }
                })
            } else {
                switch errCode {
                case -1:
                    // Error
                    self.presentAlert("Error logging in", errStr!)
                case -2, -3:
                    // -2: Wrong Status Code
                    // -3: No JSON data
                    self.presentAlert("Error logging in", "Reason: \(errStr!)")
                case 1, 3:
                    // 1: Wrong password
                    // 3: Account don't exist
                    if automatic {
                        if errCode == 1 {
                            self.presentAlert("Password Change Detected", "Please login manually.")
                            UserDefaults.standard.set(true, forKey: "passwordchanged")
                            UserDefaults.standard.synchronize()
                        } else {
                            self.presentAlert("Can not auto login", "Please login manually.")
                        }
                    } else {
                        self.presentAlert("Invalid Username or Password", "Please try again.")
                    }
                case 2:
                    // No activation
                    self.presentAlert("Not Activated", "Did you forgot to activate your account?")
                    
                default: break
                }
            }
        }
    }
    
    func updateLoginUI(account: UserAccount) {
        self.usernameLabel.isHidden = false
        self.classLabel.isHidden = false
        self.emailTextField.isHidden = true
        self.passwordTextField.isHidden = true
        self.usernameLabel.text = (account.username != "") ? account.username : account.userEmail
        if account.grade != 0 && account.classInitial.count >= 2 {
            self.classLabel.text = "\(account.grade)\(account.classInitial)"
        } else {
            self.classLabel.text = "Class Not Set"
        }
        
        let loginCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        loginCell.textLabel?.text = "Logout"
        let registerCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        registerCell.isHidden = true
        let profileCell = self.tableView(self.tableView, cellForRowAt: IndexPath(row: 0, section: 1))
        profileCell.isHidden = false
        self.updateTableView()
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EditProfile" {
            let nav = segue.destination as! UINavigationController
            let dest = nav.topViewController as! ProfileEditorViewController
            dest.userAccount = currentUserAccount
        } else if segue.identifier == "ViewSettings" {
            let dest = segue.destination as! SettingsViewController
            dest.userAccount = currentUserAccount
            dest.loggedIn = loggedIn
        } 
    }
    
    @IBAction func profileCanceled(_ sender: UIStoryboardSegue) {
    }
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
    }

}

extension MeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            if emailTextField.text == "" {
                return true
            }
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            if emailTextField.text == "" {
                return true
            }
            login(withEmail: emailTextField.text!, password: passwordTextField.text!)
        }
        return true
    }
}
