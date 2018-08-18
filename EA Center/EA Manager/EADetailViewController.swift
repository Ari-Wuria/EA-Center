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
    
    @IBOutlet weak var maxStudentSelector: UISegmentedControl!
    
    var selectedCategoryID: Int?
    @IBOutlet var categoryLabel: UILabel!
    
    var working = false
    
    var currentEA: EnrichmentActivity? {
        didSet {
            if isViewLoaded {
                if navigationController?.topViewController != self {
                    navigationController?.popToViewController(self, animated: true)
                }
                viewUpdated = false
                updateUI()
            }
        }
    }
    
    var viewUpdated: Bool = false
    
    var currentAccount: UserAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = currentEA?.name ?? "EA Center"
        
        if currentEA != nil {
            updateUI()
        }
    }
    
    func updateUI() {
        if !viewUpdated {
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
            
            selectedCategoryID = currentEA!.categoryID
            categoryLabel.text = currentEA!.categoryForDisplay()
            viewUpdated = true
            
            maxStudentSelector.selectedSegmentIndex = currentEA!.maxStudents
        }
    }
    
    func saveData() {
        let weekMode = weekSelector.selectedSegmentIndex + 1
        let timeMode = timeSelector.selectedSegmentIndex + 1
        let location = locationTextField.text!
        let minGrade = minGradeSelector.selectedSegmentIndex + 6
        let maxGrade = maxGradeSelector.selectedSegmentIndex + 6
        
        let maxStudents = maxStudentSelector.selectedSegmentIndex
        
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
        
        guard days.count > 0 else {
            presentAlert(withTitle: "Invalid days", message: "Please select at least 1 running day.")
            working = false
            return
        }
        
        let realMaxStudents = EnrichmentActivity.actualMaxStudent(count: maxStudents)
        guard realMaxStudents > currentEA!.joinedCount! || realMaxStudents < 0 else {
            presentAlert(withTitle: "Can not update max student count", message: "Max student count can not be less than the amount of currently joined students.")
            working = false
            return
        }
        
        let daysString = days.map{"\($0)"}.joined(separator: ",")
        
        currentEA?.updateDetail(newWeekMode: weekMode, newTimeMode: timeMode, newLocation: location, newMinGrade: minGrade, newMaxGrade: maxGrade, newShortDesc: nil, newProposal: nil, newDays: daysString, newCategory: selectedCategoryID!, newMaxStudentsCount: maxStudents) { (success, errString) in
            if success {
                self.presentAlert(withTitle: "Success", message: "EA Info Updated")
            } else {
                self.presentAlert(withTitle: "Failed updating EA info", message: errString!)
            }
            
            NotificationCenter.default.post(name: EAUpdatedNotification, object: ["updatedea":self.currentEA])
            
            self.working = false
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
        /*
        if indexPath.section == 0 && (indexPath.row != 7 || indexPath.row == 6) {
            return nil
        }
 */
        switch (indexPath.section, indexPath.row) {
        case (0, 6), (0, 8), (1, _), (2, _), (3, _), (4, _):
            return indexPath
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 8 {
            // Dismiss the location text field
            self.locationTextField.resignFirstResponder()
            
            if working == true {
                return
            }
            
            working = true
            
            // Save
            saveData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EditDesc" {
            let controller = segue.destination as! TextEditorViewController
            controller.currentEA = currentEA
            controller.saveMode = 1
            controller.title = "Short Description"
        } else if segue.identifier == "EditProposal" {
            let controller = segue.destination as! TextEditorViewController
            controller.currentEA = currentEA
            controller.saveMode = 2
            controller.title = "Proposal"
        } else if segue.identifier == "EditPoster" {
            let controller = segue.destination as! EditPosterViewController
            controller.ea = currentEA
        } else if segue.identifier == "ShowLeaders" {
            let controller = segue.destination as! EALeadersViewController
            controller.currentEA = currentEA
            controller.currentAccount = currentAccount
        } else if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.delegate = self
        } else if segue.identifier == "TakeAttendance" {
            let controller = segue.destination as! AttendanceViewController
            controller.currentEA = currentEA!
        }
    }

    deinit {
        print("deinit: \(self)")
    }
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
                    self.backgroundColor = UIColor.clear
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

extension EADetailViewController: CategoryPickerViewControllerDelegate {
    func categoryPickerViewController(_ controller: CategoryPickerViewController, didPickCategory categoryID: Int, _ categoryString: String) {
        navigationController?.popViewController(animated: true)
        // Delay to fix a wierd big where the label don't update.
        selectedCategoryID = categoryID
        categoryLabel.text = categoryString
    }
}
