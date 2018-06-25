//
//  EAListCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EAListCellView: NSTableCellView {
    var activityID: Int = 0
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var shortDescLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func likeActivity(_ sender: Any) {
    }
}
