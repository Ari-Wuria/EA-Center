
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        containerView.isHidden = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        retriveMyEA()
    }
    
    func retriveMyEA() {
        let urlString = MainServerAddress + "/getmyea.php"
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
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData: [String:Any]
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            } catch {
                print("No JSON data: \(error)")
                return
            }
            
            let myEAs = jsonData["result"] as! [[String:Any]]
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
        
        return view
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        containerView.isHidden = false
        
        let ea = myEA[tableView.selectedRow]
        NotificationCenter.default.post(name: ManagerSelectionChangedNotification, object: ea, userInfo: nil)
    }
}
