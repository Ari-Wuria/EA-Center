//
//  CategoryPickerViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/7.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

protocol CategoryPickerViewControllerDelegate: class {
    func categoryPickerViewController(_ controller: CategoryPickerViewController, didPickCategory categoryID: Int, _ categoryString: String)
}

class CategoryPickerViewController: UITableViewController {
    let categories = ["Uncategorized", "Science and Technologies", "Arts and Crafts", "Sports & Health", "Community Based Groups", "Recreational Activities", "Other"]
    
    weak var delegate: CategoryPickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = categories[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.categoryPickerViewController(self, didPickCategory: indexPath.row, categories[indexPath.row])
    }
}
