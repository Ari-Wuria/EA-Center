//
//  AboutViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/1.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!

    @IBOutlet var mainTouchBar: NSTouchBar!
    
    var escEvent: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        title = "About EASLINK"
        
        imageView.wantsLayer = true
        imageView.canDrawSubviewsIntoLayer = true
        imageView.layer?.masksToBounds = true
        imageView.layer?.cornerRadius = 25
        
        addESCEvent()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        removeESCEvent()
    }
    
    @IBAction func openGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/TomShen1234/EA-Center")!)
    }
    
    @IBAction func showUseOfLibraries(_ sender: Any) {
        // TODO: Add use of library
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    func addESCEvent() {
        escEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            if event.window != self.view.window {
                return event
            }
            
            if event.keyCode == 53 {
                // esc pressed
                self.view.window?.close()
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
