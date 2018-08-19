//
//  AttendenceCell.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class AttendenceCell: UITableViewCell {
    @IBOutlet weak var studentNameLabel: UILabel!
    
    @IBOutlet weak var attendenceSegmentedControl: UISegmentedControl!
    
    // Reserve for a spinner
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var studentAccount: UserAccount!
    var currentEA: EnrichmentActivity!
    
    var attendanceDate: Date!
    
    var errorHandler: ((String) -> ())?
    
    lazy var dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        attendenceSegmentedControl.selectedSegmentIndex = -1
    }

    @IBAction func markAttendance(_ sender: Any) {
        //print("Set attendance for \(studentAccount)")
        
        let segmentedControl = sender as! UISegmentedControl
        let attendanceCode: String
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            attendanceCode = "A"
        case 1:
            attendanceCode = "P"
        case 2:
            attendanceCode = "L"
        default:
            attendanceCode = "U"
        }
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        let nextDateString = dateFormatter.string(from: attendanceDate)
        let currentDateString = dateFormatter.string(from: Date())
        
        guard nextDateString == currentDateString else {
            errorHandler?("This session had already passed")
            segmentedControl.selectedSegmentIndex = -1
            return
        }
        
        //spinner.startAnimation(sender)
        currentEA.uploadAttendence(attendanceDate, attendanceCode, studentAccount.userID, true) { (success, errStr) in
            if success {
                // Success
                //self.spinner.stopAnimation(nil)
            } else {
                // Error, handle it
                self.errorHandler?(errStr!)
                
                self.attendenceSegmentedControl.selectedSegmentIndex = -1
                
                //self.spinner.stopAnimation(nil)
            }
        }
    }
}
