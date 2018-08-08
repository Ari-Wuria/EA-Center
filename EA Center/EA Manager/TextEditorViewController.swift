//
//  TextEditorViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/12.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class TextEditorViewController: UITableViewController {
    // Proposal: 2
    // Short Desc.: 1
    var saveMode: Int = 0

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var textView: UITextView!
    var currentEA: EnrichmentActivity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if saveMode == 1 {
            textView.text = currentEA?.shortDescription
        } else if saveMode == 2 {
            textView.text = currentEA?.proposal
        }
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
        
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func save(_ sender: Any) {
        if textView.text.count > 1000 {
            let alert = UIAlertController(title: "Error", message: "Short description and proposal can not be more than 1000 characters long.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let wordCount = textView.text.words.count
        if saveMode == 1 {
            if wordCount > 150 {
                self.spinner.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Short description can not be over 150 words.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            spinner.startAnimating()
            currentEA?.updateShortDesc(newShortDesc: textView.text) { (success, errString) in
                if success {
                    self.spinner.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedea":self.currentEA])
                } else {
                    self.spinner.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: errString, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if saveMode == 2 {
            if wordCount > 150 {
                self.spinner.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Proposal can not be over 100 words.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            spinner.startAnimating()
            currentEA?.updateProposal(newProposal: textView.text) { (success, errString) in
                if success {
                    self.spinner.stopAnimating()
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedea":self.currentEA])
                } else {
                    self.spinner.stopAnimating()
                    let alert = UIAlertController(title: "Error", message: errString, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return getWordCount()
    }
    
    func getWordCount() -> String {
        if saveMode == 1 {
            let wordCount = textView.text.words.count
            return "\(wordCount)/150 words"
        } else if saveMode == 2 {
            let wordCount = textView.text.words.count
            return "\(wordCount)/100 words"
        }
        return ""
    }
    
    func updateWordCount() {
        let newtext = getWordCount()
        let label = tableView.footerView(forSection: 0)?.textLabel
        label?.text = newtext
        let newSize = newtext.size(withAttributes: [NSAttributedString.Key.font:label?.font as Any])
        let newSizeAdjusted = CGSize(width: ceil(Double(newSize.width)), height: ceil(Double(newSize.height)))
        label?.frame.size = newSizeAdjusted
    }
    
    deinit {
        print("deinit \(self)")
    }
}

extension TextEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateWordCount()
    }
}
