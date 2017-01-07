//
//  CommunicationHandler.swift
//  nasty-fish
//
//  Created by Michael Gambitz on 07.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class CommunicationHandler : NSObject {
    
    private let NFSharingServiceType = "nf-sharing"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    //private let info = UIDevice.current.
    
    private let vendorID = UIDevice.current.identifierForVendor?.uuidString
    
    //private let manageMyFiles = NSFileMana
    
    // ubiquityIdentityToken
    
//    @NSCopying var ubiTok: (NSCoding & NSCopying & NSObjectProtocol)?{
//        get {
//            
//        }
//    }
    
    let currentToken = FileManager.default.ubiquityIdentityToken
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: NFSharingServiceType)
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: NFSharingServiceType)
        super.init()
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
        print(currentToken as Any) // as Any to avoid warning
        
    }
    deinit{
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func sendNFTransaction(transactionInfo : String){
        NSLog("%@", "sendNFTransaction: \(transactionInfo)")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(transactionInfo.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            }
            catch {
                NSLog("%@", "\(error)")
            }
        }
        
    }

}
extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

extension CommunicationHandler : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        //change:
        invitationHandler(true, self.session)
    }
}

extension CommunicationHandler : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeer \(error)")
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer \(peerID)")
    }
}

extension CommunicationHandler : MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}
