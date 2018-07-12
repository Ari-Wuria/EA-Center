//
//  EADetailViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/11.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EADetailViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var weekSelector: UISegmentedControl!
    @IBOutlet var timeSelector: UISegmentedControl!
    
    @IBOutlet var mondayButton: DayButton!
    @IBOutlet var tuesdayButton: DayButton!
    @IBOutlet var wednesdayButton: DayButton!
    @IBOutlet var thursdayButton: DayButton!
    @IBOutlet var fridayButton: DayButton!
    
    @IBOutlet var locationTextField: UITextField!
    
    @IBOutlet var minGradeSelector: UISegmentedControl!
    @IBOutlet var maxGradeSelector: UISegmentedControl!
    
    var currentEA: EnrichmentActivity? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        
        title = currentEA!.name
    }
    
    func updateUI() {
        weekSelector.selectedSegmentIndex = currentEA!.weekMode - 1
        timeSelector.selectedSegmentIndex = currentEA!.timeMode - 1
        locationTextField.text = currentEA!.location
        minGradeSelector.selectedSegmentIndex = currentEA!.minGrade - 6
        maxGradeSelector.selectedSegmentIndex = currentEA!.maxGrade - 6
        
        if currentEA!.days.contains(1) {
            mondayButton.backgroundHighlighted = true
        }
        if currentEA!.days.contains(2) {
            tuesdayButton.backgroundHighlighted = true
        }
        if currentEA!.days.contains(3) {
            wednesdayButton.backgroundHighlighted = true
        }
        if currentEA!.days.contains(4) {
            thursdayButton.backgroundHighlighted = true
        }
        if currentEA!.days.contains(5) {
            fridayButton.backgroundHighlighted = true
        }
    }
    
    func saveData() {
        let weekMode = weekSelector.selectedSegmentIndex + 1
        let timeMode = timeSelector.selectedSegmentIndex + 1
        let location = locationTextField.text!
        let minGrade = minGradeSelector.selectedSegmentIndex + 6
        let maxGrade = maxGradeSelector.selectedSegmentIndex + 6
        
        var days: [Int] = []
        if mondayButton.backgroundHighlighted {
            days.append(1)
        }
        if tuesdayButton.backgroundHighlighted {
            days.append(2)
        }
        if wednesdayButton.backgroundHighlighted {
            days.append(3)
        }
        if thursdayButton.backgroundHighlighted {
            days.append(4)
        }
        if fridayButton.backgroundHighlighted {
            days.append(5)
        }
        let daysString = days.map{"\($0)"}.joined(separator: ",")
        
        currentEA?.updateDetail(newWeekMode: weekMode, newTimeMode: timeMode, newLocation: location, newMinGrade: minGrade, newMaxGrade: maxGrade, newShortDesc: nil, newProposal: nil, newDays: daysString) { (success, errString) in
            if success {
                self.presentAlert(withTitle: "Success", message: "EA Info Updated")
            } else {
                self.presentAlert(withTitle: "Error", message: errString!)
            }
            
            NotificationCenter.default.post(name: EAUpdatedNotification, object: nil)
        }
    }
    
    func presentAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 && indexPath.row != 6 {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 6 {
            // Dismiss the location text field
            self.locationTextField.resignFirstResponder()
            
            // Save
            saveData()
        }
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

/// Button which can toggle highlighted state with custom highlight color.
/// Must be used in storyboard.
class DayButton: UIButton {
    @IBInspectable var highlightTint: UIColor = UIColor.white
    var backgroundHighlighted: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.backgroundHighlighted == true {
                    self.backgroundColor = self.highlightTint
                } else {
                    self.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: #selector(toggleSelected), for: .touchUpInside)
    }
    
    @objc func toggleSelected() {
        backgroundHighlighted = !backgroundHighlighted
    }
}
