//
//  LeaderSettingsViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class LeaderSettingsViewController: NSViewController {
    @objc var containingTabViewController: ManagerTabViewController?
    
    @IBOutlet var leaderTableView: NSTableView!
    @IBOutlet var supervisorTableView: NSTableView!
    
    var currentEA: EnrichmentActivity? = nil
    
    var loggedInEmail: String?
    
    // 0: Nothing
    // 1: Leader
    // 2: Supervisor
    var currentSelectedTable: Int = 0
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Table view data source and delegate had been setup in storyboard
    }
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        
        if isViewLoaded {
            leaderTableView.reloadData()
            supervisorTableView.reloadData()
        }
        
        loggedInEmail = notification.userInfo!["currentLogin"] as? String
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLeader" {
            let controller = segue.destinationController as! AddLeaderViewController
            controller.updateMode = 1
            controller.currentEA = currentEA
            controller.delegate = self
        } else if segue.identifier == "AddSupervisor" {
            let controller = segue.destinationController as! AddLeaderViewController
            controller.updateMode = 2
            controller.currentEA = currentEA
            controller.delegate = self
        }
    }
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    override func deleteBackward(_ sender: Any?) {
        if currentSelectedTable == 0 {
            return
        } else if currentSelectedTable == 1 {
            let leader = currentEA!.leaderEmails[leaderTableView.selectedRow]
            if leader == loggedInEmail! {
                showErrorAlert("Error", "You can't remove yourself from the leader list. If you do want to do that, get another leader or supervisor in this EA to remove you.")
                return
            }
            //print("Delete leader: \(leader)")
            currentEA?.deleteLeader(email: leader, isSupervisor: false, completion: { (success, errString) in
                if success {
                    self.leaderTableView.reloadData()
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["id":self.currentEA!.id, "updatedEA":self.currentEA!])
                } else {
                    self.showErrorAlert("Can not remove leader", errString)
                    
                    if errString! == "This EA no longer exists." {
                        NotificationCenter.default.post(name: EADeletedNotification, object: self.currentEA!)
                    }
                }
            })
        } else if currentSelectedTable == 2 {
            let supervisor = currentEA!.supervisorEmails[supervisorTableView.selectedRow]
            if supervisor == loggedInEmail {
                showErrorAlert("Error", "You can't remove yourself from the supervisor list. If you do want to do that, get another leader or supervisor in this EA to remove you.")
                return
            }
            //print("Delete supervisor: \(supervisor)")
            currentEA?.deleteLeader(email: supervisor, isSupervisor: true, completion: { (success, errString) in
                if success {
                    self.supervisorTableView.reloadData()
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["id":self.currentEA!.id, "updatedEA":self.currentEA!])
                } else {
                    self.showErrorAlert("Can not remove supervisor", errString)
                    
                    if errString! == "This EA no longer exists." {
                        NotificationCenter.default.post(name: EADeletedNotification, object: self.currentEA!)
                    }
                }
            })
        }
    }
 
    deinit {
        print("deinit: \(self)")
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
}

extension LeaderSettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == leaderTableView {
            let leaders = currentEA!.leaderEmails
            return leaders.count
        } else {
            // tableView == supervisorTableView
            let supervisors = currentEA!.supervisorEmails
            return supervisors.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view: NSTableCellView? = nil
        if tableColumn?.identifier.rawValue == "LeaderName" {
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LeaderNameCell"), owner: nil) as? NSTableCellView
            view?.textField?.stringValue = "Loading name..."
            let leaders = currentEA!.leaderEmails
            let leaderEmail = leaders[row]
            AccountProcessor.name(from: leaderEmail) { (name) in
                view?.textField?.stringValue = name ?? "Can not retrive name"
                if name == "" {
                    view?.textField?.stringValue = "Name not set"
                }
            }
        } else if tableColumn?.identifier.rawValue == "LeaderEmail" {
            let leaders = currentEA!.leaderEmails
            let leaderEmail = leaders[row]
            
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "LeaderEmailCell"), owner: nil) as? NSTableCellView
            view?.textField?.stringValue = leaderEmail
        } else if tableColumn?.identifier.rawValue == "SupervisorName" {
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SupervisorNameCell"), owner: nil) as? NSTableCellView
            view?.textField?.stringValue = "Loading name..."
            let supervisors = currentEA!.supervisorEmails
            let supervisorEmail = supervisors[row]
            AccountProcessor.name(from: supervisorEmail) { (name) in
                view?.textField?.stringValue = name ?? "Can not retrive name"
                if name == "" {
                    view?.textField?.stringValue = "Name not set"
                }
            }
        } else if tableColumn?.identifier.rawValue == "SupervisorEmail" {
            let supervisors = currentEA!.supervisorEmails
            let supervisorEmail = supervisors[row]
            
            view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SupervisorEmailCell"), owner: nil) as? NSTableCellView
            view?.textField?.stringValue = supervisorEmail
        }
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        let currentRow = table.selectedRow
        if currentRow == -1 {
            currentSelectedTable = 0
        } else if table == leaderTableView {
            currentSelectedTable = 1
        } else if table == supervisorTableView {
            currentSelectedTable = 2
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    @IBAction func addLeader(_ sender: Any) {
        performSegue(withIdentifier: "AddLeader", sender: sender)
    }
    
    @IBAction func addSupervisor(_ sender: Any) {
        performSegue(withIdentifier: "AddSupervisor", sender: sender)
    }
}

extension LeaderSettingsViewController: AddLeaderViewControllerDelegate {
    func controller(_ controller: AddLeaderViewController, finishedWithAccountEmail email: String) {
        let mode = controller.updateMode
        if mode == 1 {
            leaderTableView.reloadData()
        } else if mode == 2 {
            supervisorTableView.reloadData()
        }
        
        NotificationCenter.default.post(name: EAUpdatedNotification, object: ["id":self.currentEA!.id, "updatedEA":self.currentEA!])
    }
}
