//
//  TransactionData.swift
//  nasty-fish
//
//  Created by manu on 21.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation

struct TransactionData {
    var senderId: String
    var senderName: String
    
    var receiverId: String
    var receiverName: String
    
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

extension Notification.Name {
    static let transactionSavedNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionSaved")
    
    static let transactionClosedNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionClosed")
}
