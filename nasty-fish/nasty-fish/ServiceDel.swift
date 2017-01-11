//
//  ServiceDel.swift
//  nasty-fish
//
//  Created by Michael Gambitz on 11.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ServiceDel : CommControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func foundPeers() {
        //tblPeers.reloadData()
        //UPDATE VIEW
    }
    
    
    func lostPeer() {
        //tblPeers.reloadData()
        //UPDATE VIEW
    }
    
    func invitationWasReceived(fromPeer: String) {
        //ALERT-Window to be shown at UI ?
        //let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
        NSLog("%@", "invitationWasReceived from: \(fromPeer) at comm delegate")
       
        // IN CASE USER MAY ACCEPT AND DECLINE
//        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (alertAction) -> Void in
//            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
//        }
//        
//        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
//            self.appDelegate.mpcManager.invitationHandler(false, nil)
//        }
//        
//        //alert.addAction(acceptAction)
//        //alert.addAction(declineAction)
        
        //NO USER QUESTIONING
        
        //self.appDelegate.
//        
//        OperationQueue.main.addOperation { () -> Void in
//            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    func connectedWithPeer(peerID: MCPeerID){
//        OperationQueue.main.addOperation { () -> Void in
//            self.performSegue(withIdentifier: "idSegueChat", sender: self)
//        }
    }
    
    
//    func foundPeers()
//    func lostPeer()
//    func invitationWasReceived(fromPeer: String)
//    
//    func connectedWithPeer(peerID: MCPeerID){
//        
//    }
    
    

}
