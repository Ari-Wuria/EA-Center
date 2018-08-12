//
//  EAManagerViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/6.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol ManagerSplitViewControlling: class {
    func managerRequestSplitViewDetail(_ controller: ManagerViewController)
}

class ManagerViewController: UITableViewController {
    var myEA: [EnrichmentActivity] = []
    var loggedIn: Bool = false
    var currentAccount: UserAccount?
    
    weak var splitViewDetail: EADetailViewController?
    
    weak var splitViewControllingDelegate: ManagerSplitViewControlling?
    
    @IBOutlet var createButton: UIBarButtonItem!
    
    var selectedEA: EnrichmentActivity?
    
    var successLoading = false
    
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
        
        if !loggedIn {
            navigationItem.rightBarButtonItems = []
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
        let splitDetail = splitDetailNav?.topViewController
        if splitDetail is EADetailViewController {
            trackSelectedEA()
        }
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
        navigationItem.rightBarButtonItems = [createButton]
    }
    
    @objc func logout(_ notification: Notification) {
        loggedIn = false
        currentAccount = nil
        myEA = []
        tableView.reloadData()
        navigationItem.rightBarButtonItems = []
    }
    
    func trackSelectedEA() {
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass != .compact {
            // iPad only
            if selectedEA != nil {
                let eaInArray = myEA.firstIndex(of: selectedEA!)
                if let row = eaInArray {
                    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .middle)
                }
            } else {
                splitViewDetail = nil
                let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
                let splitDetail = splitDetailNav?.topViewController
                if splitDetail is EADetailViewController {
                    // TODO: Try to use reusable detail controller
                    // Currently using a one time use controller, because this one is the description view, not the detail view.
                    //performSegue(withIdentifier: "EADescDetail", sender: nil)
                    let nav = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "DescriptionNav")
                    splitViewController?.showDetailViewController(nav, sender: nil)
                }
            }
        }
    }
    
    // MARK: - Download
    
    func retriveMyEA() {
        let urlString = MainServerAddress + "/manageea/getmyea.php"
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
                        
                        let splitDetailNav = self.splitViewController?.viewControllers.last as? UINavigationController
                        let splitDetail = splitDetailNav?.topViewController
                        if splitDetail is EADetailViewController {
                            // Refresh
                            self.selectedEA = nil
                            self.trackSelectedEA()
                        }
                    }
                }
            }
            
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    //completion(false, -1, error!.localizedDescription)
                    self.presentAlert(withTitle: "Failed retriving my EAs", message: error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Wrong Status Code")
                DispatchQueue.main.async {
                    //completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                    self.presentAlert(withTitle: "Failed retriving my EAs", message: "The server returned an invalid response code. (something that's not 200)")
                }
                return
            }
            
            let jsonData: Any
            do {
                jsonData = try JSONSerialization.jsonObject(with: data!)
            } catch {
                //print("No JSON data: \(error)")
                self.presentAlert(withTitle: "Failed retriving my EAs", message: "This app is having trouble understanding the data that the server had provided. (No JSON data)")
                return
            }
            
            guard let jsonResult = jsonData as? [String:Any] else {
                self.successLoading = true
                return
            }
            
            let myEAs = jsonResult["result"] as! [[String:Any]]
            for eaDict in myEAs {
                let ea = EnrichmentActivity(dictionary: eaDict)
                self.myEA.append(ea)
            }
            self.successLoading = true
        }
        dataTask.resume()
    }
    
    @objc func refresh() {
        if loggedIn == false {
            refreshControl?.endRefreshing()
            return
        }
        
        successLoading = false
        
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
            if myEA.count > 0 {
                return myEA.count
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loggedIn {
            if successLoading == true && myEA.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "StarterCell")!
            } else if myEA.count == 0 && successLoading == false {
                return tableView.dequeueReusableCell(withIdentifier: "NothingCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManageCell", for: indexPath) as! EAManageCell
            
            // Configure the cell...
            
            let ea = myEA[indexPath.row]
            
            cell.nameLabel.text = ea.name
            
            let location = (ea.location.count > 0) ? ea.location : "Location Unspecified"
            cell.locationLabel.text = location
            
            cell.timeLabel.text = ea.timeModeForDisplay()
            
            let supervisors = ea.supervisorEmails
            if supervisors.count > 0 {
                cell.supervisorLabel.text = "Loading supervisor info..."
                let firstSupervisorEmail = supervisors[0]
                AccountProcessor.name(from: firstSupervisorEmail) { (name) in
                    if let supervisorName = name {
                        if supervisors.count > 1 {
                            cell.supervisorLabel.text = "\(supervisorName) + \(supervisors.count - 1) more"
                        } else {
                            cell.supervisorLabel.text = supervisorName
                        }
                    } else {
                        cell.supervisorLabel.text = "Failed retriving supervisor info."
                    }
                }
            } else {
                cell.supervisorLabel.text = "No supervisor"
            }
            
            let plural = ea.joinedUserID!.count == 1 ? "" : "s"
            cell.numStudentsLabel.text = "\(ea.joinedUserID!.count) Participant\(plural)"
            
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
            
            let ea = myEA[indexPath.row]
            if ea.approved == 0 || ea.approved == 1 || ea.approved == 4 || ea.approved == 5 {
                let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete this EA?\nEnter EA name to confirm.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    let textField = alert.textFields![0]
                    let confirmText = textField.text
                    if confirmText == ea.name {
                        ea.delete { (success, errStr) in
                            if success {
                                NotificationCenter.default.post(name: EADeletedNotification, object: ea)
                                self.myEA.remove(at: indexPath.row)
                                if self.myEA.count > 0 {
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                } else {
                                    tableView.reloadData()
                                }
                            } else {
                                self.presentAlert(withTitle: "Can not delete EA!", message: errStr!)
                                
                                if errStr == "This EA no longer exists." {
                                    NotificationCenter.default.post(name: EADeletedNotification, object: ea)
                                    self.myEA.remove(at: indexPath.row)
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                }
                            }
                        }
                    } else {
                        self.presentAlert(withTitle: "Error", message: "Confirm name do not match.")
                    }
                })
                alert.addAction(delete)
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter EA name"
                }
                present(alert, animated: true, completion: nil)
            } else {
                presentAlert(withTitle: "Error", message: "You can't delete an EA that's currently running.")
            }
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
        if loggedIn && myEA.count > 0 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            let cell = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: "ManageEADetail", sender: cell)
        } else {
            let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
            let splitDetail = splitDetailNav?.topViewController
            if !(splitDetail is EADetailViewController) {
                performSegue(withIdentifier: "EADetail", sender: nil)
                splitViewControllingDelegate?.managerRequestSplitViewDetail(self)
            }
            
            let eaToDisplay = myEA[indexPath.row]
            
            splitViewDetail!.currentEA = eaToDisplay
            splitViewDetail!.currentAccount = currentAccount!
            
            selectedEA = eaToDisplay
            
            if splitViewController!.displayMode != .allVisible {
                // Temporary fix for segue animation
                delay(0.01) {
                    self.hideMasterPane()
                }
            }
        }
    }
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
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
            controller.currentAccount = currentAccount!
        } else if segue.identifier == "Create" {
            let nav = segue.destination as! UINavigationController
            nav.modalPresentationStyle = .formSheet
            let controller = nav.topViewController as! CreateEAViewController
            controller.email = currentAccount!.userEmail
            controller.delegate = self
        }
    }

    @IBAction func createNewEA(_ sender: Any) {
        // Might not be used.
    }
    
    @IBAction func backFromCreate(_ sender: UIStoryboardSegue) {
    }
}

extension ManagerViewController: CreateEAViewControllerDelegate {
    func createEAViewController(_ controller: CreateEAViewController, didFinishWith enrichmentActivity: EnrichmentActivity) {
        dismiss(animated: true, completion: nil)
        myEA.append(enrichmentActivity)
        tableView.reloadData()
    }
}
