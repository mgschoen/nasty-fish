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
        
        print("[TransactionManager] Processing sending of transaction \(transaction.transactionDescription)...")

        if (transaction.status == MessageStatus.accepted.rawValue) {
            print("[TransactionManager] Message status == accepted")
            
            if transaction.type == MessageType.create.rawValue {
                print("[TransactionManager] Message type == create")
                _ = storeTransaction(transaction)
            }
            
            if transaction.type == MessageType.close.rawValue {
                print("[TransactionManager] Message type == close")
                closeTransaction(transaction)
            }
        }
        
        // post a notification
        print("[TransactionManager] Sending transactionReplyNotification to NotificationCenter")
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": transaction]
        NotificationCenter.default.post(name: .transactionReplyNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    // transaction receiver
    func process(received transaction: TransactionMessage, accepted: Bool) {
        
        print("[TransactionManager] Processing received transaction \(transaction.transactionDescription)")
        
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
        
        let succeed = sendData(answerMessage)
        
        if accepted && succeed {
            
            print("[TransactionManager] Transaction accepted by user and sending successful")
            
            if transaction.type == MessageType.create.rawValue {
                print("[TransactionManager] Transaction type == create")
                _ = storeTransaction(transaction)
            }
        
            if transaction.type == MessageType.close.rawValue {
                print("[TransactionManager] Transaction type == close")
                closeTransaction(transaction)
            }
        }
            
        // post a notification
        print("[TransactionManager] Sending transactionReplyNotification to Notification Center")
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": answerMessage]
        NotificationCenter.default.post(name: .transactionReplyNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    
    
    // MARK: - CommunicationController
    
    func initializeCommunicationController() {
        
        if commController != nil {
            return
        }
        
        NSLog("TransactionManager.initializeCommunicationController()")
        
        if let customName = dataController?.fetchUserCustomName() {
            if let uuid = dataController?.appInstanceId {
                commController = CommController(customName, uuid)
                
                commController?.delegate = self
                
                commController?.startAdvertisingForPartners()
                commController?.startBrowsingForPartners()
            }
        }
    }
    
    func restartCommunicationController() {
        NSLog("TransactionManager.restartCommunicationController()")
        
        commController = nil
        
        initializeCommunicationController()
    }
    
    func fetchPeerNames() -> [String] {
        return (commController?.peerCustomNames())!
    }
    
    func resolvePeerName(_ peerName: String) -> String {
        return (commController?.resolvePartnerInfo(forName: peerName))!
    }
    
    func sendData(_ transaction: TransactionMessage) -> (Bool) {
        print("[TransactionManager] Sending TransactionMessage to \(transaction.receiverName)")
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
        
        print("[TransactionManager] CommController called receivedData()")
        
        let userInfo:[String: TransactionMessage] = ["TransactionMessage": transaction]
        
        if transaction.status == MessageStatus.request.rawValue {
            print("[TransactionManager] Transaction status == request. User input required")
            // message send to the receiver
            NotificationCenter.default.post(name: .transactionRequestNotification,
                                            object: nil,
                                            userInfo: userInfo)
        } else {
            print("[TransactionManager] Transaction status == \(transaction.status). Processing reply...")
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
