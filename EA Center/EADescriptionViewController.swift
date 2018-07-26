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
            if isViewLoaded {
                textView.text = ""
                pencilPaper?.isHidden = true
                updateEADescription()
            }
            title = ea!.name
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet var pencilPaper: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = ""
        if ea != nil {
            if downloadTask == nil {
                updateEADescription()
            }
            title = ea!.name
            
            pencilPaper?.isHidden = true
        } else {
            title = "EASLINK"
            
            pencilPaper?.isHidden = false
        }
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
                self.textView.attributedText = content
                
                // Delete file after displaying to prevent taking up space
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: unzipLocation))
                
                //self.longDescLoadingLabel.isHidden = true
            }
        }
        
        downloadTask!.resume()
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
