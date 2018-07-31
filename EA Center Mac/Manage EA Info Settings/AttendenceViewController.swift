//
//  AttendenceViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AttendenceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @objc var containingTabViewController: ManagerTabViewController?
    
    @IBOutlet weak var studentListTable: NSTableView!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    var currentEA: EnrichmentActivity?
    var loggedInEmail: String?
    
    var allSegmentedControls = [NSSegmentedControl]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
    }
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        
        // Reset segmented control for reuse
        for segmentedControl in allSegmentedControls {
            segmentedControl.tag = 101
        }
        allSegmentedControls.removeAll()
        
        if isViewLoaded {
            studentListTable.reloadData()
        }
        
        loggedInEmail = notification.userInfo!["currentLogin"] as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentEA?.joinedUserID?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn!.identifier.rawValue == "Name" {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Name"), owner: nil)
            let label = view?.viewWithTag(100) as! NSTextField
            label.stringValue = "Loading Student Name..."
            let studentAccountID = currentEA!.joinedUserID![row]
            AccountProcessor.retriveUserAccount(from: studentAccountID) { (account, errCode, errStr) in
                if let userAccount = account {
                    let nameToDisplay = (userAccount.username.count > 0) ? userAccount.username : userAccount.userEmail
                    label.stringValue = nameToDisplay
                } else {
                    label.stringValue = "Failed retriving name..."
                }
            }
            return view
        } else if tableColumn!.identifier.rawValue == "Attendance" {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Attendance"), owner: nil)
            
            // Using segmented control tag to store account id
            let segmentedControl = view?.viewWithTag(101) as! NSSegmentedControl
            let studentAccountID = currentEA!.joinedUserID![row]
            segmentedControl.tag = studentAccountID
            allSegmentedControls.append(segmentedControl)
            
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
