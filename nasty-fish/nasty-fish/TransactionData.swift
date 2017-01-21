//
//  TransactionData.swift
//  nasty-fish
//
//  Created by manu on 21.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation

struct TransactionData {
    var userId: String
    var userName: String
    
    var peerId: String
    var peerName: String
    
    var transactionId: UUID
    var transactionDescription: String
    var isIncomming: Bool
    var isMoney: Bool
    var quantity: UInt?
    var category: String?
    var dueDate: NSDate?
    var imageURL: String?
    var dueWhenTransactionIsDue: Transaction?
    
}

