//
//  ViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    // MARK: - Properties
    @IBOutlet weak var loadingSpinner: NSProgressIndicator!
    @IBOutlet weak var loadingIndicatorView: NSStackView!
    
    @IBOutlet weak var listTableView: NSTableView!
    
    @IBOutlet var customTouchBar: NSTouchBar?
    
    @IBOutlet var longDescTextView: NSTextView!
    @IBOutlet weak var longDescLoadingLabel: NSTextField!
    
    @IBOutlet var statusVisualEffectView: NSVisualEffectView!
    @IBOutlet weak var eaStatusLabel: NSTextField!
    @IBOutlet weak var joinButton: NSButton!
    
    @IBOutlet weak var pencilPaper: NSImageView!
    
    @IBOutlet var debugGestureRecognizer: NSClickGestureRecognizer!
    
    @IBOutlet weak var touchLikeButton: NSButton!
    @IBOutlet weak var touchJoinButton: NSButton!
    
    var debugWindowVisible = false
    var debugWindow: NSWindowController?
    
    var loggedIn: Bool = false
    
    var allEA: [EnrichmentActivity] = []
    var joinableEA: [EnrichmentActivity] = []
    
    var currentAccount: UserAccount?
    
    var downloadTask: URLSessionDownloadTask?
    
    var loading = true
    
    var selectedEA: EnrichmentActivity?
    
    var searching = false
    @IBOutlet weak var searchField: NSSearchField!
    var filteredContent = [EnrichmentActivity]()
    
    // 1: Popularity 2: Name Forward 3: Name Backward
    var filterMode = 1
    @IBOutlet weak var filterPopup: NSPopUpButton!
    
    // Used for reselecting row in table view without updating long desc
    var descriptionNeedsUpdate = true
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.selectionHighlightStyle = .none
        
        loadingSpinner.startAnimation(nil)
        
        downloadEAList()
        
        updateEAStatusLabel()
        
        //longDescTextView.wantsLayer = true
        //longDescTextView.layer?.masksToBounds = false
        
        longDescLoadingLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loggedIn(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOut(_:)), name: LogoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(descriptionUpdated(_:)), name: ManagerDescriptionUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaCreated(_:)), name: EACreatedNotification, object: nil)
        
        statusVisualEffectView.isHidden = true
        
        statusVisualEffectView.material = NSVisualEffectView.Material.appearanceBased
        
        pencilPaper.addGestureRecognizer(debugGestureRecognizer)
        
        searchField.delegate = self
        
        touchLikeButton.isHidden = true
        touchJoinButton.isHidden = true
        
        //longDescTextView.textContainerInset = CGSize(width: 0, height: 30)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        listTableView.backgroundColor = NSColor(named: "Table Color")!
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func descriptionUpdated(_ notification: Notification) {
        let object = notification.object as! [String:Any]
        let updatedID = object["id"] as! Int
        
        let localEAUpdated = allEA.filter { (ea) -> Bool in
            return ea.id == updatedID
        }
        
        let ea = localEAUpdated[0]
        
        let updatedEALocation = allEA.firstIndex(of: ea)!
        
        if listTableView.selectedRow == updatedEALocation {
            let filePath = object["rtfdPath"]
            let content: NSAttributedString
            do {
                content = try NSAttributedString(url: URL(fileURLWithPath: filePath as! String), options: [:], documentAttributes: nil)
            } catch {
                // Unzipped file failed or file doesn't exist
                print("Unzipped file failed or file doesn't exist")
                return
            }
            longDescTextView.textStorage?.setAttributedString(content)
        }
    }
    
    @objc func eaCreated(_ obj: Notification) {
        let dic = obj.object as! [String:Any]
        let ea = dic["ea"] as! EnrichmentActivity
        allEA.append(ea)
        
        updateJoinableEA()
        
        listTableView.reloadData()
    }
    
    @objc func eaUpdated(_ notification: Notification) {
        let object = notification.object as! [String:Any]
        let updatedID = object["id"] as! Int
        
        let localEAUpdated = allEA.filter { (ea) -> Bool in
            return ea.id == updatedID
        }
        
        let ea = localEAUpdated[0]
        
        let updatedEA = object["updatedEA"] as! EnrichmentActivity
        
        let updatedEALocation = allEA.firstIndex(of: ea)!
        
        allEA[updatedEALocation] = updatedEA
        
        updateJoinableEA()
        
        listTableView.reloadData()
    }
    
    @objc func loggedIn(_ notification: Notification) {
        let object = notification.object as! [String:Any]
        let userAccount = object["account"] as! UserAccount
        currentAccount = userAccount
        
        if listTableView.selectedRow != -1 {
            touchLikeButton.isHidden = false
        } else {
            touchLikeButton.isHidden = true
        }
        
        loggedIn = true
        updateEAStatusLabel()
        
        listTableView.reloadData()
    }
    
    @objc func loggedOut(_ notification: Notification) {
        currentAccount = nil
        
        touchLikeButton.isHidden = true
        
        loggedIn = false
        updateEAStatusLabel()
        
        listTableView.reloadData()
    }

    override func makeTouchBar() -> NSTouchBar? {
        return customTouchBar
    }

    @IBAction func touchShowBulletin(_ sender: Any) {
        (view.window?.windowController as! MainWindowController).showStudentBulletin(sender)
    }
    
    func downloadEAList() {
        loading = true
        
        let urlString = MainServerAddress + "/manageea/getealist.php"
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            defer {
                DispatchQueue.main.async {
                    self.loading = false
                    
                    self.listTableView.reloadData()
                    
                    self.loadingIndicatorView.isHidden = true
                    
                    if let selected = self.selectedEA {
                        if self.searching == true {
                            let filtered = self.filteredContent.filter{$0.id == selected.id}
                            if filtered.count == 1 {
                                let newRow = self.filteredContent.firstIndex(of: filtered[0])!
                                self.listTableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
                            }
                        } else {
                            let filtered = self.joinableEA.filter{$0.id == selected.id}
                            if filtered.count == 1 {
                                let newRow = self.joinableEA.firstIndex(of: filtered[0])!
                                self.listTableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
                            }
                        }
                    }
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error!)
                    alert.runModal()
                    self.failedDownloadCleanup()
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
                    self.failedDownloadCleanup()
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:Any]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "The server returned an invalid object. (not a dictionary)"
                    alert.runModal()
                    self.failedDownloadCleanup()
                }
                return
            }
            
            //print(String(data: data!, encoding: .utf8))
            
            let eaArray = response["allea"] as! [[String:Any]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                self.allEA.append(enrichmentActivity)
            }
            self.updateJoinableEA()
        }
        dataTask.resume()
    }
    
    func updateJoinableEA() {
        joinableEA = allEA.filter { (ea) -> Bool in
            // Also include closed EA just for show
            return (ea.approved == 2) || (ea.approved == 3) || (ea.approved == 5)
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
    
    func updateEADescription(_ row: Int) {
        guard row != -1 else {
            // Clear text view
            longDescTextView.string = ""
            statusVisualEffectView.isHidden = true
            longDescLoadingLabel.isHidden = true
            return
        }
        
        statusVisualEffectView.isHidden = false
        
        let ea: EnrichmentActivity
        if searching == false {
            ea = joinableEA[row]
        } else {
            ea = filteredContent[row]
        }
        let eaID = ea.id
        let eaName = ea.name
        
        let downloadPath = "/longdescriptions/\(eaID).rtfd.zip"
        let pathEncoded = downloadPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = MainServerAddress + pathEncoded
        let url = URL(string: urlString)!
        
        if downloadTask != nil {
            downloadTask!.cancel()
            downloadTask = nil
        }
        
        // No cache download
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        downloadTask = session.downloadTask(with: url) { (filePath, urlResponse, error) in
            
            guard error == nil else {
                // Can't download with an error
                DispatchQueue.main.async {
                    if (error as! URLError).code != URLError.cancelled {
                        let alert = NSAlert(error: error!)
                        alert.runModal()
                    }
                }
                return
            }
            
            let httpResponse = urlResponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "The server returned an invalid response. (not 200)"
                    alert.runModal()
                }
                return
            }
            
            let tempDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let unzipLocation = tempDir + "/longdescriptions/\(eaName)"
            let location = unzipLocation + "/\(eaName).rtfd"
            let locationURL = URL(fileURLWithPath: location)
            
            // Unzip
            SSZipArchive.unzipFile(atPath: filePath!.path, toDestination: unzipLocation)
            
            let content: NSAttributedString
            
            do {
                content = try NSAttributedString(url: locationURL, options: [:], documentAttributes: nil)
            } catch {
                // Unzipped file failed or file doesn't exist
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "I can't seems to understand this description file. (unzip file doesn't exist or is invalid)"
                    alert.runModal()
                }
                return
            }
            
            DispatchQueue.main.async {
                // TODO: Scroll to top and update size
                //(self.longDescTextView.enclosingScrollView as! MyScrollView).scrollToTop()
                
                self.longDescTextView.textStorage?.setAttributedString(content)
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
                
                self.longDescLoadingLabel.isHidden = true
            }
        }
        downloadTask!.resume()
    }
    
    func failedDownloadCleanup() {
        loadingIndicatorView.isHidden = true
        // TODO: Show something to show error
    }
    
    func updateEAStatusLabel(with ea: EnrichmentActivity? = nil) {
        if loggedIn == false {
            eaStatusLabel.stringValue = "Login to join EAs"
            joinButton.isHidden = true
            touchJoinButton.isHidden = true
        } else if currentAccount!.accountType == 4 || currentAccount?.accountType == 1 {
            if selectedEA != nil {
                if selectedEA!.joinedUserID!.contains(currentAccount!.userID) {
                    eaStatusLabel.stringValue = "You are already in this EA"
                    joinButton.isHidden = true
                    touchJoinButton.isHidden = true
                } else if selectedEA!.leaderEmails.contains(currentAccount!.userEmail) {
                    eaStatusLabel.stringValue = "You are the leader of this EA"
                    joinButton.isHidden = true
                    touchJoinButton.isHidden = true
                } else {
                    if selectedEA?.approved == 2 {
                        if let ea = ea {
                            eaStatusLabel.stringValue = "Join \(ea.name)!"
                        } else {
                            eaStatusLabel.stringValue = "Join this EA!"
                        }
                        joinButton.isHidden = false
                        joinButton.isEnabled = true
                        touchJoinButton.isHidden = false
                        touchJoinButton.isEnabled = true
                    } else if selectedEA?.approved == 3 {
                        eaStatusLabel.stringValue = "This EA is closed"
                        joinButton.isHidden = false
                        joinButton.isEnabled = false
                        touchJoinButton.isHidden = false
                        touchJoinButton.isEnabled = false
                    } else if selectedEA?.approved == 5 {
                        eaStatusLabel.stringValue = "Waiting for approval"
                        joinButton.isHidden = true
                        touchJoinButton.isHidden = true
                    }
                }
                
                let currentDate = Date()
                if currentDate > (selectedEA?.endDate)! {
                    eaStatusLabel.stringValue = "This EA has ended"
                    joinButton.isHidden = true
                    touchJoinButton.isHidden = true
                }
            }
        } else {
            eaStatusLabel.stringValue = "Only student accounts can join EAs"
            joinButton.isHidden = true
            touchJoinButton.isHidden = true
        }
    }
    
    @IBAction func joinEA(_ sender: Any) {
        let ea: EnrichmentActivity
        if searching {
            ea = filteredContent[listTableView.selectedRow]
        } else {
            ea = joinableEA[listTableView.selectedRow]
        }
        
        let alert = NSAlert()
        alert.messageText = "Are you sure you want to join \(ea.name)?"
        //alert.informativeText = "I will implement joining in the next push"
        alert.addButton(withTitle: "Join!")
        alert.addButton(withTitle: "Cancel")
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "Enter any additional message for the leaders."
        textField.lineBreakMode = NSLineBreakMode.byTruncatingHead
        alert.accessoryView = textField
        alert.beginSheetModal(for: view.window!) { (response) in
            if response == .alertFirstButtonReturn {
                // Join
                //print("Text: \(textField.stringValue)")
                self.joinButton.isEnabled = false
                
                let joinString = textField.stringValue
                ea.updateJoinState(true, self.currentAccount!.userID, self.currentAccount!.username, joinString) { (success, errStr) in
                    if success {
                        self.eaStatusLabel.stringValue = "You are already in this EA"
                        self.joinButton.isHidden = true
                        self.touchJoinButton.isHidden = true
                    } else {
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = errStr!
                        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    }
                }
            }
        }
        alert.window.makeFirstResponder(textField)
    }
    
    @IBAction func touchToggleLike(_ sender: Any) {
        if listTableView.selectedRow != -1 {
            let cellView = listTableView.view(atColumn: 0, row: listTableView.selectedRow, makeIfNecessary: true) as! EAListCellView
            cellView.toggleLikedState() { success in
                if success {
                    let imageName = cellView.liked ? "Closed Heart" : "Open Heart"
                    self.touchLikeButton.image = NSImage(named: imageName)
                }
            }
        }
    }
    
    @IBAction func changeSortMode(_ sender: Any) {
        let popup = sender as! NSPopUpButton
        filterMode = popup.indexOfSelectedItem + 1
        
        if searching {
            sortFilteredContent()
        }
        
        updateJoinableEA()
        listTableView.reloadData()
    }
    
    @IBAction func reloadList(_ sender: Any) {
        allEA = []
        longDescTextView.string = ""
        listTableView.reloadData()
        statusVisualEffectView.isHidden = true
        pencilPaper.isHidden = false
        touchLikeButton.isHidden = true
        touchJoinButton.isHidden = true
        downloadEAList()
    }
    
    @IBAction func showDebugWindow(_ sender: Any) {
        if currentAccount?.accountType == 1 && debugWindowVisible == false {
            let storyboard = NSStoryboard(name: "DebugMenu", bundle: .main)
            let window = storyboard.instantiateInitialController() as! NSWindowController
            window.showWindow(sender)
            debugWindowVisible = true
            debugWindow = window
            
            let closeButton = debugWindow?.window?.standardWindowButton(.closeButton)
            closeButton?.target = self
            closeButton?.action = #selector(debugWindowClosed(_:))
        }
    }
    
    @objc func debugWindowClosed(_ sender: Any) {
        debugWindow?.close()
        
        debugWindowVisible = false
    }
    
    @IBAction func touchShowCampusMap(_ sender: Any) {
        //performSegue(withIdentifier: "ShowCampusMap", sender: sender)
        view.window?.windowController?.performSegue(withIdentifier: "ShowCampusMap", sender: sender)
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

// MARK: - Extensions
// MARK: Table view extension
extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        //return allEA.count
        
        if loading == true {
            return 0
        } else if joinableEA.count == 0 {
            return 1
        } else if searching && searchField.stringValue != "" {
            return filteredContent.count
        } else {
            return joinableEA.count
        }
    }
    
    // TODO: Hide unapproved activities in server
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if joinableEA.count == 0 {
            return tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Nothing"), owner: nil)
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellIdentifier"), owner: nil) as? EAListCellView
        
        //let enrichmentActivity = joinableEA[row]
        let enrichmentActivity: EnrichmentActivity
        if searching && searchField.stringValue != "" {
            enrichmentActivity = filteredContent[row]
        } else {
            enrichmentActivity = joinableEA[row]
        }
        
        cell?.nameLabel.stringValue = enrichmentActivity.name
        //cell?.shortDescLabel.stringValue = enrichmentActivity.shortDescription
        if enrichmentActivity.shortDescription != "" {
            cell?.shortDescLabel.stringValue = enrichmentActivity.shortDescription
        } else {
            cell?.shortDescLabel.stringValue = "This EA does not have a short description."
        }
        
        cell?.ea = enrichmentActivity
        
        if loggedIn {
            // TODO: Check liked
            cell?.likeButtonContainer.isHidden = false
            cell?.userID = currentAccount!.userID
            
            if enrichmentActivity.likedUserID!.contains(currentAccount!.userID) {
                cell?.liked = true
            } else {
                cell?.liked = false
            }
            
            cell?.likeCountLabel.stringValue = "\(enrichmentActivity.likedUserID!.count)"
        } else {
            cell?.likeButtonContainer.isHidden = true
        }
        
        cell?.toolTip = tooltip(for: row)
        
        cell?.categoryLabel.stringValue = enrichmentActivity.categoryForDisplay()
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = listTableView.selectedRow
        
        if row == -1 {
            statusVisualEffectView.isHidden = true
            pencilPaper.isHidden = false
            longDescTextView.string = ""
            
            touchJoinButton.isHidden = true
            touchLikeButton.isHidden = true
            return
        }
        
        pencilPaper.isHidden = true
        
        if descriptionNeedsUpdate {
            longDescLoadingLabel.isHidden = false
            longDescTextView.string = ""
            updateEADescription(row)
        }
        
        let ea: EnrichmentActivity
        if searching == false {
            ea = joinableEA[row]
        } else {
            ea = filteredContent[row]
        }
        
        if loggedIn {
            touchLikeButton.isHidden = false
            if ea.likedUserID!.contains(currentAccount!.userID) {
                touchLikeButton.image = NSImage(named: "Closed Heart")
            } else {
                touchLikeButton.image = NSImage(named: "Open Heart")
            }
        } else {
            touchLikeButton.isHidden = true
        }
        
        selectedEA = ea
        
        updateEAStatusLabel(with: selectedEA)
    }
 
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if joinableEA.count == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if searching == false {
            if joinableEA.count > 0 {
                let view = ListRowView()
                let ea = joinableEA[row]
                view.backgroundColorName = "Table Cell Color \(ea.categoryID)"
                return view
            } else {
                return nil
            }
        } else {
            if filteredContent.count > 0 {
                let view = ListRowView()
                let ea = filteredContent[row]
                view.backgroundColorName = "Table Cell Color \(ea.categoryID)"
                return view
            } else {
                return nil
            }
        }
    }
    
    func tooltip(for row: Int) -> String {
        let ea = joinableEA[row]
        let leaderEmail = ea.leaderEmails
        let leaderString: String
        if leaderEmail.count > 1 {
            leaderString = "\(leaderEmail[0]) + \(leaderEmail.count - 1) more"
        } else {
            leaderString = leaderEmail[0]
        }
        let daysMapped = ea.days.map { (dayInt) -> String in
            switch dayInt {
            case 1:
                return "Monday"
            case 2:
                return "Tuesday"
            case 3:
                return "Wednesday"
            case 4:
                return "Thursday"
            case 5:
                return "Friday"
            default:
                return "Unknown Day"
            }
        }
        let daysStr = daysMapped.joined(separator: ", ")
        //return "Location: \(ea.location)\nLeader email: \(leaderString)"
        return """
        Location: \(ea.location)
        Leader email: \(leaderString)
        Days: \(daysStr)
        Running \(ea.weekModeForDisplay().lowercased()) \(ea.timeModeForDisplay())
        """
    }
}

// MARK: Search Extension
extension ViewController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        searching = true
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        searching = false
        listTableView.reloadData()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if searchField.stringValue != "" {
            searching = true
            filteredContent = joinableEA.filter { (ea) -> Bool in
                return ea.name.contains(searchField.stringValue)
            }
            sortFilteredContent()
            
            listTableView.reloadData()
            
            if let selected = selectedEA {
                if filteredContent.contains(selected) {
                    descriptionNeedsUpdate = false
                    let filtered = filteredContent.filter{$0.id == selected.id}
                    if filtered.count == 1 {
                        let newRow = filteredContent.firstIndex(of: filtered[0])!
                        listTableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
                        descriptionNeedsUpdate = true
                    }
                } else {
                    statusVisualEffectView.isHidden = true
                    pencilPaper.isHidden = false
                    longDescTextView.string = ""
                    
                    touchJoinButton.isHidden = true
                    touchLikeButton.isHidden = true
                    
                    selectedEA = nil
                }
            }
        } else {
            searching = false
            
            listTableView.reloadData()
            
            if let selected = selectedEA {
                descriptionNeedsUpdate = false
                let filtered = joinableEA.filter{$0.id == selected.id}
                if filtered.count == 1 {
                    let newRow = joinableEA.firstIndex(of: filtered[0])!
                    listTableView.selectRowIndexes(IndexSet(integer: newRow), byExtendingSelection: false)
                    descriptionNeedsUpdate = true
                }
            }
        }
    }
    
    func sortFilteredContent() {
        filteredContent.sort { (first, second) -> Bool in
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
}

// MARK: - Other subclasses
class ListRowView: NSTableRowView {
    var backgroundColorName: String?
    
    override var isSelected: Bool {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isSelected {
            NSColor(named: "Table Selection Color")!.setFill()
            bounds.fill()
        } else {
            NSColor(named: backgroundColorName!)!.setFill()
            bounds.fill()
        }
    }
}

// TODO: Fix text view clipping
class MyScrollView: NSScrollView {
    
    override var isFlipped: Bool {
        return true
    }
    
    func scrollToTop() {
        documentView?.scroll(CGPoint.zero)
    }
}

class MyTextView: NSTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        //layer = NoClippingLayer()
        //let _ = layer as! NoClippingLayer
        
        needsDisplay = true
        
        textContainerInset = CGSize(width: 0, height: 30)
    }
    
    override var textContainerOrigin: NSPoint {
        let superOrigin = super.textContainerOrigin
        return NSPoint(x: superOrigin.x, y: superOrigin.y - 30)
    }
    
    override var wantsDefaultClipping: Bool {
        return false
    }
}

class NoClippingLayer: CALayer {
    override var masksToBounds: Bool {
        set {
            
        }
        get {
            return false
        }
    }
}
