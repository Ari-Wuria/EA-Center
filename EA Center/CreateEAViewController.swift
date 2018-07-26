//
//  CreateEAViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol CreateEAViewControllerDelegate {
    func createEAViewController(_ controller: CreateEAViewController, didFinishWith enrichmentActivity: EnrichmentActivity)
}

class CreateEAViewController: UITableViewController {
    @IBOutlet weak var nameTextField: UITextField!
    var email: String = ""
    
    var delegate: CreateEAViewControllerDelegate?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
        
        nameTextField.delegate = self
    }

    @IBAction func done(_ sender: Any) {
        let name = nameTextField.text!
        if name == "" {
            presentAlert(withTitle: "Error", message: "Please enter a proper EA name.")
        }
        
        doneButton.isEnabled = false
        cancelButton.isEnabled = false
        
        EnrichmentActivity.create(withName: name, email: email) { (success, ea, errStr) in
            if success {
                NotificationCenter.default.post(name: EACreatedNotification, object: ["ea":ea!])
                self.delegate?.createEAViewController(self, didFinishWith: ea!)
            } else {
                self.presentAlert(withTitle: "Can not create EA", message: errStr!)
                
                self.doneButton.isEnabled = true
                self.cancelButton.isEnabled = true
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateEAViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
