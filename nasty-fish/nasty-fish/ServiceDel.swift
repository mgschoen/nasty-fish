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
        NSLog("%@", "foundPeers -- no peers/sessions info")
        //UPDATE VIEW
    }
    
    func lostPeer() {
        NSLog("%@", "lostPeer -- no peer/session info")
        //UPDATE VIEW
    }
    
    func invitationWasReceived(fromPeer: String) {
        //Alert-Window to be shown at UI ?
        //let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.alert)
        NSLog("%@", "invitationWasReceived from: \(fromPeer) at comm delegate")
       
        // IN CASE USER MAY ACCEPT AND DECLINE
        // DEFINE ACTIONS HERE
        
        //NO USER QUESTIONING
        //Completion
        self.appDelegate.commController?.invitationHandler(true, self.appDelegate.commController.session)
        
        //Show Alert-Window
    }
    
    func connectedWithPeer(peerID: MCPeerID){
        NSLog("%@", "connectedWithPeer: \(peerID)")
        //Visualize

    }
}
