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
    
    init (dc:DataController) {
        dataController = dc
    }
    
    func storageIsPopulated () -> Bool {
        let testFetch1 = dataController.fetchPeer(icloudID: "peter.pan@gmx.de")
        let testFetch2 = dataController.fetchPeer(icloudID: "rudi.ruessel@yahoo.com")
        let testFetch3 = dataController.fetchPeer(icloudID: "benjamin.bluemchen@icloud.com")
        var transactionsWithRudi = 0
        let transactions = dataController.fetchTransactions()
        for transaction in transactions {
            if (transaction.peer?.icloudID == "rudi.ruessel@yahoo.com") {
                transactionsWithRudi += 1
            }
        }
        if (testFetch1 != nil && testFetch2 != nil && testFetch3 != nil && transactionsWithRudi > 0) {
            return true
        }
        return false
    }
    
    func populate () {
        
        // * * * KnownPeers * * *
        let peter = dataController.storeNewPeer(icloudID: "peter.pan@gmx.de", customName: "Peter Pan", avatarURL: nil)
        let rudi = dataController.storeNewPeer(icloudID: "rudi.ruessel@yahoo.com", customName: "Rennschwein Rudi Rüssel", avatarURL: nil)
        let sindbad = dataController.storeNewPeer(icloudID: "sindbad_see@aol.com", customName: "Sindbad der Seefahrer", avatarURL: nil)
        let donald = dataController.storeNewPeer(icloudID: "donduck333@duckto.wn", customName: "Donald Duck", avatarURL: nil)
        let mickey = dataController.storeNewPeer(icloudID: "mick-mouse@gmail.com", customName: "Mickey Maus", avatarURL: nil)
        let benjamin = dataController.storeNewPeer(icloudID: "benjamin.bluemchen@icloud.com", customName: "Benni", avatarURL: nil)
        
        // * * * Transactions * * *
        
        // With Peter
        _ = dataController.storeNewTransaction(
            itemDescription: "Flöte",
            peer: peter!,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: nil,
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        _ = dataController.storeNewTransaction(
            itemDescription: "Captain Hooks Haken",
            peer: peter!,
            incoming: true,
            isMoney: false,
            quantity: 2,
            category: nil,
            dueDate: NSDate(timeIntervalSinceNow: 604800.0),
            imageURL: "/images/transactions/hook.jpg",
            dueWhenTransactionIsDue: nil)
        
        // With Rudi
        _ = dataController.storeNewTransaction(
            itemDescription: "Tröte",
            peer: rudi!,
            incoming: true,
            isMoney: false,
            quantity: 2,
            category: "music",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        let braten = dataController.storeNewTransaction(
            itemDescription: "Schweinebraten",
            peer: rudi!,
            incoming: true,
            isMoney: false,
            quantity: 5,
            category: "food",
            dueDate: nil,
            imageURL: "/images/transactions/braten.jpg",
            dueWhenTransactionIsDue: nil)
        _ = dataController.storeNewTransaction(
            itemDescription: "Preisgeld",
            peer: rudi!,
            incoming: true,
            isMoney: true,
            quantity: 100000,
            category: nil,
            dueDate: NSDate(timeIntervalSinceNow: 2419200.0),
            imageURL: nil,
            dueWhenTransactionIsDue: braten)
        _ = dataController.storeNewTransaction(
            itemDescription: "Pokal",
            peer: rudi!,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "sports",
            dueDate: NSDate(timeIntervalSinceNow: 31536000.0),
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        _ = dataController.storeNewTransaction(
            itemDescription: "Seifenkiste",
            peer: rudi!,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "sports",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        
        // With Sindbad
        _ = dataController.storeNewTransaction(
            itemDescription: "Segel",
            peer: sindbad!,
            incoming: true,
            isMoney: false,
            quantity: 1,
            category: "sports",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        
        // With Donald
        _ = dataController.storeNewTransaction(
            itemDescription: "Autoreparatur",
            peer: donald!,
            incoming: false,
            isMoney: true,
            quantity: 50000,
            category: "money",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        _ = dataController.storeNewTransaction(
            itemDescription: "Irgendwelche Schulden",
            peer: donald!,
            incoming: false,
            isMoney: true,
            quantity: 150000,
            category: "money",
            dueDate: NSDate(timeIntervalSinceNow: 2419200.0),
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        
        // With Mickey
        _ = dataController.storeNewTransaction(
            itemDescription: "Schlapphut",
            peer: mickey!,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: nil,
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        
        // With Benjamin
        _ = dataController.storeNewTransaction(
            itemDescription: "Zooticket",
            peer: benjamin!,
            incoming: true,
            isMoney: true,
            quantity: 1000,
            category: "animals",
            dueDate: nil,
            imageURL: nil,
            dueWhenTransactionIsDue: nil)
        _ = dataController.storeNewTransaction(
            itemDescription: "Bilderbuch",
            peer: benjamin!,
            incoming: false,
            isMoney: false,
            quantity: nil,
            category: "books",
            dueDate: nil,
            imageURL: "/images/transactions/book.jpg",
            dueWhenTransactionIsDue: nil)
        
        
    }
    
}
