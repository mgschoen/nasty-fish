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
    var nfTransactionsArray: [Dictionary<String, String>] = []
    
    //completion handler declaration
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    override init(){
        super.init()
        
        //  DONE FTM: Different name chosen by group; -> identifierForVendor?.uuid String managed by DataController
        //  WAS: 
        //peer = MCPeerID(displayName: UIDevice.current.name)
        
//        if !(appDelegate.dataController?.fetchUserCustomName() == nil){
//        //get UIDevice.current.identifierForVendor?.uuid from DataController Instance
//        peer = MCPeerID(displayName: (appDelegate.dataController?.fetchUserCustomName())!)
//        } else {
        peer = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
//        }
        session = MCSession(peer: peer)
        session.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "nastyfish-mpc")
        advertiser.delegate = self
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "nastyfish-mpc")
        browser.delegate = self
        
        //FOR NOW
        //Define this object as Observer for following notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleMPCReceivedDataWithNotification), name: NSNotification.Name("receivedMPCDataNotification"), object: nil)
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Advertiser                                                                         *
     * ------------------------------------------------------------------------------------ */
    //MCNearbyServiceAdvertiser Protocol START
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        //TODO
        //foundPartners.append(peerID)
        
        //TODO
        //FURTHER UNDERSTAND THIS
        self.invitationHandler = invitationHandler as ((Bool, MCSession?) -> Void)!
        
        //call the delegate instance to handle the invitation
        delegate?.invitationWasReceived(fromPeer: peerID.displayName)
        print("advertiser didReceiveInvitation from \(peerID)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error.localizedDescription)")
    }
    //MCNearbyServiceAdvertiser Protocol END
    
    /* ------------------------------------------------------------------------------------ *
     *   Browser                                                                            *
     * ------------------------------------------------------------------------------------ */
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

    /* ------------------------------------------------------------------------------------ *
     *   Session                                                                            *
     * ------------------------------------------------------------------------------------ */

    //MCSession Protocol START
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case MCSessionState.connected:
            NSLog("%@", "didChangeStateConnected: \(peerID) connected to \(session)")
            delegate?.connectedWithPeer(peerID: peerID)
            
        case MCSessionState.connecting:
            NSLog("%@", "didChangeStateConnecting: \(peerID) is connecting to \(session)")
            
        default:
            NSLog("%@", "didChangeStateNotConnected: \(peerID) did not connect to \(session)")
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
        
        //Notification Observer pattern
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"), object: dictionary)
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
    
    /* ------------------------------------------------------------------------------------ *
     *   Sending Data                                                                       *
     * ------------------------------------------------------------------------------------ */
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        
        var wasSentSuccessful : Bool = true
        do {
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: MCSessionSendDataMode.reliable)
            //session.send returns true if the message was successfully enqueued for delivery, or false if an error occurred
        } catch {
            NSLog("%@", "\(error.localizedDescription)")
            wasSentSuccessful = false
            return wasSentSuccessful
        }
        return wasSentSuccessful
    }
    
    /* 
     Method to send Strings to all connected peers
     */
    func sendNFTransaction(transactionInfo : String) -> Bool {
        NSLog("%@", "sendNFTransaction: \(transactionInfo)")
        var transactionSent : Bool = true
        if !(session.connectedPeers.isEmpty) {
            do {
                try self.session.send(transactionInfo.data(using: String.Encoding.utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
            }
            catch {
                NSLog("%@", "\(error)")
                transactionSent = false
            }
        }
        return transactionSent
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Receiving Data                                                                     *
     * ------------------------------------------------------------------------------------ */
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let nftransaction = dataDictionary["nftransaction"] {
            // Make sure that the transaction-text is different to "_end_nfcommunication_".
            if nftransaction != "_end_nfcommunication_"{
                // Create a new dictionary and set the sender and the received transaction to it.
                var nfTransactionsDictionary: [String: String] = ["sender": fromPeer.displayName, "nftransaction": nftransaction]
                
                // Add this dictionary to the messagesArray array.
                nfTransactionsArray.append(nfTransactionsDictionary)
                NSLog("%@", "NFTransaction appended to array")
                
                //UPDATE VIEW LIKE
                // Reload the tableview data and scroll to the bottom using the main thread.
//                OperationQueue.main.addOperation({ () -> Void in
//                    self.updateTableview()
//                })
            }
            else{
                // In this case an "_end_nfcommunication_" transaction-text was received.
                // Show an alert view to the user.
                
                    session.disconnect()
                
            }
        }
    }
    
    
    
}

protocol CommControllerDelegate {
    
    func foundPeers()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)

}
