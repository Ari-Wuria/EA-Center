//
//  CreateNewEAViewController.swift
//  EA Center Mac
//
//  Created by Tom & Jerry on 2018/7/15.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class CreateNewEAViewController: NSViewController {
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var createButton: NSButton!
    @IBOutlet var spinner: NSProgressIndicator!
    
    var escEvent: Any?
    
    var currentEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        preferredContentSize = view.frame.size
        
        nameTextField.delegate = self
        
        nameTextField.becomeFirstResponder()
        
        createButton.isEnabled = false
        
        addESCEvent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        removeESCEvent()
    }
    
    @IBAction func create(_ sender: Any) {
        // TODO
        let name = nameTextField.stringValue
        if name == "" {
            let alert = NSAlert()
            alert.messageText = "Please enter a valid name"
            alert.runModal()
            return
        }
        
        removeESCEvent()
        createButton.isEnabled = false
        spinner.startAnimation(sender)
        
        EnrichmentActivity.create(withName: name, email: currentEmail!) { (success, resultEA, errString) in
            if success == false {
                let alert = NSAlert()
                alert.messageText = "Error creating EA"
                alert.informativeText = errString!
                alert.runModal()
                
                self.addESCEvent()
                self.createButton.isEnabled = true
                self.spinner.stopAnimation(nil)
                return
            } else {
                NotificationCenter.default.post(name: EACreatedNotification, object: ["ea":resultEA])
                self.dismiss(nil)
            }
        }
    }
    
    
    
    func addESCEvent() {
        escEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            if event.window != self.view.window {
                return event
            }
            
            if event.keyCode == 53 {
                // esc pressed
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
}

extension CreateNewEAViewController: NSTextFieldDelegate {
    override func controlTextDidEndEditing(_ obj: Notification) {
        if createButton.isEnabled {
            create(obj)
        }
    }
}
