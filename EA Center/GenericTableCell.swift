//
//  GenericTableCell.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/14.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class GenericTableCell: UITableViewCell {
    
    var selectable: Bool = true {
        didSet {
            if selectable == false {
                selectionStyle = .none
            } else {
                selectionStyle = .default
            }
        }
    }

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
