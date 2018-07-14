//
//  LeaderSettingsViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class LeaderSettingsViewController: NSViewController {
    @IBOutlet var leaderTableView: NSTableView!
    @IBOutlet var supervisorTableView: NSTableView!
    
    var currentEA: EnrichmentActivity? = nil
    
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
    }
 
    deinit {
        print("deinit: \(self)")
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
}
