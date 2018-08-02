//
//  AboutViewController.swift
//  EA Center
//
//  Created by Tom & Jerry on 2018/7/18.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        versionLabel.text = "Version: \(version!)"
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
