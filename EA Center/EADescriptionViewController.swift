//
//  EADescriptionViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EADescriptionViewController: UIViewController {
    var ea: EnrichmentActivity? {
        didSet {
            if ea != nil {
                if isViewLoaded {
                    textView.text = ""
                    pencilPaper?.isHidden = true
                    updateEADescription()
                    updateEAStatusLabel()
                }
                title = ea!.name
            } else {
                if isViewLoaded {
                    textView.text = ""
                    pencilPaper?.isHidden = false
                }
                title = "EASLINK"
            }
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    var downloadTask: URLSessionDownloadTask?
    
    var loggedIn = false
    var currentAccount: UserAccount? {
        didSet {
            loggedIn = currentAccount == nil ? false : true
        }
    }
    
    @IBOutlet var pencilPaper: UIImageView?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet var joinButton: UIBarButtonItem!
    
    @IBOutlet weak var eaStatusContainerView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Inset the text view above the blur view
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        
        updateEAStatusLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ea != nil {
            if downloadTask == nil {
                updateEADescription()
            }
            title = ea!.name
            
            pencilPaper?.isHidden = true
        } else {
            title = "EASLINK"
            
            textView.text = ""
            
            pencilPaper?.isHidden = false
        }
    }
    
    func updateEADescription() {
        let downloadPath = "/longdescriptions/\(ea!.id).rtfd.zip"
        let pathEncoded = downloadPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = MainServerAddress + pathEncoded
        let url = URL(string: urlString)!
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        
        let session = URLSession.shared
        downloadTask = session.downloadTask(with: url) { (filePath, urlResponse, error) in
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.spinner.stopAnimating()
                }
            }
            
            guard error == nil else {
                // Can't download with an error
                print("Error: \(error!.localizedDescription)")
                self.presentAlert(withTitle: "Can not download description", message: "\(error!.localizedDescription)")
                return
            }
            
            let httpResponse = urlResponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                print("Response code not 200: \(String(describing: httpResponse?.statusCode))")
                self.presentAlert(withTitle: "Can not download description", message: "The server returned an invalid response code. (\(String(describing: httpResponse?.statusCode))")
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
                self.presentAlert(withTitle: "Can not load description", message: "I can't process the file downloaded from the server :(\nPlease try again.")
                return
            }
            
            DispatchQueue.main.async {
                self.textView.attributedText = content
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
                
                //self.longDescLoadingLabel.isHidden = true
            }
        }
        
        downloadTask!.resume()
    }
    
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func toggleJoinButtonVisibility(_ visible: Bool) {
        if !visible {
            navigationItem.rightBarButtonItems = []
        } else {
            navigationItem.rightBarButtonItems = [joinButton]
        }
    }
    
    func updateEAStatusLabel() {
        if ea != nil {
            eaStatusContainerView.isHidden = false
            if loggedIn == false {
                statusLabel.text = "Login to join EAs"
                toggleJoinButtonVisibility(false)
            } else if currentAccount!.accountType == 4 || currentAccount?.accountType == 1 {
                if ea!.joinedUserID!.contains(currentAccount!.userID) {
                    statusLabel.text = "You are already in this EA"
                    toggleJoinButtonVisibility(false)
                } else if ea!.leaderEmails.contains(currentAccount!.userEmail) {
                    statusLabel.text = "You are the leader of this EA"
                    toggleJoinButtonVisibility(false)
                } else {
                    if ea?.approved == 2 {
                        if let ea = ea {
                            statusLabel.text = "Join \(ea.name)!"
                        } else {
                            statusLabel.text = "Join this EA!"
                        }
                        toggleJoinButtonVisibility(true)
                        joinButton.isEnabled = true
                    } else if ea?.approved == 3 {
                        statusLabel.text = "This EA is closed"
                        toggleJoinButtonVisibility(true)
                        joinButton.isEnabled = false
                    } else if ea?.approved == 5 {
                        statusLabel.text = "Waiting for approval"
                        toggleJoinButtonVisibility(false)
                    }
                }
                
                let currentDate = Date()
                if currentDate > (ea?.endDate)! {
                    statusLabel.text = "This EA has ended"
                    toggleJoinButtonVisibility(false)
                }
            } else {
                statusLabel.text = "Only student accounts can join EAs"
                toggleJoinButtonVisibility(false)
            }
        } else {
            eaStatusContainerView.isHidden = true
            toggleJoinButtonVisibility(false)
        }
    }
    
    @IBAction func joinEA(_ sender: Any) {
        let alert = UIAlertController(title: "Join this EA?", message: "Are you sure you want to join \(ea!.name)?", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Note for EA leader"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Join!", style: .default, handler: { (action) in
            let text = alert.textFields![0].text
            self.ea?.updateJoinState(true, self.currentAccount!.userID, self.currentAccount!.username, text!) { (success, errStr) in
                if success {
                    // Success
                    self.updateEAStatusLabel()
                } else {
                    self.presentAlert(withTitle: "Error joining EA", message: errStr!)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("deinit: \(self)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
