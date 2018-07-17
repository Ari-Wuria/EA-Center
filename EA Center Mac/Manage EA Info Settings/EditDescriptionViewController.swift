//
//  EditDescriptionViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EditDescriptionViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet var statusLabel: NSTextField!
    @IBOutlet var saveButton: NSButton!
    
    var currentEA: EnrichmentActivity?
    var currentText: NSAttributedString?
    
    var escEvent: Any?
    
    var uploadTask: URLSessionUploadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        addESCEvent()
        spinner.stopAnimation(nil)
    }
    
    func addESCEvent() {
        escEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            if event.window != self.view.window {
                return event
            }
            
            if event.keyCode == 53 {
                // esc pressed
                self.dismiss(nil)
                return nil
            }
            
            return event
        }
    }
    
    func removeESCEvent() {
        if let event = escEvent {
            NSEvent.removeMonitor(event)
        }
        escEvent = nil
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        textView.textStorage?.setAttributedString(currentText!)
    }
    
    @IBAction func save(_ sender: Any) {
        statusLabel.stringValue = "Saving..."
        spinner.startAnimation(sender)
        saveButton.isEnabled = false
        removeESCEvent()
        
        // Retrive RTFD
        //let rtfd = textView.rtfd(from: NSMakeRange(0, textView.string.count))
        
        // Save RTFD
        let tempSavePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let tempSaveLocation = tempSavePath + "/longdescriptions/\(currentEA!.name).rtfd"
        //let saveLocation = URL(fileURLWithPath: tempSaveLocation)
        /*
        do {
            try rtfd?.write(to: saveLocation)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
            return
        }
        */
        let success = textView.writeRTFD(toFile: tempSaveLocation, atomically: true)
        if !success {
            let alert = NSAlert()
            alert.messageText = "Can not save."
            alert.informativeText = "Can not write file."
            alert.runModal()
            failed()
            return
        }
        
        // Zip RTFD
        let zipLocation = tempSavePath + "/longdescriptions/\(currentEA!.id).rtfd.zip"
        //SSZipArchive.createZipFile(atPath: zipLocation, withFilesAtPaths: [tempSaveLocation])
        SSZipArchive.createZipFile(atPath: zipLocation, withContentsOfDirectory: tempSaveLocation, keepParentDirectory: true)
        
        // Upload zip through upload task
        let uploadURLString = MainServerAddress + "/longdescriptions/upload.php?filename=\(currentEA!.id).rtfd.zip"
        let uploadURL = URL(string: uploadURLString)
        var request = URLRequest(url: uploadURL!)
        request.httpMethod = "POST"
        //let config = URLSessionConfiguration.background(withIdentifier: "eacenter.upload")
        //config.httpMaximumConnectionsPerHost = 1
        //let session = URLSession(configuration: config)
        let session = URLSession.shared
        let fileURL = URL(fileURLWithPath: zipLocation)
        uploadTask = session.uploadTask(with: request, fromFile: fileURL) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error!)
                    alert.runModal()
                    
                    self.failed()
                    return
                }
            }
            // Look, I updated the description! 😀
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error Uploading"
                    alert.informativeText = "Can not upload. (Wrong status code)"
                    alert.runModal()
                    
                    self.failed()
                    return
                }
            }
            
            let jsonDict: [String:Any]?
            do {
                try jsonDict = JSONSerialization.jsonObject(with: data!) as? [String:Any]
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error)
                    alert.runModal()
                    self.failed()
                }
                return
            }
            
            guard let result = jsonDict else {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error Uploading"
                    alert.informativeText = "No Server response!"
                    alert.runModal()
                    
                    self.failed()
                }
                return
            }
            
            let success = result["success"] as! Bool
            guard success == true else {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Error Uploading"
                    alert.informativeText = "Server Error!"
                    alert.runModal()
                    
                    self.failed()
                }
                return
            }
            
            // Success
            DispatchQueue.main.async {
                self.dismiss(nil)
                NotificationCenter.default.post(name: ManagerDescriptionUpdatedNotification, object: ["zipPath":zipLocation, "rtfdPath":tempSaveLocation, "id":self.currentEA!.id])
                
                // Clear cache
                URLCache.shared.removeAllCachedResponses()
            }
        }
        uploadTask!.resume()
    }
    
    func failed() {
        saveButton.isEnabled = true
        addESCEvent()
        spinner.stopAnimation(nil)
        statusLabel.stringValue = "Press esc to cancel"
    }
    
    override func viewDidDisappear() {
        removeESCEvent()
        textView.string = ""
    }
    
    deinit {
        print("Editor deinit")
    }
}
