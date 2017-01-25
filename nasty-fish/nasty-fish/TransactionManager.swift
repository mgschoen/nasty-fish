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
        let answerMessage = TransactionMessage(type: transaction.type,
                                      status: accepted ? MessageStatus.accepted.rawValue : MessageStatus.declined.rawValue,
                                      senderId: transaction.receiverId,
                                      senderName: transaction.receiverName,
                                      receiverId: transaction.senderId,
                                      receiverName: transaction.senderName,
                                      transactionId: transaction.transactionId,
                                      transactionDescription: transaction.transactionDescription,
                                      isIncomming: transaction.isIncomming,
                                      isMoney: transaction.isMoney,
                                      quantity: transaction.quantity,
                                      category: transaction.category,
                                      dueDate: transaction.dueDate,
                                      imageURL: transaction.imageURL)
        
//        temp.status = accepted ? MessageStatus.accepted.rawValue : MessageStatus.declined.rawValue
//        
//        temp.senderId = transaction.receiverId
//        temp.senderName = transaction.receiverName
//        temp.receiverId = transaction.senderId
//        temp.receiverName = transaction.senderName
        
        let succeed = sendData(answerMessage)
//        assert(!succeed, "sendData failed")
        
        if accepted && succeed {
            if transaction.type == MessageType.create.rawValue {
                _ = storeTransaction(transaction)
            }
        
            if transaction.type == MessageType.close.rawValue {
                closeTransaction(transaction)
            }
        }
            
        // post a notification
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": answerMessage]
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
        return (commController?.peerCustomNames())!
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
        NotificationCenter.default.post(name: .transactionPeersChangedNotification,
                                        object: nil,
                                        userInfo: nil)
    }
    
    func lostPeer() {
        NotificationCenter.default.post(name: .transactionPeersChangedNotification,
                                        object: nil,
                                        userInfo: nil)
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
                
        let transaction = dataController?.storeNewTransaction(itemId: newTransaction.transactionId,
                                                              itemDescription: newTransaction.transactionDescription,
                                                              peer: peer!,
                                                              incoming: newTransaction.status == MessageStatus.request.rawValue ? !newTransaction.isIncomming : newTransaction.isIncomming,
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
