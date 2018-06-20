//
//  BulletinViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/20.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa
import WebKit

class BulletinViewController: NSViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let requestURL = URL(string: "https://edublog.bcis.cn/ssbulletin/")!
        let request = URLRequest(url: requestURL)
        webView.load(request)
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.doubleValue = Double(webView.estimatedProgress)
            
            if webView.estimatedProgress == 1 {
                delay(0.5) {
                    self.progressBar.isHidden = true
                }
            }
            if webView.estimatedProgress < 0.1 {
                progressBar.isHidden = false
            }
        }
    }
    
    override func viewWillDisappear() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        
        super.viewWillDisappear()
    }
    
}

