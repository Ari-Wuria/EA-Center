//
//  EAListViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol EAListSplitViewControlling: class {
    func eaListRequestSplitViewDetail(_ controller: EAListViewController)
}

class EAListViewController: UITableViewController {
    var allEA: [EnrichmentActivity] = []
    var joinableEA: [EnrichmentActivity] = []
    
    var filteredEA = [EnrichmentActivity]()
    
    var listRefreshControl: UIRefreshControl = UIRefreshControl()
    
    var loading: Bool = true
    
    let searchController = UISearchController(searchResultsController: nil)
    
    weak var splitViewDetail: EADescriptionViewController?
    
    weak var splitViewControllingDelegate: EAListSplitViewControlling?
    
    var currentAccount: UserAccount?
    
    var filterMode: Int = 1
    
    // Track selectedEA on iPad
    var selectedEA: EnrichmentActivity?

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaCreated(_:)), name: EACreatedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(login(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout(_:)), name: LogoutNotification, object: nil)
        
        // Get the split detail of this view controller at launch because it is the first detail vc shown
        splitViewControllingDelegate?.eaListRequestSplitViewDetail(self)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: UIAccessibility.invertColorsStatusDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
        let splitDetail = splitDetailNav?.topViewController
        if splitDetail is EADescriptionViewController {
            trackSelectedEA()
        }
    }
    
    @objc func login(_ notification: Notification) {
        let object = notification.object as! [String:Any]
        let userAccount = object["account"]
        currentAccount = userAccount as? UserAccount
        
        tableView.reloadData()
    }
    
    @objc func logout(_ notification: Notification) {
        currentAccount = nil
        
        tableView.reloadData()
    }
    
    @objc func eaUpdated(_ notification: Notification) {
        let obj = notification.object as! [String:Any]
        let updatedEA = obj["updatedea"] as! EnrichmentActivity
        
        let currentUpdatedEA = allEA.filter { (ea) -> Bool in
            return ea.id == updatedEA.id
        }
        
        let currentEA = currentUpdatedEA[0]
        
        let position = allEA.firstIndex(of: currentEA)!
        
        allEA[position] = updatedEA
        
        updateJoinableEA()
        
        tableView.reloadData()
    }
    
    @objc func eaCreated(_ notification: Notification) {
        let obj = notification.object as! [String:Any]
        let createdEA = obj["ea"] as! EnrichmentActivity
        allEA.append(createdEA)
        updateJoinableEA()
        tableView.reloadData()
    }
    
    @objc func refresh() {
        allEA.removeAll()
        downloadEAList()
    }
    
    @IBAction func filterModeChanged(_ sender: Any) {
        let control = sender as! UISegmentedControl
        filterMode = control.selectedSegmentIndex + 1
        
        if isFiltering() {
            sortFilteredEA()
        }
        
        updateJoinableEA()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source and delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loading == true || allEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            return 1
        } else if loading == false && joinableEA.count > 0 {
            if isFiltering() {
                return filteredEA.count
            } else {
                return joinableEA.count
            }
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if loading == true {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell")!
        } else if joinableEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "NothingCell")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EACell", for: indexPath) as! EAListCell
            
            // Configure the cell...
            
            let ea: EnrichmentActivity
            if isFiltering() {
                ea = filteredEA[indexPath.row]
            } else {
                ea = joinableEA[indexPath.row]
            }
            
            cell.nameLabel.text = ea.name
            
            if ea.shortDescription != "" {
                cell.shortDescriptionLabel.text = ea.shortDescription
            } else {
                cell.shortDescriptionLabel.text = "This EA does not have a short description."
            }
            //cell.shortDescriptionLabel.sizeToFit()
            
            cell.currentEA = ea
            
            if currentAccount == nil {
                cell.likeContainerView.isHidden = true
                cell.currentUser = nil
            } else {
                cell.likeContainerView.isHidden = false
                
                cell.liked = ea.likedUserID!.contains(currentAccount!.userID)
                cell.currentUser = currentAccount
                
                cell.likeCountLabel.text = "\(ea.likedUserID!.count)"
            }
            
            // Give it a random color for now
            // TODO: Set color based on category
            let number = 1 + arc4random() % 7
            //let number = indexPath.row + 4
            cell.backgroundColor = UIColor(named: "Table Cell Color \(number)")
    
            // 3D Touch support
            if traitCollection.forceTouchCapability == .available {
                if cell.forceTouchRegistered == false {
                    registerForPreviewing(with: self, sourceView: cell)
                    cell.forceTouchRegistered = true
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if loading == true || joinableEA.count == 0 || (isFiltering() && filteredEA.count == 0) {
            // Loading height
            return 109
        } else {
            // Custom
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if loading == true || joinableEA.count == 0 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            //tableView.deselectRow(at: indexPath, animated: true)
            
            let cell = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: "ShowEADetail", sender: cell)
        } else {
            searchController.searchBar.resignFirstResponder()
            
            let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
            let splitDetail = splitDetailNav?.topViewController
            if !(splitDetail is EADescriptionViewController) {
                performSegue(withIdentifier: "EADescDetail", sender: nil)
                splitViewControllingDelegate?.eaListRequestSplitViewDetail(self)
            } else if splitDetail != splitViewDetail {
                splitViewDetail = splitDetail as? EADescriptionViewController
            }
            
            splitViewDetail?.currentAccount = currentAccount
            
            let eaToDisplay: EnrichmentActivity
            if isFiltering() {
                eaToDisplay = filteredEA[indexPath.row]
            } else {
                eaToDisplay = joinableEA[indexPath.row]
            }
            splitViewDetail?.ea = eaToDisplay
            
            selectedEA = eaToDisplay
            
            if splitViewController!.displayMode != .allVisible {
                // Temporary fix for segue animation
                delay(0.01) {
                    self.hideMasterPane()
                }
            }
        }
    }
    
    // MARK: - Split View
    
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
        
        if segue.identifier == "ShowEADetail" {
            let destinationController = segue.destination as! EADescriptionViewController
            
            destinationController.currentAccount = self.currentAccount
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)!
            
            let ea: EnrichmentActivity
            if isFiltering() {
                ea = filteredEA[indexPath.row]
            } else {
                ea = joinableEA[indexPath.row]
            }
            destinationController.ea = ea
        }
    }
    
    // MARK: - Downloads
    
    func downloadEAList() {
        let urlString = MainServerAddress + "/manageea/getealist.php"
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
                        self.trackSelectedEA()
                    }
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Failed downloading EAs", message: error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Failed downloading EAs", message: "The server returned an invalid response code. (something that's not 200)")
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    self.presentAlert(withTitle: "Failed downloading EAs", message: "This app is having trouble understanding the data that the server had provided. (No JSON data)")
                }
                return
            }
            
            let eaArray = response["allea"] as! [[String:AnyObject]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                self.allEA.append(enrichmentActivity)
            }
            self.updateJoinableEA()
            // Defer...
        }
        dataTask.resume()
    }

    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func updateJoinableEA() {
        joinableEA = allEA.filter { (ea) -> Bool in
            return (ea.approved == 2) || (ea.approved == 3)
        }
        
        joinableEA.sort { (first, second) -> Bool in
            if filterMode == 1 {
                return first.likedUserID!.count > second.likedUserID!.count
            } else if filterMode == 2 {
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            } else if filterMode == 3 {
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedDescending
            }
            return false
        }
    }
    
    func trackSelectedEA() {
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass != .compact {
            // iPad only
            if selectedEA != nil {
                let eaInArray: Int?
                if isFiltering() {
                    eaInArray = filteredEA.firstIndex(of: selectedEA!)
                } else {
                    eaInArray = joinableEA.firstIndex(of: selectedEA!)
                }
                if let row = eaInArray {
                    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .middle)
                } else {
                    // Remove selected EA and show empty detail
                    selectedEA = nil
                    
                    let splitDetailNav = splitViewController?.viewControllers.last as? UINavigationController
                    let splitDetail = splitDetailNav?.topViewController
                    if !(splitDetail is EADescriptionViewController) {
                        performSegue(withIdentifier: "EADescDetail", sender: nil)
                        splitViewControllingDelegate?.eaListRequestSplitViewDetail(self)
                    }
                    splitViewDetail?.currentAccount = currentAccount
                    splitViewDetail?.ea = nil
                    
                    //performSegue(withIdentifier: "EADescDetail", sender: nil)
                }
            }
        }
    }
}

extension EAListViewController: UINavigationControllerDelegate {
    
}

// Extension for searching
extension EAListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        trackSelectedEA()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Name") {
        filteredEA = joinableEA.filter({( ea : EnrichmentActivity) -> Bool in
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
        
        sortFilteredEA()
        
        tableView.reloadData()
    }
    
    func sortFilteredEA() {
        filteredEA.sort { (first, second) -> Bool in
            if filterMode == 1 {
                return first.likedUserID!.count > second.likedUserID!.count
            } else if filterMode == 2 {
                // Sort name ascending
                return first < second
            } else if filterMode == 3 {
                // Sort name descending
                return first > second
            }
            return false
        }
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

// 3D Touch extension
extension EAListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(withIdentifier: "EADesc") as! EADescriptionViewController
        controller.currentAccount = currentAccount
        
        let cell = previewingContext.sourceView as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let ea: EnrichmentActivity
        if isFiltering() {
            ea = filteredEA[indexPath.row]
        } else {
            ea = joinableEA[indexPath.row]
        }
        controller.ea = ea
        
        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.show(viewControllerToCommit, sender: nil)
    }
}
/*
// Table View Cell 3D Touch Extension
fileprivate extension UITableViewCell {
    
}
*/
