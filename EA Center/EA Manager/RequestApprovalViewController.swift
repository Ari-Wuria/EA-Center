//
//  SendApprovalViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class RequestApprovalViewController: UITableViewController {
    enum DatePickerMode {
        case none
        case start
        case end
    }
    
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var done: UIBarButtonItem!
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    private var datePickerVisible = false
    
    var currentEA: EnrichmentActivity!
    
    var startDate: Date = Date()
    // Tomorrow (86400 seconds = 1 day)
    var endDate: Date = Date().addingTimeInterval(86400)
    
    private let dateDisplayFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationController?.modalPresentationStyle = .formSheet
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor(named: "Menu Color")
        
        startDateLabel.text = dateDisplayFormatter.string(from: startDate)
        endDateLabel.text = dateDisplayFormatter.string(from: endDate)
        
        startDatePicker.date = startDate
        endDatePicker.date = endDate
    }

    @IBAction func startDatePickerChanged(_ sender: UIDatePicker) {
        startDate = sender.date
        startDateLabel.text = dateDisplayFormatter.string(from: startDate)
    }
    
    @IBAction func endDatePickerChanged(_ sender: UIDatePicker) {
        endDate = sender.date
        endDateLabel.text = dateDisplayFormatter.string(from: endDate)
    }
    
    // MARK: - Table view data source and delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    deinit {
        print("deinit \(self)")
    }
    
    @IBAction func done(_ sender: Any) {
        if startDate > endDate {
            presentAlert(withTitle: "Error", message: "Start date can not be later than end date")
            return
        }
        
        if startDate < Date() {
            presentAlert(withTitle: "Error", message: "Start date must be after today")
            return
        }
        
        cancel.isEnabled = false
        done.isEnabled = false
        
        currentEA.requestApproval(1, startDate, endDate) { (success, errStr) in
            if success {
                let hudView = RequestApprovalHudView.hud(in: self.navigationController!.view, animated: true)
                hudView.text = "Requested!"
                delay(0.6) {
                    self.performSegue(withIdentifier: "Finished", sender: sender)
                }
            } else {
                self.presentAlert(withTitle: "Error Requesting Approval", message: errStr!)
         
                self.cancel.isEnabled = true
                self.done.isEnabled = true
            }
        }
    }
    
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
