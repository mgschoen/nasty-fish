//
//  CommController.swift
//  nasty-fish
//
//  Created by Michael Gambitz on 11.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import MultipeerConnectivity

class CommController: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var delegate: CommControllerDelegate?
    
    var foundPartners = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    override init(){
        super.init()
        
        // TODO
        // Different name to be chosen by group 8
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        //peer = appDelegate.dataController.  getVedorID
        
        session = MCSession(peer: peer)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "nastyfish-mpc")
        advertiser.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "nastyfish-mpc")
        browser.delegate = self
    }
    
    //MCNearbyServiceAdvertiser Protocol START
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        //TODO
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //TODO
    }
    //MCNearbyServiceAdvertiser Protocol END
    
    //MCNearbyServiceBrowser Protocol START
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //TODO
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //TODO
    }
    //MCNearbyServiceBrowser Protocol END

    //MCSession Protocol START
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //TODO
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //TODO
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        //NECESSARY ??
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //NECESSARY ??
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //NECESSARY ??
    }
    //MCSession Protocol END
}

protocol CommControllerDelegate {
    func foundPeers()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
}
