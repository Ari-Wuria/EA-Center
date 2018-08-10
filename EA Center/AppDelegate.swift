//
//  AppDelegate.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/19.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    
    var splitViewController: UISplitViewController!
/*
    var splitViewController: UISplitViewController {
        //return window!.rootViewController as! UISplitViewController
        return rootSplitViewController
    }
    */
    
    var masterTabBarController: MyTabBarController {
        return splitViewController.viewControllers.first! as! MyTabBarController
    }
    
    var listNavController: UINavigationController {
        return masterTabBarController.viewControllers?.first! as! UINavigationController
    }
    
    var listViewController: EAListViewController {
        return listNavController.topViewController as! EAListViewController
    }
    
    var managerNavController: UINavigationController {
        return masterTabBarController.viewControllers?[1] as! UINavigationController
    }
    
    var managerController: ManagerViewController {
        return managerNavController.topViewController as! ManagerViewController
    }
    
    var meNavController: UINavigationController {
        return masterTabBarController.viewControllers?[2] as! UINavigationController
    }
    
    var meController: MeViewController {
        return meNavController.topViewController as! MeViewController
    }
    
    var detailNavController: UINavigationController {
        return splitViewController.viewControllers.last! as! UINavigationController
    }
    
    var detailViewController: UIViewController {
        return detailNavController.topViewController!
    }
    
    var deviceToken: String?
    // MARK: - Application did finish launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let defaults: [String:Any] = ["rememberlogin":true, "loginemail":"", "biometriclock":false, "launched": false, "passwordchanged":false, "firstdisplayed":false, "biometricasked":false]
        UserDefaults.standard.register(defaults: defaults)
        
        let firstLaunched = UserDefaults.standard.bool(forKey: "launched")
        if firstLaunched == false {
            // First launch processing
            UserDefaults.standard.set(true, forKey: "rememberlogin")
            UserDefaults.standard.set(true, forKey: "launched")
            UserDefaults.standard.synchronize()
        }
        
        UIImageView.appearance().accessibilityIgnoresInvertColors = true
        
        // -------
        
        let launchController = window!.rootViewController as! LaunchViewController
        launchController.delegate = self
        /*
        // Test Code
        splitViewController = window!.rootViewController as? UISplitViewController
        let controller = LaunchViewController()
        launchScreenPresented(controller, targetController: splitViewController)
    */
        // -------
        registerForPushNotification()
        
        application.applicationIconBadgeNumber = 0
        
        // Check if launched through remote notification
        //if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject] {
            // Get aps dict from notification
            //let aps = notification["aps"] as! [String:AnyObject]
            // Use aps here, test code below
            //let extra = aps["extra"] as! String
            //print("\(extra)")
        //}
        
        return true
    }
    // MARK: - Push Notification
    // Used tutorial: https://www.raywenderlich.com/156966/push-notifications-tutorial-getting-started
    func registerForPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: - Other application delegates
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        self.deviceToken = token
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed registering remote notification: \(error)")
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        let extra = aps["extra"]
        print("\(extra!)")
    }
}

// MARK: - Extension for Split View Handling
extension AppDelegate: EAListSplitViewControlling, ManagerSplitViewControlling, MeSplitViewControlling {
    func currentSplitViewDetail(_ controller: MeViewController) -> UIViewController {
        return detailViewController
    }
    
    func meViewRequestSplitViewDetail(_ controller: MeViewController, mode: Int) {
        controller.splitViewDetail = detailViewController
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }
    
    func eaListRequestSplitViewDetail(_ controller: EAListViewController) {
        //currentDetailController = detailViewController
        controller.splitViewDetail = detailViewController as? EADescriptionViewController
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }
    
    func managerRequestSplitViewDetail(_ controller: ManagerViewController) {
        //currentDetailController = managerDetailController
        controller.splitViewDetail = detailViewController as? EADetailViewController
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
    }
}

extension AppDelegate: LaunchViewControllerDelegate {
    func launchScreenPresented(_ controller: LaunchViewController, targetController: UISplitViewController) {
        // Process iPad split view stuff after launch screen is presented
        if !(window!.rootViewController!.traitCollection.horizontalSizeClass == .compact) {
            splitViewController = targetController
            
            detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            
            masterTabBarController.title = "All EAs"
            
            // App Delegate implemented the view switching
            listViewController.splitViewControllingDelegate = self
            managerController.splitViewControllingDelegate = self
            meController.splitViewControllingDelegate = self
            
            meController.pushNotificationToken = deviceToken
            
            let orientation = UIDevice.current.orientation
            if orientation == .portrait || orientation == .portraitUpsideDown {
                // Wait for crossfade to finish
                delay(0.2) {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.splitViewController.preferredDisplayMode = .primaryOverlay
                    }, completion: { _ in
                        self.splitViewController.preferredDisplayMode = .automatic
                    })
                }
            }
        }
    }
}

// MARK: Subclasses
class MyTabBarController: UITabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        title = tabBar.selectedItem?.title
    }
}
