//
//  CoordinatorDetailViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/22.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class CoordinatorDetailViewController: NSViewController {
    var currentEA: EnrichmentActivity?
    
    @IBOutlet weak var weekLabel: NSTextField!
    @IBOutlet weak var daysLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var gradeLabel: NSTextField!
    @IBOutlet weak var datesLabel: NSTextField!
    @IBOutlet weak var shortDescLabel: NSTextField!
    
    @IBOutlet weak var approveButton: NSButton!
    @IBOutlet weak var rejectButton: NSButton!
    
    lazy var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func updateInfo(with ea: EnrichmentActivity) {
        currentEA = ea
        
        let daysString = ea.days.map { (day) -> String in
            switch day {
            case 1:
                return "Mon"
            case 2:
                return "Tues"
            case 3:
                return "Weds"
            case 4:
                return "Thurs"
            case 5:
                return "Fri"
            default:
                return "Err"
            }
        }
        
        weekLabel.stringValue = ea.weekModeForDisplay()
        //daysLabel.stringValue = "I'll find a way to display this..."
        daysLabel.stringValue = daysString.count > 0 ? daysString.joined(separator: ",") : "No day selected"
        timeLabel.stringValue = ea.timeModeForDisplay()
        locationLabel.stringValue = (ea.location.count > 0) ? ea.location : "Location Unspecified"
        gradeLabel.stringValue = "Grade \(ea.minGrade) - \(ea.maxGrade)"
        //datesLabel.stringValue = "Formatted date"
        shortDescLabel.stringValue = ea.shortDescription
        
        let startDate = dateFormatter.string(from: ea.startDate!)
        let endDate = dateFormatter.string(from: ea.endDate!)
        datesLabel.stringValue = "\(startDate) - \(endDate)"
        
        approveButton.isEnabled = true
        rejectButton.isEnabled = true
    }
    
    @IBAction func viewPoster(_ sender: Any) {
        // Used storyboard segue
    }
    
    @IBAction func approve(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "Are you sure you want to approve this EA for running? You can't undo this action."
        alert.addButton(withTitle: "Approve this EA!")
        //approveButton.target = self
        //approveButton.action = #selector(approveEA)
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: view.window!) { (response) in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.approveEA()
            }
        }
    }
    
    func approveEA() {
        currentEA?.updateApprovalState(2) { (success, errStr) in
            if success {
                NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedEA":self.currentEA!, "id":self.currentEA!.id])
                
                self.approveButton.isEnabled = false
                self.rejectButton.isEnabled = false
                
                let alert = NSAlert()
                alert.messageText = "Success"
                alert.runModal()
            } else {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = errStr!
                alert.runModal()
            }
        }
    }
    
    @IBAction func reject(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "Are you sure you want to reject this EA? You can't undo this action."
        alert.addButton(withTitle: "Reject")
        //rejectButton.target = self
        //rejectButton.action = #selector(rejectEA)
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: view.window!) { (response) in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.rejectEA()
            }
        }
    }
    
    @objc func rejectEA() {
        currentEA?.updateApprovalState(4) { (success, errStr) in
            if success {
                NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedEA":self.currentEA!, "id":self.currentEA!.id])
                
                self.approveButton.isEnabled = false
                self.rejectButton.isEnabled = false
                
                let alert = NSAlert()
                alert.messageText = "Success"
                alert.runModal()
            } else {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = errStr!
                alert.runModal()
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPoster" {
            let dest = segue.destinationController as! ViewDescriptionViewController
            dest.currentEA = currentEA!
        }
    }
    
    deinit {
        print("deinit: \(self)")
    }
}
