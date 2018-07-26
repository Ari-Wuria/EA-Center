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
    @IBOutlet weak var likeButton: UIButton!
    
    var liked: Bool = false {
        didSet {
            let imageName = liked ? "Closed Heart" : "Open Heart"
            likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }
    
    var currentEA: EnrichmentActivity?
    var currentUser: UserAccount?
    
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

    @IBAction func toggleLiked(_ sender: Any) {
        liked = !liked
        
        currentEA?.updateLikeState(liked, currentUser!.userID) { (success, errStr) in
            if success {
                // Success
            } else {
                self.liked = !self.liked
            }
        }
    }
}
