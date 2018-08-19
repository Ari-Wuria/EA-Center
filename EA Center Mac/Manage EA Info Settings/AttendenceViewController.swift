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
    
    @IBOutlet var nextSessionDateLabel: NSTextField!
    
    @IBOutlet var touchAllPresentButton: NSButton!
    @IBOutlet var touchAllAbsentButton: NSButton!
    @IBOutlet var touchAllLateButton: NSButton!
    
    var currentEA: EnrichmentActivity?
    var loggedInEmail: String?
    
    // Only set if session is on this day
    var nextSessionDate: Date!
    
    lazy var dateFormatter = DateFormatter()
    
    var attendenceEnabled = false
    
    var noWeekSession = false
    
    //var allSegmentedControls = [NSSegmentedControl]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
        
        //dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
    }
    
    @objc func eaUpdated(_ notification: Notification) {
        let object = notification.object as! [String:Any]
        let ea = object["updatedEA"] as! EnrichmentActivity
        newObject(ea)
    }
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        /*
        // Reset segmented control for reuse
        for segmentedControl in allSegmentedControls {
            segmentedControl.tag = 101
        }
        allSegmentedControls.removeAll()
        */
        
        newObject(ea, notification.userInfo)
    }
    
    func newObject(_ ea: EnrichmentActivity, _ userInfo: [AnyHashable:Any]? = nil) {
        defer {
            // Reload on exit
            if isViewLoaded {
                studentListTable.reloadData()
            }
        }
        
        let date = Date()
        let days = currentEA!.days
        var weekSessionDates = [Date]()
        for day in days {
            weekSessionDates.append(date.next(date.weekdayFromInt(day)!, considerToday: true))
        }
        weekSessionDates.sort { (date1, date2) -> Bool in
            return date1 < date2
        }
        
        noWeekSession = false
        
        if isViewLoaded {
            if !(ea.approved == 2 || ea.approved == 3) || ea.endDate! < Date() {
                nextSessionDateLabel.stringValue = "EA not approved or is already over :("
                attendenceEnabled = false
                return
            }
            
            if weekSessionDates.count == 0 {
                nextSessionDateLabel.stringValue = "Please select running days"
                attendenceEnabled = false
                noWeekSession = true
                return
            }
        }
        
        if weekSessionDates.count == 0 {
            return
        }
        
        let earliest = weekSessionDates[0]
        
        nextSessionDate = earliest
        
        if isViewLoaded {
            let nextSessionStr = dateFormatter.string(from: nextSessionDate)
            let currentStr = dateFormatter.string(from: Date.today())
            let prefix: String
            if nextSessionStr == currentStr {
                prefix = "Today's session: "
                attendenceEnabled = true
            } else {
                prefix = "Next session: "
                attendenceEnabled = false
            }
            nextSessionDateLabel.stringValue = prefix + nextSessionStr
        } else {
            let nextSessionStr = dateFormatter.string(from: nextSessionDate)
            let currentStr = dateFormatter.string(from: Date.today())
            if nextSessionStr == currentStr {
                attendenceEnabled = true
            } else {
                attendenceEnabled = false
            }
        }
        
        if let userInfo = userInfo {
            loggedInEmail = userInfo["currentLogin"] as? String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if currentEA == nil {
            return
        }
        
        if !(currentEA!.approved == 2 || currentEA!.approved == 3) || currentEA!.endDate! < Date() {
            nextSessionDateLabel.stringValue = "EA not approved or is already over :("
            attendenceEnabled = false
            return
        }
        
        if !noWeekSession {
            nextSessionDateLabel.stringValue = "Please select running days"
            attendenceEnabled = false
            return
        }
        
        studentListTable.reloadData()
        let nextDateStr = dateFormatter.string(from: nextSessionDate)
        let prefix: String
        if attendenceEnabled {
            prefix = "Today's session: "
        } else {
            prefix = "Next session: "
        }
        nextSessionDateLabel.stringValue = prefix + nextDateStr
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
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Attendance"), owner: nil) as! AttendenceCellView
            
            // Using segmented control tag to store account id
            //let segmentedControl = view?.viewWithTag(101) as! NSSegmentedControl
            let studentAccountID = currentEA!.joinedUserID![row]
            //segmentedControl.tag = studentAccountID
            //allSegmentedControls.append(segmentedControl)
            
            view.attendenceStudentID = studentAccountID
            
            view.currentEA = currentEA
            
            if attendenceEnabled == true {
                view.attendenceEnabled = true
                view.attendenceSegmentControl.isEnabled = true
                view.attendanceDate = nextSessionDate
            } else {
                view.attendenceEnabled = false
                view.attendenceSegmentControl.isEnabled = false
                view.attendanceDate = nil
            }
            
            let dates = self.currentEA!.todayAttendenceList!
            if dates.count > 0 {
                AccountProcessor.retriveUserAccount(from: studentAccountID) { (account, errCode, errStr) in
                    if let userAccount = account {
                        let filtered = dates.filter { (attendance) -> Bool in
                            if attendance.studentID == userAccount.userID {
                                return true
                            } else {
                                return false
                            }
                        }
                        if filtered.count == 1 {
                            let attendance = filtered.first!
                            view.attendenceSegmentControl.selectSegment(withTag: attendance.attendanceStatus)
                        }
                    } else {
                        // Do nothing, can't get attendence
                    }
                }
            }
            
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // TODO: Show Description
        //performSegue(withIdentifier: "ShowDescription", sender: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDescription" {
            let controller = segue.destinationController as! NSViewController
            let row = studentListTable.selectedRow
            let view = studentListTable.view(atColumn: 1, row: row, makeIfNecessary: false)
            controller.sourceItemView = view
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
