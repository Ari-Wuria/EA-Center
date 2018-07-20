//
//  CreateEAViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class CreateEAViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.backgroundColor = UIColor(named: "Menu Color")
    }

    @IBAction func done(_ sender: Any) {
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
