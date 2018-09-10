//
//  DebugVIewBugsViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/31.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

struct Bug {
    var id: Int!
    var email: String!
    var system: String!
    var bugDetail: String!
    
    init(dictionary: [String:Any]) {
        id = dictionary["entryid"] as? Int
        email = dictionary["email"] as? String
        system = dictionary["system"] as? String
        bugDetail = dictionary["bug"] as? String
    }
}

class DebugViewBugsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var bugs = [Bug]()
    
    @IBOutlet var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        downloadBugList()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window!.windowController!.shouldCascadeWindows = true
    }
    
    func downloadBugList() {
        let urlString = MainServerAddress + "/viewbugs.php"
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            defer {
                
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error!)
                    alert.runModal()
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
                }
                return
            }
            let response: [String:Any]
            do {
                
                let responseDict = try JSONSerialization.jsonObject(with: data!)
                if responseDict is Array<Any> {
                    let alert = NSAlert()
                    alert.messageText = "Aww..."
                    alert.informativeText = "No EA is up yet... Just be patient"
                    alert.runModal()
                }
                if let dict = responseDict as? [String:Any] {
                    response = dict
                } else {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = "The server returned an invalid object. (not a dictionary)"
                        alert.runModal()
                    }
                    return
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
                return
            }
            
            //print(String(data: data!, encoding: .utf8))
            
            let bugArray = response["allbugs"] as! [[String:Any]]
            for dict in bugArray {
                let bug = Bug(dictionary: dict)
                self.bugs.append(bug)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        dataTask.resume()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bugs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: nil) {
            let label = view.viewWithTag(100) as! NSTextField
            let bug = bugs[row]
            switch tableColumn!.identifier.rawValue {
            case "Email":
                label.stringValue = bug.email
            case "System":
                label.stringValue = bug.system
            case "Detail":
                label.stringValue = bug.bugDetail
            default:
                break
            }
            return view
        }
        return nil
    }
}
