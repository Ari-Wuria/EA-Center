//
//  CampusMapViewController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/6.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class CampusMapViewController: UIPageViewController, UIPageViewControllerDataSource {
    var indexMin = 0
    var indexMax = 5
    
    var allMaps = [MapImageViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        dataSource = self
        
        let mapViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MapViewController") as! MapImageViewController
        mapViewController.floor = indexMin
        setViewControllers([mapViewController], direction: .forward, animated: false, completion: nil)
        
        //view.backgroundColor = UIColor(named: "Menu Color")!
        
        // TODO: Add a page control
    }
    
    // MARK: - Page view controller data source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let newMap = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MapViewController") as! MapImageViewController
        let existingMap = viewController as! MapImageViewController
        let floor = existingMap.floor
        let newFloor: Int
        if floor == indexMax {
            newFloor = indexMin
        } else {
            newFloor = floor + 1
        }
        newMap.floor = newFloor
        return newMap
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let newMap = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MapViewController") as! MapImageViewController
        let existingMap = viewController as! MapImageViewController
        let floor = existingMap.floor
        let newFloor: Int
        if floor == indexMin {
            newFloor = indexMax
        } else {
            newFloor = floor - 1
        }
        newMap.floor = newFloor
        return newMap
    }
    /*
    // FIXME: Fix page indicator causing the whole view to push up.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 6
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
 */
}
