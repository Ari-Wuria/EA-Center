//
//  AttendenceViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AttendenceViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @objc var containingTabViewController: ManagerTabViewController?
    
    @IBOutlet weak var studentListTable: NSTableView!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
