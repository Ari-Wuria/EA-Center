//
//  DebugViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/27.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class DebugViewController: NSViewController {
    @IBOutlet weak var debugCheckbox: NSButton!
    @IBOutlet weak var serverPopup: NSPopUpButton!
    
    var restartShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        debugCheckbox.state = UserDefaults.standard.bool(forKey: "Debug") == true ? .on : .off
        serverPopup.selectItem(at: UserDefaults.standard.integer(forKey: "ServerID"))
    }
    
    @IBAction func toggleDebug(_ sender: Any) {
        let newDebug = debugCheckbox.state == .on
        UserDefaults.standard.set(newDebug, forKey: "Debug")
        
        let newServerID = serverPopup.indexOfSelectedItem
        if newServerID != 0 {
            showRestartAlert()
        }
    }
    
    @IBAction func serverChanged(_ sender: Any) {
        let newServerID = serverPopup.indexOfSelectedItem
        UserDefaults.standard.set(newServerID, forKey: "ServerID")
        
        showRestartAlert()
    }
    
    func showRestartAlert() {
        if restartShown {
            return
        }
        
        restartShown = true
        
        let alert = NSAlert()
        alert.messageText = "Please restart app for changes to fully take effect."
        alert.runModal()
    }
}
