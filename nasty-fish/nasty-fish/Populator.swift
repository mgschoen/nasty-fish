//
//  Populator.swift
//  nasty-fish
//
//  Created by Martin Schön on 13.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import Foundation

class Populator : NSObject {
    
    private var dataController : DataController
    
    // * * * * * * Dummy Data Definition * * * * * * //
    
    private struct transactionDummy {
        var itemDescription: String,
            peer: Int,
            incoming: Bool,
            isMoney: Bool,
            quantity: UInt?,
            category: String?,
            dueDate: NSDate?,
            imageURL: String?,
            dueWhenTransactionIsDue: Int?
    }
    
    private var peerDummyData = [
        [ "icloudID": "peter.pan@gmx.de", "customName": "Peter Pan" ],
        [ "icloudID": "rudi.ruessel@yahoo.com", "customName": "Rennschwein Rudi Rüssel" ],
        [ "icloudID": "sindbad_see@aol.com", "customName": "Sindbad der Seefahrer" ],
        [ "icloudID": "donduck333@duckto.wn", "customName": "Donald Duck" ],
        [ "icloudID": "mick-mouse@gmail.com", "customName": "Mickey Maus" ],
        [ "icloudID": "benjamin.bluemchen@icloud.com", "customName": "Benni" ]
    ]
    
    private var transactionDummyData = [
        
        // With peter
        transactionDummy(
            itemDescription: "Flöte",
            peer: 0,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: nil,
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Captain Hooks Haken",
            peer: 0,
            incoming: true,
            isMoney: false,
            quantity: 2,
            category: nil,
            dueDate: NSDate(timeIntervalSinceNow: 604800.0),
            imageURL: "/images/transactions/hook.jpg",
            dueWhenTransactionIsDue: nil),
        
        // With Rudi
        transactionDummy(
            itemDescription: "Tröte",
            peer: 1,
            incoming: true,
            isMoney: false,
            quantity: 2,
            category: "music",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Schweinebraten",
            peer: 1,
            incoming: true,
            isMoney: false,
            quantity: 5,
            category: "food",
            dueDate: nil,
            imageURL: "/images/transactions/braten.jpg",
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Preisgeld",
            peer: 1,
            incoming: true,
            isMoney: true,
            quantity: 100000,
            category: nil,
            dueDate: NSDate(timeIntervalSinceNow: 2419200.0),
            imageURL: nil,
            dueWhenTransactionIsDue: 3),
        transactionDummy(
            itemDescription: "Pokal",
            peer: 1,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "sports",
            dueDate: NSDate(timeIntervalSinceNow: 31536000.0),
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Seifenkiste",
            peer: 1,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "sports",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        
        // With Sindbad
        transactionDummy(
            itemDescription: "Segel",
            peer: 2,
            incoming: true,
            isMoney: false,
            quantity: 1,
            category: "sports",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        
        // With Donald
        transactionDummy(
            itemDescription: "Autoreparatur",
            peer: 3,
            incoming: false,
            isMoney: true,
            quantity: 50000,
            category: "money",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Irgendwelche Schulden",
            peer: 3,
            incoming: false,
            isMoney: true,
            quantity: 150000,
            category: "money",
            dueDate: NSDate(timeIntervalSinceNow: 2419200.0),
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        
        // With Mickey
        transactionDummy(
            itemDescription: "Schlapphut",
            peer: 4,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: nil,
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        
        // With Benjamin
        transactionDummy(
            itemDescription: "Zooticket",
            peer: 5,
            incoming: true,
            isMoney: true,
            quantity: 1000,
            category: "animals",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil),
        transactionDummy(
            itemDescription: "Bilderbuch",
            peer: 5,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "books",
            dueDate: nil,
            imageURL: "/images/transactions/book.jpg",
            dueWhenTransactionIsDue: nil)
    ]
    
    // * * * * * * END Dummy Data Definition * * * * * * //
    
    init (dc:DataController) {
        dataController = dc
    }
    
    // Checks persistent storage for dummy data.
    // Returns true if all dummy data defined above is stored.
    // Returns false if at least one entity is missing.
    func storageIsPopulated () -> Bool {
        
        for peer in peerDummyData {
            if (dataController.fetchPeer(icloudID: peer["icloudID"]!) == nil) {
                return false
            }
        }
        
        let storedTransactions = dataController.fetchTransactions()
        for dummy in transactionDummyData {
            var foundDummyInStored = false
            for stored in storedTransactions {
                if (stored.itemDescription == dummy.itemDescription) {
                    foundDummyInStored = true
                    break
                }
            }
            if (!foundDummyInStored) {
                return false
            }
        }
        
        return true
    }
    
    // Saves a bunch of dummy data defined above into the persistent storage
    func populate () {
        
        unpopulate()
        
        // KnownPeers
        var storedPeers = Array<KnownPeer?>(repeating: nil, count: peerDummyData.count)
        var storedTransactions = Array<Transaction?>(repeating: nil, count: transactionDummyData.count)
        
        for (index, peer) in peerDummyData.enumerated() {
            var newPeer = dataController.storeNewPeer(icloudID: peer["icloudID"]!, customName: peer["customName"], avatarURL: nil)
            if (newPeer == nil) {
                newPeer = dataController.fetchPeer(icloudID: peer["icloudID"]!)
            }
            storedPeers[index] = newPeer
        }
        
        // Transactions
        for (index, transaction) in transactionDummyData.enumerated() {
            storedTransactions[index] = dataController.storeNewTransaction(itemDescription: transaction.itemDescription, peer: storedPeers[transaction.peer]!, incoming: transaction.incoming, isMoney: transaction.isMoney, quantity: transaction.quantity, category: transaction.category, dueDate: transaction.dueDate, imageURL: transaction.imageURL, dueWhenTransactionIsDue: (transaction.dueWhenTransactionIsDue == nil) ? nil : storedTransactions[transaction.dueWhenTransactionIsDue!])
        }
    }
    
    // Deletes every entity that is similar to one of the dummy data
    // items defined above from the persistent storage
    func unpopulate () {
        
        let storedTransactions = dataController.fetchTransactions()
        let storedPeers = dataController.fetchPeers()
        
        for storedTransaction in storedTransactions {
            for dummyTransaction in transactionDummyData {
                if (storedTransaction.itemDescription == dummyTransaction.itemDescription
                    && storedTransaction.peer?.icloudID == peerDummyData[dummyTransaction.peer]["icloudID"]) {
                    dataController.delete(transaction: storedTransaction)
                    break
                }
            }
        }
        
        for storedPeer in storedPeers {
            for dummyPeer in peerDummyData {
                if (storedPeer.icloudID == dummyPeer["icloudID"]) {
                    if (storedPeer.transactions?.count == 0) {
                        dataController.delete(peer: storedPeer)
                    }
                    break
                }
            }
        }
        
    }
}
