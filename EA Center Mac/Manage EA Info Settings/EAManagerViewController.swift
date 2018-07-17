
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        containerView.isHidden = true
        titleNameLabel.stringValue = "Manage EA"
        
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated), name: EAUpdatedNotification, object: nil)
        
        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.backgroundColor = NSColor(named: "Main Background")!.cgColor
        view.window?.styleMask = .texturedBackground
        view.window?.backgroundColor = NSColor(named: "Main Background")!
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        retriveMyEA()
    }
    
    @objc func eaUpdated() {
        tableView.reloadData()
    }
    
    func retriveMyEA() {
        let urlString = MainServerAddress + "/manageea/getmyea.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(loggedInEmail)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    //completion(false, -1, error!.localizedDescription)
                    self.showErrorAlert(nil, nil, error!)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                    self.showErrorAlert("Error", "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData: Any
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!)
            } catch {
                //print("No JSON data: \(error)")
                self.showErrorAlert(nil, nil, error)
                return
            }
            
            guard jsonData is [String:Any] else {
                // No EA. Empty array
                return
            }
            
            let result = jsonData as! [String:Any]
            
            let myEAs = result["result"] as! [[String:Any]]
            for eaDict in myEAs {
                let ea = EnrichmentActivity(dictionary: eaDict)
                self.myEA.append(ea)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        }
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

extension EAManagerViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 129
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return myEA.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ManageCell"), owner: nil) as! ManagerCellView
        let ea = myEA[row]
        
        view.eaNameLabel.stringValue = ea.name
        view.locationLabel.stringValue = ea.location
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
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        containerView.isHidden = false
        
        if tableView.selectedRow == -1 {
            containerView.isHidden = true
            titleNameLabel.stringValue = "Manage EA"
            return
        }
        
        let ea = myEA[tableView.selectedRow]
        NotificationCenter.default.post(name: ManagerSelectionChangedNotification, object: ea, userInfo: nil)
        
        titleNameLabel.stringValue = ea.name
    }
    
    @IBAction func reloadList(_ sender: Any) {
        myEA = []
        containerView.isHidden = true
        titleNameLabel.stringValue = "Manage EA"
        retriveMyEA()
    }
}
