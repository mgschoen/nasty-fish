////
////  ServiceDel.swift
////  nasty-fish
////
////  Created by Michael Gambitz on 11.01.17.
////  Copyright © 2017 Gruppe 08. All rights reserved.
////
//
//import UIKit
//import MultipeerConnectivity
//
//class ServiceDel : NSObject, CommControllerDelegate {
//    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    
//    override init(){
//        super.init()
//        //appDelegate.commController.delegate = self
//    }
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
//        self.appDelegate.transactionManager?.commController?.invitationHandler(true, self.appDelegate.transactionManager?.commController?.session)
//        
//        //Show Alert-Window
//        
//        
//        //try0815:
////        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
////        
////        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
////            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
////        }
////        
////        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
////            self.appDelegate.mpcManager.invitationHandler(false, nil)
////        }
////        
////        alert.addAction(acceptAction)
////        alert.addAction(declineAction)
////        
////        OperationQueue.main.addOperation { () -> Void in
////            self.present(alert, animated: true, completion: nil)
////        }
//
//        
//    }
//    
//    func connectedWithPeer(peerID: MCPeerID){
//        NSLog("%@", "connectedWithPeer: \(peerID)")
//        //Visualize
//
//    }
//}
