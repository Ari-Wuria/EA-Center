//
//  EditDescriptionViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EditDescriptionViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    
    var escEvent: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
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
    
    @IBAction func save(_ sender: Any) {
        dismiss(sender)
    }
    
    override func viewWillDisappear() {
        if let event = escEvent {
            NSEvent.removeMonitor(event)
        }
    }
    
    deinit {
        print("Editor deinit")
    }
}
