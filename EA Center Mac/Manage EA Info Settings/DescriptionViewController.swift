//
//  DescriptionEditorViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class DescriptionViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //textView.toggleRuler(nil)
    }
    
    @IBAction func save(_ sender: Any) {
    }
}
