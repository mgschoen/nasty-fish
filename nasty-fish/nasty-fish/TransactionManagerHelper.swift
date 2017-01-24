//
//  TransactionData.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 21.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation

enum MessageType {
    case create
    case close
}

enum MessageStatus {
    case request
    case accepted
    case declined
}

// Helper datatype to work with unsaved transactions
struct TransactionMessage {
    var type: MessageType
    var status: MessageStatus
    
    var senderId: String
    var senderName: String
    
    var receiverId: String
    var receiverName: String
    
    var transactionId: String
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
    static let transactionRequestNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionRequest")
    
    static let transactionReplyNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionReply")
}
