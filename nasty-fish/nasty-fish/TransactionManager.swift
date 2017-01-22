//
//  TransactionManager.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 18.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit
import Foundation


//protocol TransactionManagerDelegate {
//    
//    func transactionSaved(transaction: Transaction?)
//}


class TransactionManager : NSObject {

    var dataController: DataController?
    var commController: CommController? = nil
    
//    var delegate: TransactionManagerDelegate?
    
    override init(){
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

        super.init()
        
    }
    
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
        return commController!.foundPartnersIDs
    }
    
    func processTransaction(newTransaction: TransactionData) {
        let result = commController!.sendExplicitDataToPartner(uuid: newTransaction.peerId,
                                                               customName: newTransaction.peerName,
                                                               incoming: newTransaction.isIncomming,
                                                               isMoney: newTransaction.isMoney,
                                                               quantity: newTransaction.quantity!,
                                                               category: newTransaction.category!,
                                                               dueDate: newTransaction.dueDate!,
                                                               imageURL: newTransaction.imageURL!,
                                                               sameDueDate: newTransaction.dueWhenTransactionIsDue!)
        
        var userInfo:[String: Transaction?] = ["transaction": nil]
        
        if (result.0) {
            let transaction = storeNewTransaction(newTransaction: newTransaction)
            
            userInfo["transaction"] = transaction
            
            // post a notification
            NotificationCenter.default.post(name: .transactionSavedNotification,
                                            object: nil,
                                            userInfo: userInfo)
        }
        else {
            // post a notification
            NotificationCenter.default.post(name: .transactionSavedNotification,
                                            object: nil,
                                            userInfo: userInfo)
        }
        
    
    }
    
    func process(savedTranscaction: Transaction) {
    
        
        
    }
    
    func finalize(clientId: String, transactionId: String, successful: Bool) {
    
    }
    
    
    
    // MARK: - DataController
    
    func storeNewTransaction(newTransaction: TransactionData) -> Transaction? {
        
        var peer = dataController?.fetchPeer(icloudID: newTransaction.peerId)
        if peer == nil {
            peer = dataController?.storeNewPeer(icloudID: newTransaction.peerId, customName: newTransaction.peerName, avatarURL: nil)
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

