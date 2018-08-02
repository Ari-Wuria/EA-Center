
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        preferredContentSize = view.frame.size
        
        addESCEvent()
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
    
    deinit {
        print("deinit \(self)")
    }
}
