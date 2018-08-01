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
    @IBOutlet weak var likeContainerView: UIStackView!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var forceTouchRegistered = false
    
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
        
        updateLikeLabel()
        
        currentEA?.updateLikeState(liked, currentUser!.userID) { (success, errStr) in
            if success {
                // Success
            } else {
                // Delay to make it not look like nothing happened if it fails
                delay(0.3, {
                    self.liked = !self.liked
                    self.updateLikeLabel()
                })
            }
        }
    }
    
    func updateLikeLabel() {
        if liked {
            currentEA?.likedUserID?.append(currentUser!.userID)
        } else {
            let index = currentEA?.likedUserID?.firstIndex(of: currentUser!.userID)
            currentEA?.likedUserID?.remove(at: index!)
        }
        
        likeCountLabel.text = "\(currentEA!.likedUserID!.count)"
    }
}
