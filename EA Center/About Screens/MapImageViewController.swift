//
//  MapImageViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/6.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class MapImageViewController: UIViewController {
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var floorLabel: UILabel!
    
    private var currentFloor: Int = 1
    
    private var mapImage: UIImage! {
        didSet {
            if isViewLoaded {
                //mapImageView.image = mapImage.rotate(byDegrees: 90)
            }
        }
    }
    
    private var floorText: String! {
        didSet {
            if isViewLoaded {
                floorLabel.text = floorText
            }
        }
    }
    
    var floor: Int {
        get {
            return currentFloor
        }
        
        set (newFloor) {
            currentFloor = newFloor
            mapImage = UIImage(named: "Map F\(newFloor)")
            updateFloorText(newFloor)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //mapImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        if let mapImage = mapImage {
            if UIScreen.main.traitCollection.horizontalSizeClass == .compact {
                mapImageView.image = mapImage.rotate(byDegrees: 90)
            } else {
                mapImageView.image = mapImage
            }
        }
        
        if let floorText = floorText {
            floorLabel.text = floorText
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func updateFloorText(_ newFloor: Int) {
        switch newFloor {
        case 1:
            floorText = "1st Floor"
        case 2:
            floorText = "2nd Floor"
        case 3:
            floorText = "3rd Floor"
        case 4:
            floorText = "4th Floor"
        default:
            break
        }
    }
    
    deinit {
        print("deinit \(self)")
    }
}
