//
//  EAManagerViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/6.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class ManagerViewController: UITableViewController {
    var myEA: [EnrichmentActivity] = []
    var loggedIn: Bool = false
    var currentAccount: UserAccount?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(loggedIn(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: LogoutNotification, object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func loggedIn(_ notification: Notification) {
        loggedIn = true
        let dic = notification.object as! [String:Any]
        let userAccount = dic["account"] as! UserAccount
        currentAccount = userAccount
        retriveMyEA()
    }
    
    @objc func logout(_ notification: Notification) {
        loggedIn = false
        currentAccount = nil
        myEA = []
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Download
    
    func retriveMyEA() {
        let urlString = MainServerAddress + "/getmyea.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(currentAccount!.userEmail)"
        request.httpBody = postString.data(using: .utf8)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
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
    
    @objc func refresh() {
        if loggedIn == false {
            refreshControl?.endRefreshing()
            return
        }
        
        myEA.removeAll()
        retriveMyEA()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loggedIn {
            return myEA.count
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loggedIn {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCell", for: indexPath) as! EAManageCell
            
            // Configure the cell...
            
            let ea = myEA[indexPath.row]
            
            cell.nameLabel.text = ea.name
            cell.locationLabel.text = ea.location
            cell.timeLabel.text = ea.timeModeForDisplay()
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "LoginWarningCell")!
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if loggedIn {
            return .delete
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if loggedIn {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
