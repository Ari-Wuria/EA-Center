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
    
    var allEA: [EnrichmentActivity] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        loadingSpinner.startAnimation(nil)
        
        downloadEAList()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func makeTouchBar() -> NSTouchBar? {
        return customTouchBar
    }

    @IBAction func touchShowBulletin(_ sender: Any) {
        (view.window?.windowController as! MainWindowController).showStudentBulletin(sender)
    }
    
    func downloadEAList() {
        let urlString = MainServerAddress + "/getealist.php"
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            guard error == nil else {
                // Can't download with an error
                print("Error: \(error?.localizedDescription)")
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                print("Response code not 200")
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                print("Not a dictionary")
                return
            }
            
            let eaArray = response["allea"] as! [[String:AnyObject]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                self.allEA.append(enrichmentActivity)
            }
            
            DispatchQueue.main.async {
                self.listTableView.reloadData()
                
                self.loadingIndicatorView.isHidden = true
            }
        }
        dataTask.resume()
    }
    
    func updateEADescription(_ row: Int) {
        let ea = allEA[row]
        let eaName = ea.name
        
        let downloadPath = "/longdescriptions/\(eaName).rtfd.zip"
        let pathEncoded = downloadPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = MainServerAddress + pathEncoded
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { (filePath, urlResponse, error) in
            guard error == nil else {
                // Can't download with an error
                print("Error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            let httpResponse = urlResponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                print("Response code not 200: \(String(describing: httpResponse?.statusCode))")
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
                print("Unzipped file failed or file doesn't exist")
                return
            }
            
            DispatchQueue.main.async {
                self.longDescTextView.textStorage?.setAttributedString(content)
            }
        }
        
        downloadTask.resume()
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // TODO: Set height for longer short descriptions
        return 103
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return allEA.count
    }
    // TODO: Hide unapproved activities in server
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CellIdentifier"), owner: nil) as? EAListCellView
        
        let enrichmentActivity = allEA[row]
        
        cell?.nameLabel.stringValue = enrichmentActivity.name
        cell?.activityID = enrichmentActivity.id
        cell?.shortDescLabel.stringValue = enrichmentActivity.shortDescription
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = listTableView.selectedRow
        
        updateEADescription(row)
    }
 
}
