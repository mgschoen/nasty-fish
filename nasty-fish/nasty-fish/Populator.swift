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
        let testFetch2 = dataController.fetchPeer(icloudID: "rudi.ruessel@yahoo.come")
        let testFetch3 = dataController.fetchPeer(icloudID: "benjamin.bluemchen@icloud.com")
        if (testFetch1 == nil && testFetch2 == nil && testFetch3 == nil) {
            return false
        }
        return true
    }
    
    func populate () {
        
        // * * * KnownPeers * * *
        let peter = dataController.storeNewPeer(icloudID: "peter.pan@gmx.de", customName: "Peter Pan", avatarURL: nil)
        let rudi = dataController.storeNewPeer(icloudID: "rudi.ruessel@yahoo.com", customName: "Rudi Rüssel", avatarURL: nil)
        let sindbad = dataController.storeNewPeer(icloudID: "sindbad_see@aol.com", customName: "Sindbad der Seefahrer", avatarURL: nil)
        let donald = dataController.storeNewPeer(icloudID: "donduck333@duckto.wn", customName: "Donald Duck", avatarURL: nil)
        let mickey = dataController.storeNewPeer(icloudID: "mick-mouse@gmail.com", customName: "Mickey Maus", avatarURL: nil)
        let benjamin = dataController.storeNewPeer(icloudID: "benjamin.bluemchen@icloud.com", customName: "Benni", avatarURL: nil)
        
        // * * * Transactions * * *
        let flute = dataController.storeNewTransaction(itemDescription: "Flöte", peer: peter!, incoming: false, isMoney: false, quantity: nil, category: nil, dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        let trombone = dataController.storeNewTransaction(itemDescription: "Tröte", peer: rudi!, incoming: true, isMoney: false, quantity: 2, category: "music", dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        let sail = dataController.storeNewTransaction(itemDescription: "Segel", peer: sindbad!, incoming: true, isMoney: false, quantity: 1, category: "sports", dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        let repair = dataController.storeNewTransaction(itemDescription: "Autoreparatur", peer: donald!, incoming: false, isMoney: true, quantity: 50000, category: "money", dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        let hat = dataController.storeNewTransaction(itemDescription: "Schlapphut", peer: mickey!, incoming: false, isMoney: false, quantity: nil, category: nil, dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        let zooticket = dataController.storeNewTransaction(itemDescription: "Zooticket", peer: benjamin!, incoming: true, isMoney: true, quantity: 1000, category: "animals", dueDate: nil, imageURL: nil, dueWhenTransactionIsDue: nil)
        
        
    }
    
}
