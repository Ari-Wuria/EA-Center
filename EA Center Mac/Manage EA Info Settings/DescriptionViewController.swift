//
//  DescriptionEditorViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class DescriptionViewController: NSViewController {
    @objc var containingTabViewController: ManagerTabViewController?
    
    @IBOutlet var textView: NSTextView!
    
    var currentEA: EnrichmentActivity?
    var currentAttributedString: NSAttributedString?
    
    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet var editButton: NSButton!
    @IBOutlet weak var touchEditButton: NSButton!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newNotification(_:)), name: ManagerSelectionChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDescription(_:)), name: ManagerDescriptionUpdatedNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //textView.toggleRuler(nil)
        
        editButton.isEnabled = false
        touchEditButton.isEnabled = false
        
        if currentEA != nil {
            downloadDescription()
        }
    }
    
    
    @objc func newNotification(_ notification: Notification) {
        let ea = notification.object as! EnrichmentActivity
        currentEA = ea
        
        if isViewLoaded {
            editButton.isEnabled = false
            touchEditButton.isEnabled = false
            downloadDescription()
        }
    }
    
    @objc func updateDescription(_ notification: Notification) {
        let dic = notification.object as! [String:Any]
        let zipLocation = dic["zipPath"] as! String
        let rtfdPath = dic["rtfdPath"] as! String
        
        // Update new RTFD
        let content: NSAttributedString
        do {
            content = try NSAttributedString(url: URL(fileURLWithPath: rtfdPath), options: [:], documentAttributes: nil)
        } catch {
            // Unzipped file failed or file doesn't exist
            print("Unzipped file failed or file doesn't exist")
            return
        }
        self.textView.textStorage?.setAttributedString(content)
        
        delay(0.5) {
            // Delete original RTFD and zip
            do {
                try FileManager.default.removeItem(at: URL(fileURLWithPath: zipLocation))
                try FileManager.default.removeItem(at: URL(fileURLWithPath: rtfdPath))
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
                return
            }
        }
    }
    /*
    @IBAction func save(_ sender: Any) {
        
    }
    */
    func downloadDescription() {
        let eaID = currentEA!.id
        let eaName = currentEA!.name
        
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
                //print("Error: \(error!.localizedDescription)")
                if (error as! URLError).code != URLError.cancelled {
                    DispatchQueue.main.async {
                        self.showErrorAlert(nil, nil, error)
                    }
                }
                return
            }
            
            let httpResponse = urlResponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                DispatchQueue.main.async {
                    if httpResponse?.statusCode == 404 {
                        self.showErrorAlert("Error", "Thie EA no longer exists.")
                        NotificationCenter.default.post(name: EADeletedNotification, object: self.currentEA!)
                    }
                    
                    self.showErrorAlert("Can not download poster", "The server returned an invalid response code.")
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
                    self.showErrorAlert("Can not reading poster", "Unzipped file failed or file doesn't exist")
                }
                return
            }
            
            DispatchQueue.main.async {
                // TODO: Scroll to top and update size
                //(self.longDescTextView.enclosingScrollView as! MyScrollView).scrollToTop()
                
                self.textView.textStorage?.setAttributedString(content)
                
                self.currentAttributedString = content
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
                
                self.editButton.isEnabled = true
                self.touchEditButton.isEnabled = true
                
            }
        }
        
        downloadTask!.resume()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditDesc" {
            let controller = segue.destinationController as! EditDescriptionViewController
            controller.currentEA = currentEA
            controller.currentText = currentAttributedString
        }
    }
    
    func showErrorAlert(_ title: String?, _ message: String?, _ error: Error? = nil) {
        let alert: NSAlert
        if let error = error {
            alert = NSAlert(error: error)
        } else if let title = title, let message = message {
            alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
        } else {
            alert = NSAlert()
            alert.messageText = "Error"
        }
        alert.runModal()
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
    
    @IBAction func touchEdit(_ sender: Any) {
        performSegue(withIdentifier: "EditDesc", sender: sender)
    }
}
