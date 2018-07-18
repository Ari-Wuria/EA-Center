//
//  MainInfoEditorViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class MainInfoEditorViewController: NSViewController {
    
    @IBOutlet weak var weekSelector: NSPopUpButton!
    @IBOutlet weak var timeSelector: NSPopUpButton!
    @IBOutlet weak var locationTextField: NSTextField!
    @IBOutlet weak var minGradeSelector: NSPopUpButton!
    @IBOutlet weak var maxGradeSelector: NSPopUpButton!
    
    @IBOutlet weak var mondayCheckbox: NSButton!
    @IBOutlet weak var tuesdayCheckbox: NSButton!
    @IBOutlet weak var wednesdayCheckbox: NSButton!
    @IBOutlet weak var thursdayCheckbox: NSButton!
    @IBOutlet weak var fridayCheckbox: NSButton!
    
    @IBOutlet weak var shortDescTextView: NSTextView!
    @IBOutlet weak var proposalTextView: NSTextView!
    
    var currentEA: EnrichmentActivity?
    
    var currentLoginEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer = CALayer()
        //view.layer?.backgroundColor = CGColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
        
        //shortDescTextView.isHorizontallyResizable = false
        //shortDescTextView.textContainer?.widthTracksTextView = true
    }
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        
        weekSelector.selectItem(at: ea.weekMode - 1)
        timeSelector.selectItem(at: ea.timeMode - 1)
        locationTextField.stringValue = ea.location
        minGradeSelector.selectItem(at: ea.minGrade - 6)
        maxGradeSelector.selectItem(at: ea.maxGrade - 6)
        
        shortDescTextView.string = ea.shortDescription
        proposalTextView.string = ea.proposal
        
        mondayCheckbox.state = ea.days.contains(1) ? .on : .off
        tuesdayCheckbox.state = ea.days.contains(2) ? .on : .off
        wednesdayCheckbox.state = ea.days.contains(3) ? .on : .off
        thursdayCheckbox.state = ea.days.contains(4) ? .on : .off
        fridayCheckbox.state = ea.days.contains(5) ? .on : .off
        
        currentLoginEmail = notification.userInfo!["currentLogin"] as! String
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        let weekMode = weekSelector.indexOfSelectedItem + 1
        let timeMode = timeSelector.indexOfSelectedItem + 1
        let location = locationTextField.stringValue
        let minGrade = minGradeSelector.indexOfSelectedItem + 6
        let maxGrade = maxGradeSelector.indexOfSelectedItem + 6
        let shortDesc = shortDescTextView.string
        let proposal = proposalTextView.string
        
        // Start by checking min and max grade
        if minGrade > maxGrade {
            showAlert(withTitle: "Minimum grade has to be greater than maximum grade")
            return
        }
        
        // Now check location length
        if location.count > 45 {
            showAlert(withTitle: "Please use fewer words to describe the location.")
            return
        }
        
        // To save bandwidth, don't update short description and proposal if it didn't change
        var sameShortDesc = false
        var sameProposal = false
        if shortDesc == currentEA!.shortDescription {
            sameShortDesc = true
        }
        
        if proposal == currentEA!.proposal {
            sameProposal = true
        }
        
        // Now get the days
        var daysArray: [Int] = []
        if mondayCheckbox.state == .on {
            daysArray.append(1)
        }
        if tuesdayCheckbox.state == .on {
            daysArray.append(2)
        }
        if wednesdayCheckbox.state == .on {
            daysArray.append(3)
        }
        if thursdayCheckbox.state == .on {
            daysArray.append(4)
        }
        if fridayCheckbox.state == .on {
            daysArray.append(5)
        }
        let days = daysArray.map{"\($0)"}.joined(separator: ",")
        
        guard currentEA!.checkOwner(currentLoginEmail!) else {
            showAlert(withTitle: "Can not modify data", message: "You no longer own this EA!")
            return
        }
        
        // Update
        currentEA!.updateDetail(newWeekMode: weekMode, newTimeMode: timeMode, newLocation: location, newMinGrade: minGrade, newMaxGrade: maxGrade, newShortDesc: !sameShortDesc ? shortDesc : nil, newProposal: !sameProposal ? proposal : nil, newDays: days) { (success, errString) in
            if !success {
                self.showAlert(withTitle: "Error Updating Info", message: errString!)
            } else {
                self.showAlert(withTitle: "EA Info Updated! 😀")
                NotificationCenter.default.post(name: EAUpdatedNotification, object: ["id":self.currentEA!.id, "updatedEA":self.currentEA!])
            }
        }
    }
    
    func showAlert(withTitle title: String, message: String = "") {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
    
    deinit {
        print("deinit: \(self)")
    }
}
