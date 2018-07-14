//
//  EAListViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EAListViewController: UITableViewController {
    var allEA: [EnrichmentActivity] = []
    
    var filteredEA = [EnrichmentActivity]()
    
    var listRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var loading: Bool = true
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshControl = listRefreshControl
        
        downloadEAList()
        
        tableView.backgroundColor = UIColor(named: "Main Table Color")
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = ["Name", "Short Description"]
        searchController.searchBar.delegate = self
    }
    
    @objc func refresh() {
        allEA.removeAll()
        downloadEAList()
    }

    // MARK: - Table view data source and delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true || allEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            return 1
        } else if loading == false && allEA.count > 0 {
            if isFiltering() {
                return filteredEA.count
            } else {
                return allEA.count
            }
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell")!
        } else if allEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "NothingCell")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EACell", for: indexPath) as! EAListCell
            
            // Configure the cell...
            
            let ea: EnrichmentActivity
            if isFiltering() {
                ea = filteredEA[indexPath.row]
            } else {
                ea = allEA[indexPath.row]
            }
            
            cell.nameLabel.text = ea.name
            cell.shortDescriptionLabel.text = ea.shortDescription
            cell.shortDescriptionLabel.sizeToFit()
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if loading == true || allEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            // Loading height
            return 109
        } else {
            // Custom
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if loading == true || allEA.count == 0 {
            return nil
        }
        return indexPath
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
*/
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ShowEADetail" {
            //let indexPath = tableView.indexPathForSelectedRow
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            
            let ea: EnrichmentActivity
            if isFiltering() {
                ea = filteredEA[indexPath.row]
            } else {
                ea = allEA[indexPath.row]
            }
            
            let destinationController = segue.destination as! EADescriptionViewController
            destinationController.ea = ea
        }
    }
    
    // MARK: - Downloads
    
    func downloadEAList() {
        let urlString = MainServerAddress + "/getealist.php"
        let url = URL(string: urlString)!
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            defer {
                self.loading = false
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    delay(0.3) {
                        self.tableView.reloadData()
                        self.listRefreshControl.endRefreshing()
                    }
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Error", message: error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Error", message: "The server returned an invalid response code. (something that's not 200)")
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Error", message: "This app is having trouble understanding the data that the server had provided. (No JSON data)")
                }
                return
            }
            
            let eaArray = response["allea"] as! [[String:AnyObject]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                self.allEA.append(enrichmentActivity)
            }
            
            // Defer...
        }
        dataTask.resume()
    }

    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// Extension for searching
extension EAListViewController: UISearchResultsUpdating, UISearchBarDelegate {
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
        filteredEA = allEA.filter({( ea : EnrichmentActivity) -> Bool in
            if scope == "Name" {
                return ea.name.lowercased().contains(searchText.lowercased())
            } else if scope == "Short Description" {
                if searchText == "" {
                    return true
                }
                return ea.shortDescription.lowercased().contains(searchText.lowercased())
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
