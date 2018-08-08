//
//  EALeadersViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EALeadersViewController: UITableViewController {
    var currentEA: EnrichmentActivity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")!
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentEA!.leaderEmails.count
        } else if section == 1 {
            if currentEA!.supervisorEmails.count == 0 {
                return 1
            } else {
                return currentEA!.supervisorEmails.count
            }
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let bgView = UIView()
        bgView.backgroundColor = UIColor(named: "Menu Color")
        let headerFooterView = view as! UITableViewHeaderFooterView
        headerFooterView.backgroundView = bgView
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Leaders"
        } else if section == 1 {
            return "Supervisors"
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && currentEA!.supervisorEmails.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NoSupervisorCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderCell", for: indexPath)

        // Configure the cell...
        
        if indexPath.section == 0 {
            let leaderEmail = currentEA!.leaderEmails[indexPath.row]
            cell.detailTextLabel?.text = leaderEmail
            cell.textLabel?.text = "Loading name..."
            
            AccountProcessor.name(from: leaderEmail) { (name) in
                if let leaderName = name {
                    if leaderName == "" {
                        cell.textLabel?.text = "Name not set"
                    } else {
                        cell.textLabel?.text = leaderName
                    }
                } else {
                    cell.textLabel?.text = "Failed retriving name"
                }
            }
        } else if indexPath.section == 1 {
            let supervisorEmail = currentEA!.supervisorEmails[indexPath.row]
            cell.detailTextLabel?.text = supervisorEmail
            cell.textLabel?.text = "Loading name..."
            
            AccountProcessor.name(from: supervisorEmail) { (name) in
                if let supervisorName = name {
                    if supervisorName == "" {
                        cell.textLabel?.text = "Name not set"
                    } else {
                        cell.textLabel?.text = supervisorName
                    }
                } else {
                    cell.textLabel?.text = "Failed retriving name"
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            
            if indexPath.section == 0 {
                let leader = currentEA?.leaderEmails[indexPath.row]
                currentEA?.deleteLeader(email: leader!, isSupervisor: false, completion: { (success, errStr) in
                    if success {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        self.showAlert("Can not delete leader", errStr!)
                    }
                })
            } else if indexPath.section == 1 {
                let supervisor = currentEA?.supervisorEmails[indexPath.row]
                currentEA?.deleteLeader(email: supervisor!, isSupervisor: true, completion: { (success, errStr) in
                    if success {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        self.showAlert("Can not delete supervisor", errStr!)
                    }
                })
            }
        }
    }

    @IBAction func addLeader(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Add Leader", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "AddLeader", sender: action)
        }))
        actionSheet.addAction(UIAlertAction(title: "Add Supervisor", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "AddSupervisor", sender: action)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "AddLeader" {
            let dest = segue.destination as! AddLeaderViewController
            dest.currentEA = currentEA
            dest.updateMode = 1
            dest.delegate = self
        } else if segue.identifier == "AddSupervisor" {
            let dest = segue.destination as! AddLeaderViewController
            dest.currentEA = currentEA
            dest.updateMode = 2
            dest.delegate = self
        }
    }
}

extension EALeadersViewController: AddLeaderViewControllerDelegate {
    func addLeaderViewController(_ controller: AddLeaderViewController, didFinishWith account: UserAccount) {
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
        NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedea":self.currentEA])
    }
}
