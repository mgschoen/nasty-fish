//
//  TransactionData.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 21.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation

// Helper datatype to work with unsaved transactions
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

// extending Notification with the nastyfish notifications
extension Notification.Name {
    static let transactionSavedNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionSaved")
    
    static let transactionClosedNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionClosed")
    
    static let createTransactionNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.creatTransaction")
    
    static let closeTransactionNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.closeTransaction")
}
