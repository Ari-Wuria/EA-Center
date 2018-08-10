//
//  SettingsViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/11.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    var loggedIn: Bool = false
    var userAccount: UserAccount? = nil
    
    let authenticator = BiometricAuth()
    
    @IBOutlet var rememberSwitch: UISwitch!
    @IBOutlet weak var biometricSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rememberSwitch.isOn = UserDefaults.standard.bool(forKey: "rememberlogin")
        biometricSwitch.isOn = UserDefaults.standard.bool(forKey: "biometriclock")
        
        if authenticator.canEvaluatePolicy() == false {
            biometricSwitch.isEnabled = false
        }
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //updateBiometricLabel()
    }
    
    func updateUI() {
        rememberSwitch.isEnabled = !loggedIn
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func setRememberLogin(_ sender: Any) {
        let rememberSwitch = sender as! UISwitch
        UserDefaults.standard.set(rememberSwitch.isOn, forKey: "rememberlogin")
        if rememberSwitch.isOn == false {
            UserDefaults.standard.set("", forKey: "loginemail")
            if let account = userAccount {
                let _ = KeychainHelper.deleteKeychain(account: account.userEmail)
            }
            UserDefaults.standard.synchronize()
        }
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func setBiometric(_ sender: Any) {
        let rememberSwitch = sender as! UISwitch
        UserDefaults.standard.set(rememberSwitch.isOn, forKey: "biometriclock")
        UserDefaults.standard.synchronize()
    }
    /*
    func updateBiometricLabel() {
        let authenticator = BiometricAuth()
        let newText: String
        let supported = authenticator.canEvaluatePolicy()
        if supported {
            newText = "Turn on to secure EASLINK with biometric"
        } else {
            newText = "Biometric not supported on this device"
            biometricSwitch.isEnabled = false
        }
        let label = tableView.footerView(forSection: 0)?.textLabel
        label?.text = newText
        let newSize = newText.size(withAttributes: [NSAttributedString.Key.font:label?.font as Any])
        let newSizeAdjusted = CGSize(width: ceil(Double(newSize.width)), height: ceil(Double(newSize.height)))
        label?.frame.size = newSizeAdjusted
    }*/
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell: UITableViewCell = super.tableView(tableView, cellForRowAt: indexPath)
        return cell.isHidden ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            let newText: String
            let supported = authenticator.canEvaluatePolicy()
            if supported {
                newText = "Turn on to secure EASLINK with biometric"
            } else {
                newText = "Biometric not supported on this device"
                biometricSwitch.isEnabled = false
            }
            return newText
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if view is UITableViewHeaderFooterView {
            let footerView = view as! UITableViewHeaderFooterView
            let newText: String
            let supported = authenticator.canEvaluatePolicy()
            if supported {
                newText = "Turn on to secure EASLINK with biometric"
            } else {
                newText = "Biometric not supported on this device"
                biometricSwitch.isEnabled = false
            }
            footerView.textLabel?.text = newText
        }
    }
    
    deinit {
        print("deinit \(self)")
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
