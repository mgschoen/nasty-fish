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
    
    func storeNewPeer (icloudID: String, customName: String?) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "KnownPeer", in: managedContext)
        let newPeer = NSManagedObject(entity: entity!, insertInto: managedContext)
        newPeer.setValue(icloudID, forKey:"icloudID")
        if (customName != nil) {
            newPeer.setValue(customName, forKey:"customName")
        }
        saveContext()
    }
    
    func fetchPeerFromStorage (icloudID: String) -> NSManagedObject {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "KnownPeer")
        let formatString = "icloudID like \"" + icloudID + "\""
        fetchRequest.predicate = NSPredicate(format: formatString, argumentArray: [])
        var response:NSManagedObject?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as [NSManagedObject]
            response = results[0]
        } catch let error as NSError {
            print("Error fetching peer from storage\n\(error)n\(error.userInfo)")
        }
        return response!
    }
    
}
