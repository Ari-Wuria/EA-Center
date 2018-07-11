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
    
    @IBOutlet var rememberSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rememberSwitch.isOn = loggedIn
        
        if loggedIn == true {
            rememberSwitch.isEnabled = false
        }
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
        }
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
