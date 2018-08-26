//
//  AddLeaderViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol AddLeaderViewControllerDelegate: class {
    func addLeaderViewController(_ controller: AddLeaderViewController, didFinishWith account: UserAccount)
}

class AddLeaderViewController: UITableViewController {
    var loading = true
    
    var accountList = [UserAccount]()
    var filteredList = [UserAccount]()
    
    // 1: Leader
    // 2: Supervisor
    var updateMode: Int = 0
    
    var currentEA: EnrichmentActivity?
    
    var searchController = UISearchController(searchResultsController: nil)
    
    weak var delegate: AddLeaderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")
        
        downloadLeaderList()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Name", "Email"]
        searchController.searchBar.delegate = self
        
        searchController.searchBar.isUserInteractionEnabled = false
    }
    
    @objc func refresh() {
        loading = true
        accountList = []
        searchController.searchBar.isUserInteractionEnabled = false
        tableView.reloadData()
        downloadLeaderList()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if loading || accountList.count == 0 {
            return 1
        } else if isFiltering() {
            if filteredList.count == 0 {
                return 1
            } else {
                return filteredList.count
            }
        } else {
            return accountList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell")!
        }
        
        if accountList.count == 0 || (isFiltering() && filteredList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "NothingCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderCell", for: indexPath)

        // Configure the cell...
        
        let leader: UserAccount
        
        if isFiltering() {
            leader = filteredList[indexPath.row]
        } else {
            leader = accountList[indexPath.row]
        }
        
        cell.textLabel?.text = (leader.username != "") ? leader.username : "Name not set"
        cell.detailTextLabel?.text = leader.userEmail

        return cell
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
                    //self.spinner.stopAnimation(nil)
                    self.loading = false
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    
                    if self.accountList.count > 0 {
                        self.searchController.searchBar.isUserInteractionEnabled = true
                    }
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert("Can not retrive list", error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    self.showAlert("Failed retriving user list", "The server returned an invalid response. (not 200)")
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [[String:Any]]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    self.showAlert("Failed retriving user list", "The server returned an invalid object. (not a dictionary)")
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
        }
        dataTask.resume()
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        
        let isSupervisor = updateMode == 2 ? true : false
        let selectedLeader: UserAccount
        if isFiltering() {
            selectedLeader = filteredList[indexPath.row]
        } else {
            selectedLeader = accountList[indexPath.row]
        }
        currentEA?.updateLeader(newLeader: selectedLeader, isSupervisor: isSupervisor, completion: { (success, errStr) in
            if success {
                self.delegate?.addLeaderViewController(self, didFinishWith: selectedLeader)
            } else {
                self.showAlert("Can not update info", errStr!)
            }
        })
    }
}

extension AddLeaderViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Name") {
        filteredList = accountList.filter({( account : UserAccount) -> Bool in
            if scope == "Name" {
                return account.username.lowercased().contains(searchText.lowercased())
            } else if scope == "Email" {
                if searchText == "" {
                    return true
                }
                return account.userEmail.lowercased().contains(searchText.lowercased())
            } else {
                return false
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
