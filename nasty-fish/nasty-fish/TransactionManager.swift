//
//  TransactionManager.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 18.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit
import Foundation

class TransactionManager : NSObject, CommControllerDelegate {

    // MARK: - Variable
    
    var dataController: DataController?
    var commController: CommController? = nil
    
    var processingTransaction: TransactionMessage? = nil
    
    // MARK: - Init
    
    override init(){
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

        super.init()
    }

    
    // MARK: - Public functions
    
    // transaction sender
    func process(send transaction: TransactionMessage) {

        if (transaction.status == MessageStatus.accepted.rawValue) {
            if transaction.type == MessageType.create.rawValue {
                _ = storeTransaction(transaction)
            }
            
            if transaction.type == MessageType.close.rawValue {
                closeTransaction(transaction)
            }
        }
        
        // post a notification
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": transaction]
        NotificationCenter.default.post(name: .transactionReplyNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    // transaction receiver
    func process(received transaction: TransactionMessage, accepted: Bool) {
        var temp = transaction
        temp.status = accepted ? MessageStatus.accepted.rawValue : MessageStatus.declined.rawValue
        
        temp.senderId = transaction.receiverId
        temp.senderName = transaction.receiverName
        temp.receiverId = transaction.senderId
        temp.receiverName = transaction.senderName
        
        let succeed = sendData(temp)
        assert(!succeed, "sendData failed")
        
        if accepted && succeed {
            if transaction.type == MessageType.create.rawValue {
                _ = storeTransaction(transaction)
            }
        
            if transaction.type == MessageType.close.rawValue {
                closeTransaction(transaction)
            }
        }
            
        // post a notification
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": temp]
        NotificationCenter.default.post(name: .transactionReplyNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    
    
    // MARK: - CommunicationController
    
    func initializeCommunicationController() {
        print("TransactionManager.initializeCommunicationController()")
        
        if commController != nil {
            return
        }
        
        if let customName = dataController?.fetchUserCustomName() {
            if let uuid = dataController?.appInstanceId {
                commController = CommController(customName, uuid)
                
                commController?.delegate = self
                
                commController?.startAdvertisingForPartners()
                commController?.startBrowsingForPartners()
            }
        }
    }
    
    func fetchPeerNames() -> [String] {
        return (commController?.foundPartnersCustomNames)!
    }
    
    func resolvePeerName(_ peerName: String) -> String {
        let index = commController?.foundPartnersCustomNames.index(of: peerName)
        
        return (commController?.foundPartnersIDs[index!])!
    }
    
    func sendData(_ transaction: TransactionMessage) -> (Bool) {
        return commController!.sendToPartner(transaction)
    }
    
    
    // MARK - CommunicationControllerDelegate
    
    func foundPeers() {
        // Todo
    }
    
    func lostPeer() {
        // Todo
    }
    
    func invitationWasReceived(fromPeer: String) {
        // Todo
    }
    
    func connectedWithPeer(peerID: String) {
        // Todo
    }
    
    func receivedData(_ transaction: TransactionMessage) {
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": transaction]
        
        if transaction.status == MessageStatus.request.rawValue {
            // message send to the receiver
            NotificationCenter.default.post(name: .transactionRequestNotification,
                                            object: nil,
                                            userInfo: userInfo)
        }
        else {
            process(send: transaction)
        }
    }


    // MARK: - DataController

    func storeTransaction(_ newTransaction: TransactionMessage) -> Transaction? {
        
        var peer: KnownPeer?
        peer = dataController?.fetchPeer(icloudID: newTransaction.senderId)
        if peer == nil {
            peer = dataController?.storeNewPeer(icloudID: newTransaction.senderId, customName: newTransaction.senderName, avatarURL: nil)
        }
        
//        if (newTransaction.status == .request) {
//            peer = dataController?.fetchPeer(icloudID: newTransaction.senderId)
//            if peer == nil {
//                peer = dataController?.storeNewPeer(icloudID: newTransaction.senderId, customName: newTransaction.senderName, avatarURL: nil)
//            }
//        }
//        else {
//            peer = dataController?.fetchPeer(icloudID: newTransaction.receiverId)
//            if peer == nil {
//                peer = dataController?.storeNewPeer(icloudID: newTransaction.receiverId, customName: newTransaction.receiverName, avatarURL: nil)
//            }
//        }
        
        let transaction = dataController?.storeNewTransaction(itemId: newTransaction.transactionId,
                                                              itemDescription: newTransaction.transactionDescription,
                                                              peer: peer!,
                                                              incoming: newTransaction.isIncomming,
                                                              isMoney: newTransaction.isMoney,
                                                              quantity: newTransaction.quantity,
                                                              category: nil,
                                                              dueDate: nil,
                                                              imageURL: nil,
                                                              dueWhenTransactionIsDue: nil)
        
        return transaction
    }
    
    func closeTransaction(_ closeTransaction: TransactionMessage) {
        if let transaction = dataController?.fetchTransaction(uuid: String(describing: closeTransaction.transactionId)) {
            dataController?.closeTransaction(transaction, returnDate: NSDate())
        }
    }
    
}

//extension TransactionManager : CommControllerDelegate {
//
//    
//    
////    override init(){
////        super.init()
////        //appDelegate.commController.delegate = self
////    }
//    
//    func foundPeers() {
//        NSLog("%@", "foundPeers -- no peers/sessions info")
//        //UPDATE VIEW
//    }
//    
//    func lostPeer() {
//        NSLog("%@", "lostPeer -- no peer/session info")
//        //UPDATE VIEW
//    }
//    
//    func invitationWasReceived(fromPeer: String) {
//        //Alert-Window to be shown at UI ?
//        //let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
//        NSLog("%@", "invitationWasReceived from: \(fromPeer) at comm delegate")
//        
//        // IN CASE USER MAY ACCEPT AND DECLINE
//        // DEFINE ACTIONS HERE
//        
//        //NO USER QUESTIONING
//        //Completion
////        commController.invitationHandler(true, self.appDelegate.commController.session)
//        
//        //Show Alert-Window
//        
//        
//        //try0815:
//        //        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
//        //
//        //        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
//        //            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
//        //        }
//        //
//        //        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
//        //            self.appDelegate.mpcManager.invitationHandler(false, nil)
//        //        }
//        //
//        //        alert.addAction(acceptAction)
//        //        alert.addAction(declineAction)
//        //
//        //        OperationQueue.main.addOperation { () -> Void in
//        //            self.present(alert, animated: true, completion: nil)
//        //        }
//        
//        
//    }
//    
////    func connectedWithPeer(peerID: MCPeerID){
////        NSLog("%@", "connectedWithPeer: \(peerID)")
////        //Visualize
////        
////    }
//}

