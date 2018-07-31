//
//  EAListCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EAListCellView: NSTableCellView {
    var ea: EnrichmentActivity?
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var shortDescLabel: NSTextField!
    @IBOutlet weak var categoryLabel: NSTextField!
    @IBOutlet weak var likeButton: NSButton!
    @IBOutlet weak var likeButtonContainer: NSStackView!
    @IBOutlet weak var likeCountLabel: NSTextField!
    
    var liked: Bool = false {
        didSet {
            //likeButton.title = liked ? "Unlike" : "Like"
            let imageName = liked ? "Closed Heart" : "Open Heart"
            likeButton.image = NSImage(named: imageName)!
        }
    }
    
    // This will not exist when the like button is hidden
    var userID: Int?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        
        //let rand = 1 + arc4random_uniform(6)
    }
    
    @IBAction func likeActivity(_ sender: Any) {
        // TODO: Do it online too
        toggleLikedState()
    }
    
    func toggleLikedState(online toggleOnline: Bool = true, _ completion: ((_ success: Bool) -> ())? = nil) {
        liked = !liked
        //likeButton.title = liked ? "Unlike" : "Like"
        if toggleOnline {
            updateLikeState(completion)
        }
        
        if !liked {
            let index = ea!.likedUserID!.firstIndex(of: userID!)
            ea?.likedUserID?.remove(at: index!)
        } else {
            ea?.likedUserID?.append(userID!)
        }
        
        likeCountLabel.stringValue = "\(ea!.likedUserID!.count)"
    }
    
    func updateLikeState(_ completion: ((_ success: Bool) -> ())? = nil) {
        ea?.updateLikeState(liked, userID!) { (success, errStr) in
            if success {
                // Success
            } else {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = errStr!
                alert.runModal()
                self.toggleLikedState(online: false)
            }
            completion?(success)
        }
    }
}
