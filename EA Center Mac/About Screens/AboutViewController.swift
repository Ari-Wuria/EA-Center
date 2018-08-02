//
//  AboutViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/1.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        title = "About EASLINK"
        
        imageView.wantsLayer = true
        imageView.canDrawSubviewsIntoLayer = true
        imageView.layer?.masksToBounds = true
        imageView.layer?.cornerRadius = 25
    }
    
    @IBAction func openGithub(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/TomShen1234/EA-Center")!)
    }
    
    @IBAction func showUseOfLibraries(_ sender: Any) {
        // TODO: Add use of library
    }
}
