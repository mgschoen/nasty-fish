//
//  DataController.swift
//  nasty-fish
//
//  Created by Martin Schön on 18.11.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

/* TODO:
 *   - Transaction implementieren
       ACHTUNG: Neue Transaktionen müssen auch beim Peer hinterlegt werden
 *   - Wie Bilder speichern?
 *   - Kann diese Klasse das Singleton Pattern erfüllen?
 *   - Soll wirklich jede Änderung persistent gespeichert werden?
 *   - Docs im Wiki!!!
 *   - Convenience Getter getTransactions(peer:KnownPeer) -> Array<Transaction>
 */

import CoreData

class DataController : NSObject {

    // The one and only access point to our persistent storage
    // that cannot be accessed from outside this class
    private var persistentContainer : NSPersistentContainer
    
    // On init an NSPersistentContainer is created that grants access
    // to the persistent storage
    override init(){
        let container = NSPersistentContainer(name: "NastyFish")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer = container
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   CoreData Internals                                                                 *
     * ------------------------------------------------------------------------------------ */
    
    // Save the current state of our Managed Object Context to
    // persistent storage
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
    
    /* ------------------------------------------------------------------------------------ *
     *   KnownPeer                                                                          *
     * ------------------------------------------------------------------------------------ */
    
    // Adds a new peer to the persistent storage
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
    
    /* ------------------------------------------------------------------------------------ *
     *   Transaction                                                                        *
     * ------------------------------------------------------------------------------------ */
    
    // Adds a new transaction to the persistent storage
    func storeNewTransaction
        (itemDescription: String,
        peer: KnownPeer,
        incoming: Bool,
        isMoney: Bool,
        quantity: UInt?,
        category: String?,
        dueDate: NSDate?,
        imageURL: String?,
        dueWhenTransactionIsDue: Transaction?) -> Transaction?
        {
            let managedContext = persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: managedContext)
            let newTransaction = NSManagedObject(entity: entity!, insertInto: managedContext) as? Transaction
            newTransaction?.uuid = UUID().uuidString
            newTransaction?.startDate = NSDate()
            newTransaction?.itemDescription = itemDescription
            newTransaction?.peer = peer
            newTransaction?.incoming = incoming
            newTransaction?.isMoney = isMoney
            if (quantity != nil) {
                newTransaction?.quantity = Int16(quantity!)
            }
            if (category == nil){
                newTransaction?.category = "none"
            } else {
                newTransaction?.category = category
            }
            if (dueDate != nil) {
                newTransaction?.dueDate = dueDate
            }
            if (imageURL == nil) {
                newTransaction?.imageURL = ""
            } else {
                newTransaction?.imageURL = imageURL
            }
            if (dueWhenTransactionIsDue != nil) {
                newTransaction?.dueWhenTransactionIsDue = dueWhenTransactionIsDue
            }
            saveContext()
            return newTransaction
        }
    
    // Returns an array of all transactions in persistent storage
    func fetchTransactions () -> Array<Transaction> {
        let fetchReqquest = NSFetchRequest<Transaction>(entityName: "Transaction")
        var response:Array<Transaction>?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchReqquest) as [Transaction]
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
    
    // Private helper function: Executes a fetch request on the transaction collection
    // with a specified format string
    private func fetchTransactions (byFormatString: String) -> Array<Transaction> {
        let fetchRequest = NSFetchRequest<Transaction>(entityName: "Transaction")
        fetchRequest.predicate = NSPredicate(format: byFormatString)
        var response:[Transaction]?
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest) as [Transaction]
            if (results.count > 0) {
                response = results
            } else {
                response = Array()
            }
        } catch let error as NSError {
            print("Error fetching transactions from storage\n\(error)n\(error.userInfo)")
        }
        return response!
    }
    
    // Returns an array fo all stored transaction with direction specified by
    // "incoming" attribute:
    //   * incoming:true - all incoming transactions
    //   * incoming:false - all outgoing transactions
    func fetchTransactions (incoming: Bool) -> Array<Transaction> {
        return fetchTransactions(byFormatString: "incoming == \(incoming)")
    }
    
    // Returns all open transactions in persistent storage
    func fetchOpenTransactions () -> Array<Transaction> {
        return fetchTransactions(byFormatString: "returnDate == NIL")
    }
    
    // Returns all closed transactions in persistent storage
    func fetchClosedTransactions () -> Array<Transaction> {
        return fetchTransactions(byFormatString: "returnDate <> NIL")
    }
    
    // Searches for a specific transaction by its uuid
    func fetchTransaction (uuid: String) -> Transaction? {
        let searchResult = fetchTransactions(byFormatString: "uuid == \"\(uuid)\"")
        let response:Transaction?
        if (searchResult.count > 0) {
            response = searchResult[0]
        } else {
            response = nil
        }
        return response
    }
}







