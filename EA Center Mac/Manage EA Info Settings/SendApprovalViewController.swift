
//
//  SendApprovalViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/28.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class SendApprovalViewController: NSViewController {
    var escEvent: Any?
    var dismissed = false
    
    @IBOutlet weak var startPicker1: NSDatePicker!
    @IBOutlet weak var startPicker2: NSDatePicker!
    
    @IBOutlet weak var endPicker1: NSDatePicker!
    @IBOutlet weak var endPicker2: NSDatePicker!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    var currentEA: EnrichmentActivity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        preferredContentSize = view.frame.size
        
        addESCEvent()
        
        startPicker1.dateValue = Date()
        startPicker2.dateValue = Date()
        // 86400 is one day
        endPicker1.dateValue = Date().addingTimeInterval(86400)
        endPicker2.dateValue = Date().addingTimeInterval(86400)
    }
    
    func addESCEvent() {
        escEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            if event.window != self.view.window {
                return event
            }
            
            if event.keyCode == 53 {
                // esc pressed
                self.dismissed = true
                self.dismiss(nil)
                return nil
            }
            
            return event
        }
    }
    
    func removeESCEvent() {
        if let event = escEvent {
            NSEvent.removeMonitor(event)
        }
        escEvent = nil
    }
    
    @IBAction func submitApproval(_ sender: Any) {
        let startDate = startPicker1.dateValue
        let endDate = endPicker1.dateValue
        
        let formatter = currentEA.dateFormatter
        let startStr = formatter?.string(from: startDate)
        let currentStr = formatter?.string(from: Date())
        
        if startDate < Date() && !(currentStr == startStr) {
            showAlert(withTitle: "Start date can not be earlier than today.")
            return
        }
        
        if endDate < startDate {
            showAlert(withTitle: "Start date has to be earlier than end date")
            return
        }
        
        spinner.startAnimation(sender)
        
        currentEA.requestApproval(1, startDate, endDate) { (success, errStr) in
            if success {
                // Success
                NotificationCenter.default.post(name: EAUpdatedNotification, object: ["id":self.currentEA.id, "updatedEA":self.currentEA])
                self.dismiss(nil)
            } else {
                self.showAlert(withTitle: "Error requesting approval", message: errStr!)
            }
            
            self.spinner.stopAnimation(nil)
        }
    }
    
    @IBAction func startPickerChanged(_ sender: Any) {
        if sender as? NSDatePicker == startPicker1 {
            startPicker2.dateValue = startPicker1.dateValue
        } else {
            startPicker1.dateValue = startPicker2.dateValue
        }
    }
    
    @IBAction func endPickerChanged(_ sender: Any) {
        if sender as? NSDatePicker == endPicker1 {
            endPicker2.dateValue = endPicker1.dateValue
        } else {
            endPicker1.dateValue = endPicker2.dateValue
        }
    }
    
    func showAlert(withTitle title: String, message: String = "") {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    deinit {
        print("deinit \(self)")
    }
}
