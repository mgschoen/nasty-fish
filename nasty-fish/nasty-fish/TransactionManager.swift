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

    var dataController: DataController
    var commController: CommController? = nil
    
    
    
    override init(){
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController!
        
        
        super.init()
        
        
        initializeCommunicationController()
        
    }
    
    func initializeCommunicationController() {
        if let customName = dataController.fetchUserCustomName() {
            if let uuid = dataController.appInstanceId {
                commController = CommController(customName, uuid)
            }
        }
    }
    
    func fetchClients() -> Dictionary<String, String> {
        return commController!.foundPartnersDictionary
    }
    
    func processTransaction(userId: String, customName: String, incoming: Bool, isMoney: Bool, quantity: UInt, category: Any, dueDate: Any, imageURL: String, sameDueDate: Any) -> (Bool, uuid: String) {
        
        let result = commController!.sendExplicitDataToPartner(uuid: userId, customName: customName, incoming: incoming, isMoney: isMoney, quantity: quantity, category: category, dueDate: dueDate, imageURL: imageURL, sameDueDate: sameDueDate)
    
        return result
    }
    
    func process(savedTranscaction: Transaction) {
    
    }
    
    func finalize(clientId: String, transactionId: String, successful: Bool) {
    
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

