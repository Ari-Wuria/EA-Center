//
//  CoordinatorSettingsViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/20.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class CoordinatorSettingsViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    @IBOutlet weak var titleLabel: NSTextField!
    
    var containingDetailController: CoordinatorDetailViewController?
    
    var loading = false
    var success = false
    
    var allEA = [EnrichmentActivity]()
    var needApprovalEA = [EnrichmentActivity]()
    
    @IBOutlet weak var letters: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        containerView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let controller = segue.destinationController as! CoordinatorDetailViewController
            containingDetailController = controller
        }
    }
    
    @objc func eaUpdated(_ notification: Notification) {
        updateNeedApproval()
        tableView.reloadData()
    }
    
    override func viewWillAppear() {
        allEA = []
        downloadEAList()
    }
    
    func downloadEAList() {
        loading = true
        
        spinner.startAnimation(nil)
        
        let urlString = MainServerAddress + "/manageea/getealist.php"
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            defer {
                DispatchQueue.main.async {
                    self.loading = false
                    self.updateNeedApproval()
                    
                    self.tableView.reloadData()
                    
                    self.spinner.stopAnimation(nil)
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error!)
                    alert.runModal()
                    self.success = false
                    //self.failedDownloadCleanup()
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "The server returned an invalid response. (not 200)"
                    alert.runModal()
                    self.success = false
                    //self.failedDownloadCleanup()
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:Any]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "The server returned an invalid object. (not a dictionary)"
                    alert.runModal()
                    self.success = false
                    //self.failedDownloadCleanup()
                }
                return
            }
            
            let eaArray = response["allea"] as! [[String:Any]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                self.allEA.append(enrichmentActivity)
            }
            
            self.success = true
        }
        dataTask.resume()
    }
    
    func updateNeedApproval() {
        needApprovalEA = allEA.filter{ (ea) -> Bool in
            return ea.approved == 1
        }
    }
    
    @IBAction func reloadList(_ sender: Any) {
        allEA = []
        titleLabel.stringValue = "Coordinator Manager"
        letters.isHidden = false
        containerView.isHidden = true
        downloadEAList()
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

extension CoordinatorSettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if loading {
            return 0
        } else if needApprovalEA.count > 0 {
            return needApprovalEA.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if needApprovalEA.count == 0 && success {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NothingCell"), owner: nil)
        } else if !success {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ErrorCell"), owner: nil)
        }
        
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("EACell"), owner: nil) as! CoordinatorSettingsCellView
        let ea = needApprovalEA[row]
        view.nameLabel.stringValue = ea.name
        view.leaderLabel.stringValue = "Loading leader"
        view.supervisorLabel.stringValue = "Loading supervisor"
        //view.proposalLabel.stringValue = ea.proposal
        if ea.proposal.count > 0 {
            view.proposalLabel.stringValue = ea.proposal
        } else {
            view.proposalLabel.stringValue = "This EA's leader is lazy and didn't write the proposal."
        }
        
        let firstLeader = ea.leaderEmails.first
        let firstSupervisor = ea.supervisorEmails.first
        
        AccountProcessor.name(from: firstLeader!) { (name) in
            if name == nil {
                view.leaderLabel.stringValue = "Error retriving leader"
            }
            if ea.leaderEmails.count == 1 {
                view.leaderLabel.stringValue = name!
            } else {
                view.leaderLabel.stringValue = "\(name!) and \(ea.leaderEmails.count - 1) more"
            }
        }
        
        if let firstSupervisor = firstSupervisor {
            AccountProcessor.name(from: firstSupervisor) { (name) in
                if name == nil {
                    view.supervisorLabel.stringValue = "Error retriving supervisor"
                }
                if ea.supervisorEmails.count == 1 {
                    view.supervisorLabel.stringValue = name!
                } else {
                    view.supervisorLabel.stringValue = "\(name!) and \(ea.supervisorEmails.count - 1) more"
                }
            }
        } else {
            view.supervisorLabel.stringValue = "No Supervisor"
        }
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if needApprovalEA.count == 0 {
            return false
        }
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow == -1 {
            containerView.isHidden = true
            titleLabel.stringValue = "Coordinator Manager"
            letters.isHidden = false
            return
        }
        
        containerView.isHidden = false
        letters.isHidden = true
        
        let ea = needApprovalEA[tableView.selectedRow]
        titleLabel.stringValue = ea.name
        containingDetailController?.updateInfo(with: ea)
    }
}
