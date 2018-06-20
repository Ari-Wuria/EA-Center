//
//  ViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var customTouchBar: NSTouchBar?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func makeTouchBar() -> NSTouchBar? {
        return customTouchBar
    }

    @IBAction func touchShowBulletin(_ sender: Any) {
        (view.window?.windowController as! MainWindowController).showStudentBulletin(sender)
    }
}

