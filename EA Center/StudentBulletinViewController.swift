//
//  StudentBulletinViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/11.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit
import WebKit

class StudentBulletinViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let urlStr = "http://edublog.bcis.cn/ssbulletin/"
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url)
        webView.load(request)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
