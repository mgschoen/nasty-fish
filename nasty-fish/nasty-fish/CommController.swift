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
    var advertisingPartners = [MCPeerID]()
    var foundPartnersAdvertisedData = Dictionary<MCPeerID, Dictionary<String, String>>()
    
    //completion handler declaration
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    override init(){
        super.init()
        
        //  DONE FTM: Different name chosen by group; -> identifierForVendor?.uuid String managed by DataController
        //  WAS: 
        //peer = MCPeerID(displayName: UIDevice.current.name)
        
        //get UIDevice.current.identifierForVendor?.uuid from DataController Instance
        peer = MCPeerID(displayName: (appDelegate.dataController?.fetchUserCustomName())!)
        
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
        //foundPartners.append(peerID)
        
        //TODO
        //FURTHER UNDERSTAND THIS
        self.invitationHandler = invitationHandler as ((Bool, MCSession?) -> Void)!
        
        //call the delegate instance to handle the invitation
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error.localizedDescription)")
    }
    //MCNearbyServiceAdvertiser Protocol END
    
    //MCNearbyServiceBrowser Protocol START
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPartners.append(peerID)
        
        //Get additional info from the Data sent during the advertising process
        if(foundPartnersAdvertisedData.isEmpty || foundPartnersAdvertisedData.index(forKey: peerID) == nil){
            
            //if key not already in dictionary add it
            foundPartnersAdvertisedData[peerID] = info
        }
        
        delegate?.foundPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPartners.enumerated() {
            if(aPeer == peerID){
                foundPartners.remove(at: index)
                
                //Not sure if a peer may be contained in the foundPartners Array but not in the Dictionary
                //But lets check it
                if(foundPartnersAdvertisedData.index(forKey: peerID) != nil){
                    foundPartnersAdvertisedData.remove(at: foundPartnersAdvertisedData.index(forKey: peerID)!)
                }
                break
            }
        }
        
        delegate?.lostPeer()
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
