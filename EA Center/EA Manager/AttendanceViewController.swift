//
//  AttendanceViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/6.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class AttendanceViewController: UITableViewController {
    var currentEA: EnrichmentActivity!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentEA.joinedUserID!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendenceCell

        // Configure the cell...
        
        cell.studentNameLabel.text = "Loading name..."
        let userID = currentEA.joinedUserID![indexPath.row]
        AccountProcessor.retriveUserAccount(from: userID) { (account, errCode, errStr) in
            if let account = account {
                if account.username != "" {
                    cell.studentNameLabel.text = account.username
                } else {
                    cell.studentNameLabel.text = account.userEmail
                }
            } else {
                cell.studentNameLabel.text = "Error retriving name."
                cell.attendenceSegmentedControl.isHidden = true
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    /*
    // Override to support editing the table view.
     // TODO: Consider adding remove student feature here.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
