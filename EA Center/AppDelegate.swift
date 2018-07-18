//
//  AppDelegate.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var splitViewController: UISplitViewController {
        return window!.rootViewController as! UISplitViewController
    }
    
    var masterTabBarController: UITabBarController {
        return splitViewController.viewControllers.first! as! UITabBarController
    }
    
    var listNavController: UINavigationController {
        return masterTabBarController.viewControllers?.first! as! UINavigationController
    }
    
    var listViewController: EAListViewController {
        return listNavController.topViewController as! EAListViewController
    }
    
    var detailNavController: UINavigationController {
        return splitViewController.viewControllers.last! as! UINavigationController
    }
    
    var detailViewController: EADescriptionViewController {
        return detailNavController.topViewController as! EADescriptionViewController
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaults: [String:Any] = ["rememberlogin":true, "loginemail":"", "biometriclock":false]
        UserDefaults.standard.register(defaults: defaults)
        
        UserDefaults.standard.set(true, forKey: "rememberlogin")
        
        UIImageView.appearance().accessibilityIgnoresInvertColors = true
        
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        masterTabBarController.title = "All EAs"
        
        listViewController.splitViewDetail = detailViewController
        
        splitViewController.preferredDisplayMode = .primaryOverlay
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

