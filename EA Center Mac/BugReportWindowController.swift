//
//  BugReportWindowController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/13.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa
import AudioToolbox

class BugReportWindowController: AboutWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func showFinishedScreen() {
        let aboutStoryboard = NSStoryboard(name: "AboutScreen", bundle: .main)
        let finishedController = aboutStoryboard.instantiateController(withIdentifier: "BugReportFinished")
        contentViewController = finishedController as? NSViewController
        
        // TODO: Play sound
        
        delay(5) {
            self.close()
        }
    }

}

