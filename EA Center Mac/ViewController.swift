//
//  ViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
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
    
    var loggedIn: Bool = false
    
    var allEA: [EnrichmentActivity] = []
    var joinableEA: [EnrichmentActivity] = []
    
    var currentAccount: UserAccount?
    
    var downloadTask: URLSessionDownloadTask?
    
    var loading = true
    
    var selectedEA: EnrichmentActivity?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.selectionHighlightStyle = .none
        
        loadingSpinner.startAnimation(nil)
        
        downloadEAList()
        
        updateLoginLabel()
        
        //longDescTextView.wantsLayer = true
        //longDescTextView.layer?.masksToBounds = false
        
        longDescLoadingLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loggedIn(_:)), name: LoginSuccessNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOut(_:)), name: LogoutNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaUpdated(_:)), name: EAUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(descriptionUpdated(_:)), name: ManagerDescriptionUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eaCreated(_:)), name: EACreatedNotification, object: nil)
        
        statusVisualEffectView.isHidden = true
        
        //view.wantsLayer = true
        //view.layer = CALayer()
        //view.layer?.backgroundColor = NSColor(named: "Main Background")?.cgColor
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
        
        loggedIn = true
        updateLoginLabel()
        
        listTableView.reloadData()
    }
    
    @objc func loggedOut(_ notification: Notification) {
        currentAccount = nil
        
        loggedIn = false
        updateLoginLabel()
        
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
                    self.updateJoinableEA()
                    
                    self.listTableView.reloadData()
                    
                    self.loadingIndicatorView.isHidden = true
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
        }
        dataTask.resume()
    }
    
    func updateJoinableEA() {
        joinableEA = allEA.filter { (ea) -> Bool in
            // Also include closed EA just for show
            return (ea.approved == 2) || (ea.approved == 3) || (ea.approved == 5)
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
        
        let ea = joinableEA[row]
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
                    if (error as! URLError).code == URLError.cancelled {
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
    
    func updateLoginLabel() {
        if loggedIn == false {
            eaStatusLabel.stringValue = "Login to join EAs"
            joinButton.isHidden = true
        } else {
            if selectedEA != nil {
                if selectedEA?.approved == 2 {
                    eaStatusLabel.stringValue = "Join this EA!"
                    joinButton.isHidden = false
                    joinButton.isEnabled = true
                } else if selectedEA?.approved == 3 {
                    eaStatusLabel.stringValue = "This EA is closed"
                    joinButton.isHidden = false
                    joinButton.isEnabled = false
                }
                
                let currentDate = Date()
                if currentDate > (selectedEA?.endDate)! {
                    eaStatusLabel.stringValue = "This EA has ended."
                    joinButton.isHidden = true
                }
            }
        }
    }
    
    deinit {
        print("deinit: \(self)")
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        //return allEA.count
        
        if loading == true {
            return 0
        } else if joinableEA.count == 0 {
            return 1
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
        
        let enrichmentActivity = joinableEA[row]
        
        cell?.nameLabel.stringValue = enrichmentActivity.name
        cell?.shortDescLabel.stringValue = enrichmentActivity.shortDescription
        
        cell?.ea = enrichmentActivity
        
        if loggedIn {
            // TODO: Check liked
            cell?.likeButton.isHidden = false
            cell?.userID = currentAccount!.userID
            
            if enrichmentActivity.likedUserID!.contains(currentAccount!.userID) {
                cell?.toggleLikedState(online: false)
            }
        } else {
            cell?.likeButton.isHidden = true
        }
        
        cell?.toolTip = tooltip(for: row)
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = listTableView.selectedRow
        
        longDescTextView.string = ""
        
        if row == -1 {
            statusVisualEffectView.isHidden = true
            pencilPaper.isHidden = false
            return
        }
        
        pencilPaper.isHidden = true
        
        longDescLoadingLabel.isHidden = false
        
        updateEADescription(row)
        
        selectedEA = joinableEA[row]
        updateLoginLabel()
    }
    
    @IBAction func reloadList(_ sender: Any) {
        allEA = []
        longDescTextView.string = ""
        listTableView.reloadData()
        statusVisualEffectView.isHidden = true
        downloadEAList()
    }
 
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if joinableEA.count == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let view = ListRowView()
        let rand = 1 + arc4random_uniform(6)
        view.backgroundColorName = "Table Cell Color \(rand)"
        return view
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
        return "Location: \(ea.location)\nLeader email: \(leaderString)"
    }
}

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
    /*
    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 60.0, right: 0)
    }
 */
}

class MyTextView: NSTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        //layer = NoClippingLayer()
        //let _ = layer as! NoClippingLayer
        
        needsDisplay = true
    }
    
    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 2000.0, right: 0)
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
