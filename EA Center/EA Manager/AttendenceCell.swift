//
//  AttendenceCell.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class AttendenceCell: UITableViewCell {
    @IBOutlet weak var studentNameLabel: UILabel!
    
    @IBOutlet weak var attendenceSegmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func markAttendence(_ sender: Any) {
    }
}
