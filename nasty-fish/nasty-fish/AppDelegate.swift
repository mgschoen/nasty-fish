//
//  AppDelegate.swift
//  nasty-fish
//
//  Created by Martin Schön on 16.11.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

// TODO:
//   - Kontext speichern, wenn Anwendung in Hintergrund tritt, beendet wird, etc...
//   - Populator implementieren

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataController: DataController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController = DataController()
        
        print("All known peers:")
        let peers = dataController?.fetchPeers()
        for peer in peers! {
            print(peer.customName! + "s iCloud ID is " + peer.icloudID!)
        }
        
        print("")
        
        let rob = dataController?.fetchPeer(icloudID: "robert_rollmops@piste.fi")
        if (rob != nil) {
            print("Transactions with \((rob!.customName)!):")
            for this in (dataController?.fetchTransactions(withPeer: rob!))! {
                print("\(this.uuid!) - \((this.incoming) ? "Incoming" : "Outgoing") transaction with \(this.peer!.customName!): \(this.itemDescription!)")
            }
        }
        
        print("\nOpen Transactions:")
        let transactions = dataController?.fetchOpenTransactions()
        for transaction in transactions! {
            print("\(transaction.uuid!) - \((transaction.incoming) ? "Incoming" : "Outgoing") transaction with \(transaction.peer!.customName!): \(transaction.itemDescription!)")
        }
        
        print("\nTransaction with uuid 2958232E-A517-4911-8710-F4FEA4E74AF2:")
        let petiTransaction = dataController?.fetchTransaction(uuid: "2958232E-A517-4911-8710-F4FEA4E74AF2")
        if (petiTransaction != nil) {
            print("\(petiTransaction!.uuid!) - \((petiTransaction!.incoming) ? "Incoming" : "Outgoing") transaction with \(petiTransaction!.peer!.customName!): \(petiTransaction!.itemDescription!)")
        }
        
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

