//
//  AddLeaderViewController.swift
//  EA Center Mac
//
//  Created by Tom & Jerry on 2018/7/14.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

protocol AddLeaderViewControllerDelegate: class {
    func controller(_ controller: AddLeaderViewController, finishedWithAccountEmail email: String)
}

class AddLeaderViewController: NSViewController {
    var escEvent: Any?
    
    @IBOutlet var searchBar: NSSearchField!
    @IBOutlet var nameEmailSwitcher: NSSegmentedControl!
    @IBOutlet var selectorTableView: NSTableView!
    @IBOutlet var spinner: NSProgressIndicator!
    
    var accountList: [UserAccount] = []
    var filteredList: [UserAccount] = []
    
    // 1: Leader
    // 2: Supervisor
    var updateMode: Int = 0
    
    weak var delegate: AddLeaderViewControllerDelegate?
    
    var currentEA: EnrichmentActivity? = nil
    
    var processing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        preferredContentSize = view.frame.size

        selectorTableView.delegate = self
        selectorTableView.dataSource = self
        searchBar.delegate = self
        
        selectorTableView.target = self
        selectorTableView.doubleAction = #selector(selectRow)
        
        addESCEvent()
        
        downloadLeaderList()
        
        view.window?.makeFirstResponder(searchBar)
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        removeESCEvent()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    func addESCEvent() {
        escEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            if event.window != self.view.window {
                return event
            }
            
            if event.keyCode == 53 {
                // esc pressed
                self.dismiss(nil)
                return nil
            }
            
            return event
        }
    }
    
    func removeESCEvent() {
        if let event = escEvent {
            NSEvent.removeMonitor(event)
        }
        escEvent = nil
    }
    
    func downloadLeaderList() {
        let urlString = MainServerAddress + "/getaccountlist.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "getuser=1"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, urlReponse, error) in
            defer {
                DispatchQueue.main.async {
                    self.spinner.stopAnimation(nil)
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.showErrorAlert(nil, nil, error)
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    self.showErrorAlert("Failed retriving user list", "The server returned an invalid response. (not 200)")
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [[String:Any]]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    self.showErrorAlert("Failed retriving user list", "The server returned an invalid object. (not a dictionary)")
                }
                return
            }
            
            for dictionary in response {
                let userAccount = UserAccount(dictionary: dictionary)
                // Make sure that only teachers and coordinator can be added as supervisor (since I'm the admin) :)
                // Began check by checking for mode and user type
                guard self.updateMode == 1 || (self.updateMode == 2 && (userAccount.accountType == 3 || userAccount.accountType == 2)) else {
                    continue
                }
                
                // Now look at if it already exists in this ea
                if self.updateMode == 1 {
                    guard !(self.currentEA!.leaderEmails.contains(userAccount.userEmail)) else {
                        continue
                    }
                } else if self.updateMode == 2 {
                    guard !(self.currentEA!.supervisorEmails.contains(userAccount.userEmail)) else {
                        continue
                    }
                } else {
                    continue
                }
                
                self.accountList.append(userAccount)
            }
            
            DispatchQueue.main.async {
                self.selectorTableView.reloadData()
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
    
    @IBAction func segmentChanged(_ sender: Any) {
        if searchBar.stringValue.count > 0 {
            search()
        }
    }
    
    @objc func selectRow() {
        guard processing == false else {
            return
        }
        
        processing = true
        
        let row = selectorTableView.clickedRow
        guard row != -1 else {
            return
        }
        
        let selectedAccount: UserAccount
        if isFiltering() {
            selectedAccount = filteredList[row]
        } else {
            selectedAccount = accountList[row]
        }
        
        spinner.startAnimation(nil)
        currentEA?.updateLeader(newLeader: selectedAccount, isSupervisor: updateMode == 2, completion: { (success, errString) in
            if success == true {
                self.delegate?.controller(self, finishedWithAccountEmail: selectedAccount.userEmail)
                self.dismiss(nil)
            } else {
                self.showAlert("Error", errString!)
                self.spinner.stopAnimation(nil)
                
                if errString! == "This EA no longer exists." {
                    NotificationCenter.default.post(name: EADeletedNotification, object: self.currentEA!)
                }
            }
        })
    }
    
    deinit {
        print("deinit: \(self)")
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}

// Table view and search extension
extension AddLeaderViewController: NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if isFiltering() {
            return filteredList.count
        } else {
            return accountList.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableColumn?.identifier)!.rawValue == "Name" {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Name"), owner: nil) as! NSTableCellView
            let account: UserAccount
            if isFiltering() {
                account = filteredList[row]
            } else {
                account = accountList[row]
            }
            view.textField?.stringValue = account.username
            return view
        } else if (tableColumn?.identifier)!.rawValue == "Email" {
            let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Email"), owner: nil) as! NSTableCellView
            let account: UserAccount
            if isFiltering() {
                account = filteredList[row]
            } else {
                account = accountList[row]
            }
            view.textField?.stringValue = account.userEmail
            return view
        }
        return nil
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let theSearchbar = obj.object as? NSSearchField else {
            return
        }
        
        guard theSearchbar == self.searchBar else {
            return
        }
        
        search()
    }
    
    func search() {
        filteredList = accountList.filter { (account) -> Bool in
            let index = self.nameEmailSwitcher.selectedSegment
            if index == 0 {
                return account.username.lowercased().contains(self.searchBar.stringValue.lowercased())
            } else if index == 1 {
                return account.userEmail.lowercased().contains(self.searchBar.stringValue.lowercased())
            }
            // We have a serious error
            return false
        }
        
        selectorTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchBar.stringValue.count > 0
    }
}
