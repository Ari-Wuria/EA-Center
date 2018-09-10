//
//  CampusMapViewController.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/8/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class CampusMapViewController: NSViewController {
    @IBOutlet weak var mapImageView: NSImageView!
    @IBOutlet weak var floorLabel: NSTextField!
    @IBOutlet weak var touchFloorLabel: NSTextField!
    
    @IBOutlet var mainTouchBar: NSTouchBar!
    
    var floorCount = 1
    let minFloorCount = 0
    let maxFloorCount = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func goUp(_ sender: Any) {
        if floorCount == maxFloorCount {
            floorCount = minFloorCount
        } else {
            floorCount += 1
        }
        
        updateMapImage()
        updateLabel()
    }
    
    @IBAction func goDown(_ sender: Any) {
        if floorCount == minFloorCount {
            floorCount = maxFloorCount
        } else {
            floorCount -= 1
        }
        
        updateMapImage()
        updateLabel()
    }
    
    func updateMapImage() {
        let image = NSImage(named: "Map F\(floorCount)")
        mapImageView.image = image
    }
    
    func updateLabel() {
        let labelText: String
        switch floorCount {
        case 0:
            labelText = "Sunken Plaza"
        case 1:
            labelText = "1st Floor"
        case 2:
            labelText = "2nd Floor"
        case 3:
            labelText = "3rd Floor"
        case 4:
            labelText = "4th Floor"
        case 5:
            labelText = "5th Floor"
        default:
            labelText = "Unknown Floor"
            break
        }
        floorLabel.stringValue = labelText
        touchFloorLabel.stringValue = labelText
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        return mainTouchBar
    }
}
