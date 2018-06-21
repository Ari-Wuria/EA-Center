
//
//  EAManagerViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/21.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EAManagerViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension EAManagerViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 129
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    /*
    func tableView(_ tableView: NSTableView, dataCellFor tableColumn: NSTableColumn?, row: Int) -> NSCell? {
     
    }
 */
}
