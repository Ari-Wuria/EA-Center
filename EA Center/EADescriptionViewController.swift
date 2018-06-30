//
//  EADescriptionViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EADescriptionViewController: UIViewController {
    var ea: EnrichmentActivity! = EnrichmentActivity()
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = ea.name
        
        textView.text = ""
        updateEADescription()
    }
    
    func updateEADescription() {
        let downloadPath = "/longdescriptions/\(ea.id).rtfd.zip"
        let pathEncoded = downloadPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let urlString = MainServerAddress + pathEncoded
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url) { (filePath, urlResponse, error) in
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
            let unzipLocation = tempDir + "/longdescriptions/\(self.ea.id)"
            let location = unzipLocation + "/\(self.ea.name).rtfd"
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
        
        downloadTask.resume()
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
