//
//  TransactionManager.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 18.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit
import Foundation


class TransactionManager : NSObject {

    // MARK: - Variable
    
    var dataController: DataController?
    var commController: CommController? = nil
    
    // MARK: - Init
    
    override init(){
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

        super.init()
    }

    
    // MARK: - Public functions
    
    // create transaction sender
    func sendAndProcess(create transaction: TransactionData) {
        let result = sendExplicitDataToPartner(newTransaction: transaction)
        
        var userInfo:[String: Bool] = ["isCreated": false]
        if (result.0) {
            let transaction = storeNewTransaction(newTransaction: transaction, isSender: true)
            
            if transaction != nil {
                userInfo["isCreated"] = true
            }
        }
        
        // post a notification
        NotificationCenter.default.post(name: .transactionSavedNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    // close transaction sender
    func sendAndProcess(close transaction: Transaction) {
        // Todo use CommController
        
        var userInfo:[String: Bool] = ["isClosed": false]
        
        dataController?.closeTransaction(transaction, returnDate: NSDate())
        userInfo["isClosed"] = true
        
        
        // post a notification
        NotificationCenter.default.post(name: .transactionClosedNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    // create transaction receiver
    func receiveAndProcess(create transaction: TransactionData, accepted: Bool) {
        // called by delegat from CommController
        
        let newTransaction = storeNewTransaction(newTransaction: transaction, isSender: false)
        let userInfo:[String: Transaction?] = ["transaction": newTransaction]
        
        // post a notification
        NotificationCenter.default.post(name: .transactionSavedNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    
    // close transaction receiver
    func receiveAndProcess(close transaction: Transaction, accepted: Bool) {
        // called by delegat from CommController
        
        
        dataController?.closeTransaction(transaction, returnDate: NSDate())
        
        // post a notification
        NotificationCenter.default.post(name: .transactionClosedNotification,
                                        object: nil)
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
            }
        }
        
//        assert(commController == nil, "The commController canot be nil")
    }
    
    func fetchClients() -> [String] {
        // Todo: use CommController
        var partnerIds = ["[User1]", "[User2]", "[User3]"]
        
        partnerIds.append(contentsOf: commController!.foundPartnersIDs)
        
        return partnerIds
    }
    
    func sendExplicitDataToPartner(newTransaction: TransactionData) -> (Bool, uuid: String) {
        // Todo: use CommController
//        return commController!.sendExplicitDataToPartner(uuid: newTransaction.peerId,
//                                                               customName: newTransaction.peerName,
//                                                               incoming: newTransaction.isIncomming,
//                                                               isMoney: newTransaction.isMoney,
//                                                               quantity: newTransaction.quantity!,
//                                                               category: newTransaction.category!,
//                                                               dueDate: newTransaction.dueDate!,
//                                                               imageURL: newTransaction.imageURL!,
//                                                               sameDueDate: newTransaction.dueWhenTransactionIsDue!)
        
        return (true, uuid: "[uuid]")
    }
    
    
    // MARK - CommunicationControllerDelegate
    
    func receivedData(create transaction: TransactionData) {
        let userInfo:[String: TransactionData?] = ["transactionData": transaction]
        
        // post a notification
        NotificationCenter.default.post(name: .createTransactionNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func receiveData(close transactionId: String)
    {
        if let transaction = dataController?.fetchTransaction(uuid: transactionId) {
            let userInfo:[String: Transaction] = ["transaction": transaction]
        
            // post a notification
            NotificationCenter.default.post(name: .closeTransactionNotification,
                                            object: nil,
                                            userInfo: userInfo)
        }
    }
    
    
    // MARK: - DataController
    
    func storeNewTransaction(newTransaction: TransactionData, isSender: Bool) -> Transaction? {
        
        var peer: KnownPeer?
        if (isSender) {
            peer = dataController?.fetchPeer(icloudID: newTransaction.receiverId)
            if peer == nil {
                peer = dataController?.storeNewPeer(icloudID: newTransaction.receiverId, customName: newTransaction.receiverName, avatarURL: nil)
            }
        }
        else {
            peer = dataController?.fetchPeer(icloudID: newTransaction.senderId)
            if peer == nil {
                peer = dataController?.storeNewPeer(icloudID: newTransaction.senderId, customName: newTransaction.senderName, avatarURL: nil)
            }
        }
        
        let transaction = dataController?.storeNewTransaction(
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

