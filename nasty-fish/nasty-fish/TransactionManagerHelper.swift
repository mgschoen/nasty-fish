//
//  TransactionData.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 21.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation

enum MessageType: String {
    case create = "create"
    case close = "close"
}

enum MessageStatus: String {
    case request = "request"
    case accepted = "accepted"
    case declined = "declined"
}

// Helper datatype to work with unsaved transactions
struct TransactionMessage {
    var type: String
    var status: String
    
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
    
    
    static func encode(transactionMessage: TransactionMessage) -> Data {
        let transactionClassObject = HelperClass(transactionMessage: transactionMessage)
        
//        NSKeyedArchiver.archiveRootObject(personClassObject, toFile: HelperClass.path())
        
        return NSKeyedArchiver.archivedData(withRootObject: transactionClassObject)
    }
    
    static func decode(data: Data) -> TransactionMessage? {
        let transactionMessageClassObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? HelperClass
        
        return transactionMessageClassObject?.transactionMessage
    }
    
}

extension TransactionMessage {
    class HelperClass: NSObject, NSCoding {
        
        var transactionMessage: TransactionMessage?
        
        init(transactionMessage: TransactionMessage) {
            self.transactionMessage = transactionMessage
            super.init()
        }
        
        class func path() -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let path = documentsPath?.appending("/TransactionMessage")
            return path!
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let type = aDecoder.decodeObject(forKey: "type") as? String else { transactionMessage = nil; super.init(); return nil }
            guard let status = aDecoder.decodeObject(forKey: "status") as? String else { transactionMessage = nil; super.init(); return nil }
            
            guard let senderId = aDecoder.decodeObject(forKey: "senderId") as? String else { transactionMessage = nil; super.init(); return nil }
            guard let senderName = aDecoder.decodeObject(forKey: "senderName") as? String else { transactionMessage = nil; super.init(); return nil }
            
            guard let receiverId = aDecoder.decodeObject(forKey: "receiverId") as? String else { transactionMessage = nil; super.init(); return nil }
            guard let receiverName = aDecoder.decodeObject(forKey: "senderName") as? String else { transactionMessage = nil; super.init(); return nil }
            
            guard let transactionId = aDecoder.decodeObject(forKey: "transactionId") as? String else { transactionMessage = nil; super.init(); return nil }
            guard let transactionDescription = aDecoder.decodeObject(forKey: "transactionDescription") as? String else { transactionMessage = nil; super.init(); return nil }
            
            let isIncomming = aDecoder.decodeBool(forKey:"isIncomming")
            let isMoney = aDecoder.decodeBool(forKey: "isMoney")
            guard let quantity = aDecoder.decodeObject(forKey: "quantity") as? UInt? else { transactionMessage = nil; super.init(); return nil }
            guard let category = aDecoder.decodeObject(forKey: "category") as? String? else { transactionMessage = nil; super.init(); return nil }
            guard let dueDate = aDecoder.decodeObject(forKey: "dueDate") as? NSDate? else { transactionMessage = nil; super.init(); return nil }
            guard let imageURL = aDecoder.decodeObject(forKey: "imageURL") as? String? else { transactionMessage = nil; super.init(); return nil }
            
            
//            var type: MessageType
//            var status: MessageStatus
//            
//            var senderId: String
//            var senderName: String
//            
//            var receiverId: String
//            var receiverName: String
//            
//            var transactionId: String
//            var transactionDescription: String
//            var isIncomming: Bool
//            var isMoney: Bool
//            var quantity: UInt?
//            var category: String?
//            var dueDate: NSDate?
//            var imageURL: String?
            
            
            transactionMessage = TransactionMessage(type: type, status: status, senderId: senderId, senderName: senderName, receiverId: receiverId, receiverName: receiverName, transactionId: transactionId, transactionDescription: transactionDescription, isIncomming: isIncomming, isMoney: isMoney, quantity: quantity, category: category, dueDate: dueDate, imageURL: imageURL)
            
            super.init()
        }
        
        func encode(with: NSCoder) {
            with.encode(transactionMessage!.type, forKey: "type")
            with.encode(transactionMessage!.status, forKey: "status")
            
            with.encode(transactionMessage!.senderId, forKey: "senderId")
            with.encode(transactionMessage!.senderName, forKey: "senderName")
            
            with.encode(transactionMessage!.receiverId, forKey: "receiverId")
            with.encode(transactionMessage!.receiverName, forKey: "receiverName")
            
            with.encode(transactionMessage!.transactionId, forKey: "transactionId")
            with.encode(transactionMessage!.transactionDescription, forKey: "transactionDescription")
            with.encode(transactionMessage!.isIncomming, forKey: "isIncomming")
            with.encode(transactionMessage!.isMoney, forKey: "isMoney")
            with.encode(transactionMessage!.quantity, forKey: "quantity")
            with.encode(transactionMessage!.category, forKey: "category")
            with.encode(transactionMessage!.dueDate, forKey: "dueDate")
            with.encode(transactionMessage!.imageURL, forKey: "imageURL")
        }
    }
}

// extending Notification with the nastyfish notifications
extension Notification.Name {
    static let transactionRequestNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionRequest")
    
    static let transactionReplyNotification = Notification.Name("de.lmu.ifi.mobile.nastyfish.transactionReply")
}
