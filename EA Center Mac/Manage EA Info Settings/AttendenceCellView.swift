//
//  AttendenceCellView.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/7.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AttendenceCellView: NSTableCellView {
    @IBOutlet var attendenceSegmentControl: NSSegmentedControl!
    
    var attendenceStudentID: Int!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func attendenceChanged(_ sender: Any) {
        print("Attendence Changed: \(attendenceStudentID ?? 0)")
    }
    
    override func prepareForReuse() {
        attendenceSegmentControl.selectedSegment = -1
    }
}
