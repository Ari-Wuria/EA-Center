//
//  AttendenceCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/7.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AttendenceCellView: NSTableCellView {
    @IBOutlet var attendenceSegmentControl: NSSegmentedControl!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    var attendenceStudentID: Int!
    var currentEA: EnrichmentActivity!
    var attendanceDate: Date!
    
    var attendenceEnabled = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        spinner.stopAnimation(nil)
    }
    
    @IBAction func attendenceChanged(_ sender: Any) {
        print("Attendence Changed: \(attendenceStudentID ?? 0)")
        
        // TODO: Make the request
        
        let segmentedControl = sender as! NSSegmentedControl
        let attendanceCode: String
        switch segmentedControl.selectedSegment {
        case 0:
            attendanceCode = "A"
        case 1:
            attendanceCode = "P"
        case 2:
            attendanceCode = "L"
        default:
            attendanceCode = "U"
        }
        //spinner.startAnimation(sender)
        currentEA.uploadAttendence(attendanceDate, attendanceCode, attendenceStudentID, true) { (success, errStr) in
            if success {
                // Success
                //self.spinner.stopAnimation(nil)
            } else {
                // Error, handle it
                let alert = NSAlert()
                alert.messageText = "Error setting attendance"
                alert.informativeText = errStr!
                alert.runModal()
                
                segmentedControl.selectedSegment = -1
                
                //self.spinner.stopAnimation(nil)
            }
        }
    }
    
    override func prepareForReuse() {
        attendenceSegmentControl.selectedSegment = -1
    }
}
