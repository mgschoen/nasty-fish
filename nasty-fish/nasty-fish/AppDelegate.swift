//
//  AppDelegate.swift
//  nasty-fish
//
//  Created by Martin Schön on 16.11.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController?
//    var commController: CommController!
    var transactionManager: TransactionManager?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        dataController = DataController()
//        assert(dataController == nil, "The dataController canot be nil")
        
//       commController = CommController()
        
        transactionManager = TransactionManager()
//        assert(transactionManager == nil, "The transactionManager canot be nil")
        
        
        // * * * DEBUG: Populate persistent storage with dummy content * * *
        let populator = Populator(dc:dataController!)
        if (populator.storageIsPopulated()) {
            NSLog("Storage is populated with dummy data")
        } else {
            NSLog("Dummy data not found or incomplete")
        }
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        transactionManager?.commController?.stopAdvertisingForPartners()
        transactionManager?.commController?.stopBrowsingForPartners()
        transactionManager?.commController = nil
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        transactionManager?.initializeCommunicationController()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

