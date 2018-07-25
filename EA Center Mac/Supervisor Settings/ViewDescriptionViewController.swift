//
//  ViewDescriptionViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/23.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ViewDescriptionViewController: NSViewController {
    @IBOutlet var descriptionTextView: NSTextView!
    var currentEA: EnrichmentActivity? {
        didSet {
            loadDescription()
        }
    }
    
    var downloadTask: URLSessionDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadDescription() {
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
                if (error as! URLError).code == URLError.cancelled {
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
                    self.showErrorAlert("Can not load poster", "The server returned an invalid response code.")
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
                    self.showErrorAlert("Can not load poster", "Unzipped file failed or file doesn't exist")
                }
                return
            }
            
            DispatchQueue.main.async {
                // TODO: Scroll to top and update size
                //(self.longDescTextView.enclosingScrollView as! MyScrollView).scrollToTop()
                
                self.descriptionTextView.textStorage?.setAttributedString(content)
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
            }
        }
        
        downloadTask!.resume()
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
    
    deinit {
        print("deinit: \(self)")
    }
}
