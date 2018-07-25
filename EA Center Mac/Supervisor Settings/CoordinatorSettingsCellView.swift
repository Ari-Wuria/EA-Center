//
//  CoordinatorSettingsCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/7/23.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class CoordinatorSettingsCellView: NSTableCellView {
    @IBOutlet var nameLabel: NSTextField!
    @IBOutlet var leaderLabel: NSTextField!
    @IBOutlet var supervisorLabel: NSTextField!
    @IBOutlet var proposalLabel: NSTextField!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
