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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(loggedInSuccess(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: LogoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")
    }
    
    @objc func eaUpdated(_ notification: Notification) {
        tableView.reloadData()
    }
    
    @objc func loggedInSuccess(_ notification: Notification) {
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
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delay(0.3) {
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
            
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    //completion(false, -1, error!.localizedDescription)
                    self.presentAlert(withTitle: "Error", message: error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                    self.presentAlert(withTitle: "Error", message: "The server returned an invalid response code. (something that's not 200)")
                }
                return
            }
            
            let jsonData: [String:Any]
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            } catch {
                //print("No JSON data: \(error)")
                self.presentAlert(withTitle: "Error", message: "This app is having trouble understanding the data that the server had provided. (No JSON data)")
                return
            }
            
            let myEAs = jsonData["result"] as! [[String:Any]]
            for eaDict in myEAs {
                let ea = EnrichmentActivity(dictionary: eaDict)
                self.myEA.append(ea)
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
    
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ManageEADetail" {
            let controller = segue.destination as! EADetailViewController
            let selectedIndexPath = tableView.indexPath(for: (sender as! UITableViewCell))
            controller.currentEA = myEA[selectedIndexPath!.row]
        }
    }

}
