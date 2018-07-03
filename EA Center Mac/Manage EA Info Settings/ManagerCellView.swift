//
//  ManagerCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/3.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ManagerCellView: NSTableCellView {
    @IBOutlet weak var eaNameLabel: NSTextField!
    @IBOutlet weak var supervisorLabel: NSTextField!
    @IBOutlet weak var numStudentsLabel: NSTextField!
    @IBOutlet weak var locationLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var statusImageView: NSImageView!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
