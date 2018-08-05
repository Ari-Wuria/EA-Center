
//
//  EAManagerViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/21.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EAManagerViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    var myEA: [EnrichmentActivity] = []
    
    var loggedInEmail: String = ""
    
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var titleNameLabel: NSTextField!
    
    @IBOutlet var approvalButton: NSButton!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    
    @IBOutlet var tableMenu: NSMenu!
    @IBOutlet weak var deleteMenu: NSMenuItem!
    
    var success = false
    
    var containingTabViewController: ManagerTabViewController?
    
    @IBOutlet weak var computer: NSImageView!
    
    @IBOutlet var eaStateSwitch: NSSegmentedControl!
    
    var selectedEA: EnrichmentActivity?
    
    var wantReloadOnSelection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        containerView.isHidden = true
        titleNameLabel.stringValue = "Manage EA"
        
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated), name: EAUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaCreated(_:)), name: EACreatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaDeleted(_:)), name: EADeletedNotification, object: nil)
        
        approvalButton.isHidden = true
        eaStateSwitch.isHidden = true
        
        tableMenu.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        retriveMyEA()
    }
    
    @objc func eaDeleted(_ obj: Notification) {
        let ea = obj.object as! EnrichmentActivity
        let index = myEA.firstIndex(of: ea)
        myEA.remove(at: index!)
        
        containerView.isHidden = true
        titleNameLabel.stringValue = "Manage EA"
        computer.isHidden = false
        
        tableView.reloadData()
        trackSelectedEA()
    }
    
    @objc func eaUpdated() {
        tableView.reloadData()
        trackSelectedEA()
    }
    
    @objc func eaCreated(_ obj: Notification) {
        let dic = obj.object as! [String:Any]
        let ea = dic["ea"] as! EnrichmentActivity
        myEA.append(ea)
        
        tableView.reloadData()
        trackSelectedEA()
    }
    
    func retriveMyEA() {
        loadingSpinner.startAnimation(nil)
        
        let urlString = MainServerAddress + "/manageea/getmyea.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(loggedInEmail)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.loadingSpinner.stopAnimation(nil)
                }
            }
            
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    //completion(false, -1, error!.localizedDescription)
                    self.showErrorAlert(nil, nil, error!)
                    self.success = false
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                    self.showErrorAlert("Can not retrive EA", "Wrong Status Code: \(httpResponse.statusCode)")
                    self.success = false
                }
                return
            }
            
            let jsonData: Any
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!)
            } catch {
                //print("No JSON data: \(error)")
                self.showErrorAlert(nil, nil, error)
                self.success = false
                return
            }
            
            guard jsonData is [String:Any] else {
                // No EA. Empty array, but success.
                self.success = true
                return
            }
            
            let result = jsonData as! [String:Any]
            
            let myEAs = result["result"] as! [[String:Any]]
            for eaDict in myEAs {
                let ea = EnrichmentActivity(dictionary: eaDict)
                self.myEA.append(ea)
            }
            
            self.success = true
            
            // Defer block
        }
        dataTask.resume()
    }
    
    func showErrorAlert(_ title: String?, _ message: String?, _ error: Error? = nil) {
        let alert: NSAlert
        if let error = error {
            alert = NSAlert(error: error)
        } else if let title = title, let message = message {
            alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
        } else {
            alert = NSAlert()
            alert.messageText = "Error"
        }
        alert.runModal()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateEA" {
            let dest = segue.destinationController as! CreateNewEAViewController
            dest.currentEmail = self.loggedInEmail
        } else if segue.identifier == "EmbedTabView" {
            let tabController = segue.destinationController as! NSTabViewController as! ManagerTabViewController
            containingTabViewController = tabController
            tabController.parentManagerController = self
        } else if segue.identifier == "DeleteEA" {
            let dest = segue.destinationController as! DeleteEAViewController
            dest.deleteEA = myEA[tableView.clickedRow]
        }
    }
    
    @IBAction func reloadList(_ sender: Any) {
        myEA = []
        containerView.isHidden = true
        titleNameLabel.stringValue = "Manage EA"
        approvalButton.isHidden = true
        computer.isHidden = false
        retriveMyEA()
    }

    override func makeTouchBar() -> NSTouchBar? {
        if containerView.isHidden == false {
            let selectedItem = containingTabViewController!.tabView.selectedTabViewItem
            let index = containingTabViewController!.tabView.indexOfTabViewItem(selectedItem!)
            let controller = containingTabViewController!.children[index]
            
            //containingTabViewController!.tabView.delegate = self
            
            return controller.makeTouchBar()
        } else {
            return mainTouchBar
        }
    }
    
    @IBAction func touchNewEA(_ sender: Any) {
        performSegue(withIdentifier: "CreateEA", sender: sender)
    }
    
    @IBAction func deleteEA(_ sender: Any) {
        performSegue(withIdentifier: "DeleteEA", sender: sender)
    }
    
    @IBAction func updateEAOpenState(_ sender: Any) {
        if eaStateSwitch.selectedSegment == 0 {
            // Opened
            selectedEA?.updateApprovalState(2) { (success, errStr) in
                if success {
                    // Success
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedEA":self.selectedEA!, "id":self.selectedEA!.id])
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Can not set EA open state"
                    alert.informativeText = errStr!
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    self.eaStateSwitch.selectSegment(withTag: 1)
                }
            }
        } else {
            // Closed
            selectedEA?.updateApprovalState(3) { (success, errStr) in
                if success {
                    // Success
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedEA":self.selectedEA!, "id":self.selectedEA!.id])
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Can not set EA open state"
                    alert.informativeText = errStr!
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    self.eaStateSwitch.selectSegment(withTag: 0)
                }
            }
        }
    }
    
    func trackSelectedEA() {
        guard let selected = selectedEA else {
            return
        }
        let array = myEA.filter { ea in
            return ea.id == selected.id
        }
        guard array.count == 1 else {
            return
        }
        let firstEA = array[0]
        let index = myEA.firstIndex(of: firstEA)!
        wantReloadOnSelection = false
        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        wantReloadOnSelection = true
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

// MARK: - Table view extension
extension EAManagerViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if myEA.count == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 129
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if myEA.count == 0 {
            return 1
        } else if myEA.count > 0 {
            return myEA.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if myEA.count == 0 && success {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CreateCell"), owner: nil)
        } else if success == false {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ErrorCell"), owner: nil)
        }
        
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ManageCell"), owner: nil) as! ManagerCellView
        let ea = myEA[row]
        
        view.eaNameLabel.stringValue = ea.name
        
        let eaLocation = (ea.location.count > 0) ? ea.location : "No location"
        
        view.locationLabel.stringValue = eaLocation
        view.timeLabel.stringValue = ea.timeModeForDisplay()
        
        if ea.supervisorEmails.count > 0 {
            view.supervisorLabel.stringValue = "Loading supervisor name..."
            let firstSupervisor = ea.supervisorEmails[0]
            AccountProcessor.name(from: firstSupervisor) { (name) in
                if name == nil {
                    view.supervisorLabel.stringValue = "Can not load supervisor name"
                    return
                }
                
                view.supervisorLabel.stringValue = name!
                if ea.supervisorEmails.count > 1 {
                    view.supervisorLabel.stringValue += " + \(ea.supervisorEmails.count - 1) more"
                }
            }
        } else {
            view.supervisorLabel.stringValue = "No Supervisor"
        }
        
        let plural = ea.joinedUserID?.count == 1 ? "" : "s"
        view.numStudentsLabel.stringValue = "\(ea.joinedUserID!.count) Participant\(plural)"
        
        view.updateStatusImageView(with: ea.approved)
        
        if let date = ea.endDate, date < Date() {
            view.updateStatusImageView(with: 6)
        }
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if wantReloadOnSelection == false {
            return
        }
        
        if tableView.selectedRow == -1 {
            containerView.isHidden = true
            titleNameLabel.stringValue = "Manage EA"
            touchBar = nil
            computer.isHidden = false
            return
        }
        
        containerView.isHidden = false
        computer.isHidden = true
        
        let ea = myEA[tableView.selectedRow]
        NotificationCenter.default.post(name: ManagerSelectionChangedNotification, object: ea, userInfo: ["currentLogin":loggedInEmail])
        
        selectedEA = ea
        
        titleNameLabel.stringValue = ea.name
        
        if ea.approved == 2 || ea.approved == 3 {
            // Approved
            approvalButton.isHidden = true
            eaStateSwitch.isHidden = false
            eaStateSwitch.selectSegment(withTag: ea.approved - 2)
        } else if ea.approved == 1 {
            approvalButton.isHidden = false
            approvalButton.isEnabled = false
            approvalButton.title = "Waiting for approval..."
            eaStateSwitch.isHidden = true
        } else if ea.approved == 0 {
            approvalButton.isHidden = false
            approvalButton.isEnabled = true
            approvalButton.title = "Submit this EA for approval"
            eaStateSwitch.isHidden = true
        } else if ea.approved == 4 {
            approvalButton.isHidden = false
            approvalButton.isEnabled = true
            approvalButton.title = "Rejected. Resubmit approval."
            eaStateSwitch.isHidden = true
        }
        
        if ea.endDate != nil {
            let currentDate = Date()
            if ea.endDate! < currentDate {
                approvalButton.isHidden = false
                approvalButton.isEnabled = true
                approvalButton.title = "Resubmit approval to run again."
                eaStateSwitch.isHidden = true
            }
        }
        
        touchBar = nil
    }
}

extension EAManagerViewController: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        //print("Update")
        let row = tableView.clickedRow
        // TODO: Fix menu
        let ea = myEA[row]
        print("\(ea.approved)")
        if ea.approved == 0 || ea.approved == 1 || ea.approved == 4 || ea.approved == 5 {
            deleteMenu.isEnabled = true
            deleteMenu.title = "Delete This EA"
        } else {
            if (ea.endDate ?? Date()) < Date() {
                deleteMenu.isEnabled = true
                deleteMenu.title = "Delete This EA"
                return
            }
            deleteMenu.isEnabled = false
            deleteMenu.title = "You can't delete a running EA"
        }
    }
}

// MARK: - Class for tab view controlling
class ManagerTabViewController: NSTabViewController {
    var parentManagerController: EAManagerViewController?
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)
        
        parentManagerController!.touchBar = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for child in children {
            // Set the containing tab view controller for sub controllers
            child.setValue(self, forKey: "containingTabViewController")
        }
    }
}
