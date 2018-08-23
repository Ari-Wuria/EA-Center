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
    
    func updateStatusImageView(with status: Int) {
        switch status {
        case 0,6:
            // EA ended will use this as well
            statusImageView.image = NSImage(named: "NSStatusNone")
        case 1,5:
            statusImageView.image = NSImage(named: "NSStatusPartiallyAvailable")
        case 2,3:
            statusImageView.image = NSImage(named: "NSStatusAvailable")
        case 4:
            statusImageView.image = NSImage(named: "NSStatusUnavailable")
        default:
            break
        }
    }
    
}
