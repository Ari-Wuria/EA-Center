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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
        view.layer = CALayer()
        //view.layer?.backgroundColor = CGColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
        
        shortDescTextView.isHorizontallyResizable = false
        shortDescTextView.textContainer?.widthTracksTextView = true
        
    }
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        
        weekSelector.selectItem(at: ea.weekMode)
        timeSelector.selectItem(at: ea.timeMode)
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
    }
    
    @IBAction func saveChanges(_ sender: Any) {
    }
}
