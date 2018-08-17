//
//  DeleteEAViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/27.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class DeleteEAViewController: NSViewController {
    var escEvent: Any?
    var dismissed = false
    
    var deleteEA: EnrichmentActivity?

    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var touchDeleteButton: NSButton!
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        preferredContentSize = view.frame.size
        
        textField.delegate = self
        
        deleteButton.isEnabled = false
        touchDeleteButton.isEnabled = false
        
        addESCEvent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        removeESCEvent()
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
    
    @IBAction func delete(_ sender: Any) {
        spinner.startAnimation(sender)
        deleteEA!.delete { (success, errStr) in
            if success {
                // Dismiss
                NotificationCenter.default.post(name: EADeletedNotification, object: self.deleteEA!)
                self.dismissed = true
                self.dismiss(nil)
            } else {
                let alert = NSAlert()
                alert.messageText = "Can not delete EA"
                alert.informativeText = errStr!
                alert.runModal()
                
                self.spinner.stopAnimation(nil)
                
                if errStr == "This EA no longer exists." {
                    // Also dismiss
                    NotificationCenter.default.post(name: EADeletedNotification, object: self.deleteEA!)
                    self.dismiss(nil)
                }
            }
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    deinit {
        print("deinit \(self)")
    }
}

extension DeleteEAViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if textField.stringValue == deleteEA!.name {
            deleteButton.isEnabled = true
            touchDeleteButton?.isEnabled = true
        } else {
            deleteButton.isEnabled = false
            touchDeleteButton?.isEnabled = false
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if deleteButton.isEnabled && !dismissed {
            delete(textField)
        }
    }
}
