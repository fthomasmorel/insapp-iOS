//
//  AppDelegate.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit
import Fabric
import CoreData
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var notification: [String: AnyObject]?
    var previousViewController:UIViewController? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        UITabBar.appearance().tintColor = kRedColor
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        
        Fabric.with([Crashlytics.self])
        
        self.notification = launchOptions?[.remoteNotification] as? [String: AnyObject]
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let _ = Credentials.fetch() else { return }
        guard let _ = APIManager.token else { return }
        APIManager.fetchNotifications(controller: self.window!.rootViewController!) { (notifs) in
            let badge = notifs.filter({ (notif) -> Bool in return !notif.seen })
            DispatchQueue.main.async {
                (self.window!.rootViewController!.presentedViewController! as? UITabBarController)?.tabBar.items?[3].badgeValue = "\(badge.count)"
                application.applicationIconBadgeNumber = badge.count
            }
        }
    }
    
    func registerForNotification(completion: (() -> ())? = nil ){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            UIApplication.shared.registerForRemoteNotifications()
            completion?()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token: String = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        
        if let credentials = Credentials.fetch() {
            APIManager.updateNotification(token: token, credentials: credentials)
        }
        
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
        if let credentials = Credentials.fetch(), let controller = self.window?.rootViewController {
            APIManager.login(credentials, controller: controller, completion: { (_, _) in } )
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController, let vc = navigationController.topViewController {
            if self.previousViewController == vc {
                if vc.responds(to: #selector(NewsViewController.scrollToTop)) {
                    vc.perform(#selector(NewsViewController.scrollToTop))
                }
            }
            self.previousViewController = vc;
        }else{
            self.previousViewController = nil;
        }
    }
    
    func activeViewController() -> UIViewController? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let tabController = appDelegate.window!.rootViewController!.presentedViewController as? UITabBarController {
            if let navigationController = tabController.selectedViewController as? UINavigationController {
                return navigationController.topViewController
            }
        }
        return .none
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Insapp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                //fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

