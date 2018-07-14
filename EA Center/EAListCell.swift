//
//  EAListCell.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/29.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class EAListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let view = UIView()
        view.backgroundColor = UIColor(named: "Table Selection Color")
        selectedBackgroundView = view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
