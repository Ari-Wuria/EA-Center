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
    }

    @IBAction func save(_ sender: Any) {
        // TODO: - Check word count
        if saveMode == 1 {
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
}
