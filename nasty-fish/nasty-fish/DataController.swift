//
//  DataController.swift
//  nasty-fish
//
//  Created by Martin Schön on 18.11.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import CoreData

class DataController : NSObject {
    
    var persistentContainer : NSPersistentContainer
    
    override init(){
        let container = NSPersistentContainer(name: "NastyFish")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer = container
    }
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Adds a new peer to the knownPeers table
    func storeNewPeer (icloudID: String, customName: String?) {
        let peersWithThisICloudID = fetchPeerFromStorage(icloudID: icloudID)
        if (peersWithThisICloudID == nil) {
            let managedContext = persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "KnownPeer", in: managedContext)
            let newPeer = NSManagedObject(entity: entity!, insertInto: managedContext)
            newPeer.setValue(icloudID, forKey:"icloudID")
            if (customName == nil) {
                newPeer.setValue("", forKey:"customName")
            } else {
                newPeer.setValue(customName, forKey:"customName")
            }
            saveContext()
        } else {
            print("Could not store new peer. Peer with icloudID \"" + icloudID + "\" already exists.")
        }
    }
    
    // Searches for a known peer by an iCloud ID
    func fetchPeerFromStorage (icloudID: String) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "KnownPeer")
        let formatString = "icloudID like \"" + icloudID + "\""
        fetchRequest.predicate = NSPredicate(format: formatString, argumentArray: [])
        var response:NSManagedObject?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as [NSManagedObject]
            if (results.count > 0) {
                response = results[0]
            } else {
                response = nil
            }
        } catch let error as NSError {
            print("Error fetching peer from storage\n\(error)n\(error.userInfo)")
        }
        return response
    }
    
    // Sets a new custom name for a peer
    func setPeerCustomName (icloudID: String, newCustomName: String) -> NSManagedObject? {
        let peer = fetchPeerFromStorage(icloudID: icloudID)
        if (peer == nil) {
            print("Could not set custom name for peer. Peer with iCloud ID \"" + icloudID + "\" was not found.")
            return nil
        }
        peer?.setValue(newCustomName, forKey: "customName")
        saveContext()
        return peer!
    }
}
