//
//  EditPosterViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/18.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EditPosterViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    
    var ea: EnrichmentActivity?
    var downloadTask: URLSessionDownloadTask?
    var uploadTask: URLSessionUploadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.isHidden = true
        spinner.startAnimating()
        
        updateEADescription()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textView.allowsEditingTextAttributes = true
    }
    
    @objc func keyboardShown(_ aNotification:NSNotification) {
        let info = aNotification.userInfo
        let infoNSValue = info![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let kbSize = infoNSValue.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ aNotification:NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }
    
    func updateEADescription() {
        let downloadPath = "/longdescriptions/\(ea!.id).rtfd.zip"
        let pathEncoded = downloadPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = MainServerAddress + pathEncoded
        let url = URL(string: urlString)!
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let session = URLSession.shared
        downloadTask = session.downloadTask(with: url) { (filePath, urlResponse, error) in
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            let httpResponse = urlResponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                print("Response code not 200: \(String(describing: httpResponse?.statusCode))")
                return
            }
            
            let tempDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let unzipLocation = tempDir + "/longdescriptions/\(self.ea!.id)"
            let location = unzipLocation + "/\(self.ea!.name).rtfd"
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
                self.textView.isHidden = false
                self.spinner.stopAnimating()
                
                self.textView.attributedText = content
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
                
                //self.longDescLoadingLabel.isHidden = true
            }
        }
        
        downloadTask!.resume()
    }
    
    @IBAction func save(_ sender: Any) {
        // Retrive RTFD
        //let rtfd = textView.rtfd(from: NSMakeRange(0, textView.string.count))
        
        // Save RTFD
        let tempSavePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let tempSaveLocation = tempSavePath + "/longdescriptions/\(ea!.name).rtfd"
        let saveLocation = URL(fileURLWithPath: tempSaveLocation)
    
        let attributedString = textView.attributedText
        let fileWrapper: FileWrapper
        do {
            fileWrapper = try attributedString!.fileWrapper(from: NSRange(location: 0, length: (attributedString?.length)!), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType:NSAttributedString.DocumentType.rtfd])
        } catch {
            showAlert(title: "Error", message: "Can not prepare file for upload:\n\(error.localizedDescription)")
            return
        }
        
        do {
            try fileWrapper.write(to: saveLocation, options: .atomic, originalContentsURL: nil)
        } catch {
            showAlert(title: "Error", message: "Can not save file for upload:\n\(error.localizedDescription)")
            return
        }
        
        // Zip RTFD
        let zipLocation = tempSavePath + "/longdescriptions/\(ea!.id).rtfd.zip"
        //SSZipArchive.createZipFile(atPath: zipLocation, withFilesAtPaths: [tempSaveLocation])
        SSZipArchive.createZipFile(atPath: zipLocation, withContentsOfDirectory: tempSaveLocation, keepParentDirectory: true)
        
        // Upload zip through upload task
        let uploadURLString = MainServerAddress + "/longdescriptions/upload.php?filename=\(ea!.id).rtfd.zip"
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
                    self.showAlert(title: "Error", message: "Can not upload file:\n\(error!.localizedDescription)")
                    return
                }
            }
            // Look, I updated the description! 😀
            let httpResponse = response as? HTTPURLResponse
            if httpResponse == nil {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Can not upload file:\nNo Response")
                    return
                }
            }
            
            if httpResponse!.statusCode != 200 {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Can not upload file:\nWrong status code: \(httpResponse!.statusCode)")
                    return
                }
            }
            
            let jsonDict: [String:Any]?
            do {
                try jsonDict = JSONSerialization.jsonObject(with: data!) as? [String:Any]
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Can not understand the server's response:\n\(error.localizedDescription)")
                }
                return
            }
            
            guard let result = jsonDict else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "The server did not give me a response :(")
                }
                return
            }
            
            let success = result["success"] as! Bool
            guard success == true else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Server Error", message: "The server didn't save the file :(")
                }
                return
            }
            
            // Success
            DispatchQueue.main.async {
                //self.dismiss(nil)
                NotificationCenter.default.post(name: ManagerDescriptionUpdatedNotification, object: ["zipPath":zipLocation, "rtfdPath":tempSaveLocation, "id":self.ea!.id])
                
                // Just remove the files on iOS
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: zipLocation))
                try? FileManager.default.removeItem(at: saveLocation)
                
                self.navigationController?.popViewController(animated: true)
                
                // Clear cache
                URLCache.shared.removeAllCachedResponses()
            }
        }
        uploadTask!.resume()
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
