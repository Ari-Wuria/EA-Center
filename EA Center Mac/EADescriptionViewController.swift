//
//  EADescriptionViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/20.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa
import WebKit

class EADescriptionViewController: NSViewController {
    @IBOutlet weak var tooltipBarView: NSVisualEffectView!
    @IBOutlet weak var descriptionWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        descriptionWebView.setValue(false, forKey: "drawsBackground")
    }
    
}
