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
    func storeNewPeer (icloudID: String, customName: String?, avatarURL: String?) -> KnownPeer? {
        let peersWithThisICloudID = fetchPeer(icloudID: icloudID)
        let resultingPeer:KnownPeer?
        if (peersWithThisICloudID == nil) {
            let managedContext = persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "KnownPeer", in: managedContext)
            let newPeer = NSManagedObject(entity: entity!, insertInto: managedContext) as? KnownPeer
            newPeer?.icloudID = icloudID
            if (customName == nil) {
                newPeer?.customName = ""
            } else {
                newPeer?.customName = customName
            }
            if (avatarURL == nil) {
                newPeer?.avatarURL = ""
            } else {
                newPeer?.avatarURL = avatarURL
            }
            saveContext()
            resultingPeer = newPeer
        } else {
            print("Could not store new peer. Peer with icloudID \"" + icloudID + "\" already exists.")
            resultingPeer = nil
        }
        return resultingPeer
    }
    
    // Returns an array of all peers in persistent storage
    func fetchPeers () -> Array<KnownPeer> {
        let fetchReqquest = NSFetchRequest<KnownPeer>(entityName: "KnownPeer")
        var response:Array<KnownPeer>?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchReqquest) as [KnownPeer]
            if (results.count > 0) {
                response = results
            } else {
                response = Array()
            }
        } catch let error as NSError {
            print("Error fetching peer from storage\n\(error)n\(error.userInfo)")
        }
        return response!
    }
    
    // Searches for a known peer by its iCloud ID
    func fetchPeer (icloudID: String) -> KnownPeer? {
        let fetchRequest = NSFetchRequest<KnownPeer>(entityName: "KnownPeer")
        let formatString = "icloudID like \"" + icloudID + "\""
        fetchRequest.predicate = NSPredicate(format: formatString, argumentArray: [])
        var response:KnownPeer?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as [KnownPeer]
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
    func set(peer: KnownPeer, customName: String) {
        peer.customName = customName
        saveContext()
    }
    
    // Sets a new avatar URL for a peer
    func set(peer: KnownPeer, avatarURL: String) {
        peer.avatarURL = avatarURL
        saveContext()
    }
}
