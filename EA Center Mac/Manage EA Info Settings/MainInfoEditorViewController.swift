//
//  MainInfoEditorViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class MainInfoEditorViewController: NSViewController {
    @objc var containingTabViewController: ManagerTabViewController?
    
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
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    @IBOutlet weak var touchWeekPopover: NSPopoverTouchBarItem!
    @IBOutlet weak var touchWeekSelector: NSSegmentedControl!
    @IBOutlet weak var touchDaysPopover: NSPopoverTouchBarItem!
    @IBOutlet weak var touchMondayButton: NSButton!
    @IBOutlet weak var touchTuesdayButton: NSButton!
    @IBOutlet weak var touchWednesdayButton: NSButton!
    @IBOutlet weak var touchThursdayButton: NSButton!
    @IBOutlet weak var touchFridayButton: NSButton!
    @IBOutlet weak var touchTimePopover: NSPopoverTouchBarItem!
    @IBOutlet weak var touchTimeSelector: NSSegmentedControl!
    @IBOutlet weak var touchMinGradePopover: NSPopoverTouchBarItem!
    @IBOutlet weak var touchMaxGradePopover: NSPopoverTouchBarItem!
    @IBOutlet weak var touchMinGradeSelector: NSSegmentedControl!
    @IBOutlet weak var touchMaxGradeSelector: NSSegmentedControl!
    
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
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "containingTabViewController" {
            containingTabViewController = value as? ManagerTabViewController
            return
        }
        
        super.setValue(value, forKey: key)
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
        
        currentLoginEmail = notification.userInfo!["currentLogin"] as? String
        
        touchWeekPopover.collapsedRepresentationLabel = ea.weekModeForDisplay()
        touchWeekSelector.selectSegment(withTag: ea.weekMode - 1)
        touchMondayButton.state = mondayCheckbox.state
        touchTuesdayButton.state = tuesdayCheckbox.state
        touchWednesdayButton.state = wednesdayCheckbox.state
        touchThursdayButton.state = thursdayCheckbox.state
        touchFridayButton.state = fridayCheckbox.state
        touchTimePopover.collapsedRepresentationLabel = ea.timeModeForDisplay()
        touchTimeSelector.selectSegment(withTag: ea.timeMode - 1)
        touchMinGradePopover.collapsedRepresentationLabel = "Grade \(ea.minGrade)"
        touchMaxGradePopover.collapsedRepresentationLabel = "Grade \(ea.maxGrade)"
        touchMinGradeSelector.selectSegment(withTag: ea.minGrade - 6)
        touchMaxGradeSelector.selectSegment(withTag: ea.maxGrade - 6)
        
        touchWeekPopover.dismissPopover(nil)
        touchTimePopover.dismissPopover(nil)
        touchDaysPopover.dismissPopover(nil)
        touchMinGradePopover.dismissPopover(nil)
        touchMaxGradePopover.dismissPopover(nil)
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
            showAlert(withTitle: "Maximum grade has to be greater than minimum grade")
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
        /*
        guard currentEA!.checkOwner(currentLoginEmail!) else {
            showAlert(withTitle: "Can not modify data", message: "You no longer own this EA!")
            return
        }
        */
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
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        let viewAtLocation = view.hitTest(location)
        if viewAtLocation != shortDescTextView.enclosingScrollView && viewAtLocation != proposalTextView.enclosingScrollView {
            // Resign first responder of text view to revive touch bar
            dismissTextView()
        }
    }
    
    // TODO: Make it also work when clicked outside this view controller's view
    func dismissTextView() {
        // Make container ManagerViewController as first responder
        view.window?.makeFirstResponder(containingTabViewController?.parentManagerController)
    }
    
    @IBAction func weekChanged(_ sender: Any) {
        if let button = sender as? NSPopUpButton, button == weekSelector {
            touchWeekSelector.selectSegment(withTag: weekSelector.indexOfSelectedItem)
        } else {
            weekSelector.selectItem(at: touchWeekSelector.indexOfSelectedItem)
        }
        
        touchWeekPopover.collapsedRepresentationLabel = weekSelector.selectedItem!.title
    }
    
    @IBAction func timeChanged(_ sender: Any) {
        if let button = sender as? NSPopUpButton, button == timeSelector {
            touchTimeSelector.selectSegment(withTag: timeSelector.indexOfSelectedItem)
        } else {
            timeSelector.selectItem(at: touchTimeSelector.indexOfSelectedItem)
        }
        
        touchTimePopover.collapsedRepresentationLabel = timeSelector.selectedItem!.title
    }
    
    @IBAction func daysChanged(_ sender: Any) {
        if let button = sender as? NSButton {
            switch button {
            case mondayCheckbox:
                touchMondayButton.state = mondayCheckbox.state
                break
            case touchMondayButton:
                mondayCheckbox.state = touchMondayButton.state
                break
            case tuesdayCheckbox:
                touchTuesdayButton.state = tuesdayCheckbox.state
                break
            case touchTuesdayButton:
                tuesdayCheckbox.state = touchTuesdayButton.state
                break
            case wednesdayCheckbox:
                touchWednesdayButton.state = wednesdayCheckbox.state
                break
            case touchWednesdayButton:
                wednesdayCheckbox.state = touchWednesdayButton.state
                break
            case thursdayCheckbox:
                touchThursdayButton.state = thursdayCheckbox.state
                break
            case touchThursdayButton:
                thursdayCheckbox.state = touchThursdayButton.state
                break
            case fridayCheckbox:
                touchFridayButton.state = fridayCheckbox.state
                break
            case touchFridayButton:
                fridayCheckbox.state = touchFridayButton.state
                break
            default:
                break
            }
        }
    }
    
    @IBAction func gradeSelectorChanged(_ sender: Any) {
        if let button = sender as? NSPopUpButton {
            if button == minGradeSelector {
                touchMinGradeSelector.selectSegment(withTag: minGradeSelector.indexOfSelectedItem)
                touchMinGradePopover.collapsedRepresentationLabel = "Grade \(minGradeSelector.indexOfSelectedItem + 6)"
            } else if button == maxGradeSelector {
                touchMaxGradeSelector.selectSegment(withTag: maxGradeSelector.indexOfSelectedItem)
                touchMaxGradePopover.collapsedRepresentationLabel = "Grade \(maxGradeSelector.indexOfSelectedItem + 6)"
            }
        } else if let button = sender as? NSSegmentedControl {
            if button == touchMinGradeSelector {
                minGradeSelector.selectItem(at: touchMinGradeSelector.indexOfSelectedItem)
                touchMinGradePopover.collapsedRepresentationLabel = "Grade \(minGradeSelector.indexOfSelectedItem + 6)"
            } else if button == touchMaxGradeSelector {
                maxGradeSelector.selectItem(at: touchMaxGradeSelector.indexOfSelectedItem)
                touchMaxGradePopover.collapsedRepresentationLabel = "Grade \(maxGradeSelector.indexOfSelectedItem + 6)"
            }
        }
    }
    
    deinit {
        print("deinit: \(self)")
    }
}
