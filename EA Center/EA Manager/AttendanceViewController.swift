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

    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    var nextSessionDate: Date!
    
    lazy var dateFormatter = DateFormatter()
    
    var attendenceEnabled = false
    
    var noWeekSession = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let date = Date()
        let days = currentEA!.days
        var weekSessionDates = [Date]()
        for day in days {
            weekSessionDates.append(date.next(date.weekdayFromInt(day)!, considerToday: true))
        }
        weekSessionDates.sort { (date1, date2) -> Bool in
            return date1 < date2
        }
        
        noWeekSession = false
        
        if !(currentEA.approved == 2 || currentEA.approved == 3) || currentEA.endDate! < Date() {
            sessionInfoLabel.text = "EA not approved or is already over :("
            attendenceEnabled = false
            return
        }
        
        if weekSessionDates.count == 0 {
            sessionInfoLabel.text = "Please select running days"
            attendenceEnabled = false
            noWeekSession = true
            return
        }
        
        let earliest = weekSessionDates[0]
        
        nextSessionDate = earliest
        
        let nextSessionStr = dateFormatter.string(from: nextSessionDate)
        let currentStr = dateFormatter.string(from: Date.today())
        let prefix: String
        if nextSessionStr == currentStr {
            prefix = "Today's session: "
            attendenceEnabled = true
        } else {
            prefix = "Next session: "
            attendenceEnabled = false
        }
        sessionInfoLabel.text = prefix + nextSessionStr
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
        cell.attendenceSegmentedControl.isHidden = true
        
        let dates = self.currentEA!.todayAttendenceList!
        
        let userID = currentEA.joinedUserID![indexPath.row]
        AccountProcessor.retriveUserAccount(from: userID) { (account, errCode, errStr) in
            if let account = account {
                if account.username != "" {
                    cell.studentNameLabel.text = account.username
                } else {
                    cell.studentNameLabel.text = account.userEmail
                }
                cell.attendenceSegmentedControl.isHidden = false
                cell.studentAccount = account
                cell.currentEA = self.currentEA
                
                cell.attendenceSegmentedControl.isEnabled = self.attendenceEnabled
                
                // Filter dates to fill in existing attendance data
                let filtered = dates.filter { (attendance) -> Bool in
                    if attendance.studentID == account.userID {
                        return true
                    } else {
                        return false
                    }
                }
                if filtered.count == 1 {
                    let attendance = filtered.first!
                    cell.attendenceSegmentedControl.selectedSegmentIndex = attendance.attendanceStatus
                }
                
                cell.attendanceDate = self.nextSessionDate
                
                cell.errorHandler = { errStr in
                    let alert = UIAlertController(title: "Error setting attendance", message: errStr, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    
    deinit {
        print("deinit \(self)")
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
