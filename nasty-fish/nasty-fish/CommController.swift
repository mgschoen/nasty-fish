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
    var uuid: String!
    
    var delegate: CommControllerDelegate?
    
    var isAdvertising: Bool
    var isBrowsing: Bool
    
    var foundPartners = [MCPeerID]()
    var invitingPartners = [MCPeerID]()
    //["vendorIDXYZ0x00":(customName, MCPeerID)]
    var partnerInfoByVendorID : [String:(String,MCPeerID)] //{
//        get {
//            return self.partnerInfoByVendorID
//        }
//        set (pInfo) {
//            self.partnerInfoByVendorID = pInfo
//        }
//    }
    
    
    //completion handler declaration
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    override init(){
        isAdvertising = false
        isBrowsing = false
        
        partnerInfoByVendorID = [String:(String,MCPeerID)]()
        
        super.init()
        //MAYBE: Care about the case that the dataContorller == nil
        peer = MCPeerID(displayName: (appDelegate.dataController?.fetchUserCustomName())!)
        uuid = (appDelegate.dataController?.appInstanceId)!
        
        print(peer)
        print(peer.displayName)
        
        /* Init Session */
        session = MCSession(peer: peer,
                            securityIdentity: nil,
                            encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        
        /* Init Advertiser */
        advertiser = MCNearbyServiceAdvertiser(peer: peer,
                                               discoveryInfo: nil,
                                               serviceType: "nastyfish-mpc")
        advertiser.delegate = self
        
        
        /* Init Browser */
        browser = MCNearbyServiceBrowser(peer: peer,
                                         serviceType: "nastyfish-mpc")
        browser.delegate = self
        
        //FOR NOW
        //Define this object as Observer for following notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMPCReceivedDataWithNotification),
                                               name: NSNotification.Name("receivedMPCDataNotification"),
                                               object: nil)
        
        startBrowsingForPartners()
        startAdvertisingForPartners()
    }
    
    init(_ customName: String, _ uuid: String) {
        
        isAdvertising = false
        isBrowsing = false
        
        partnerInfoByVendorID = [String:(String,MCPeerID)]()
        super.init()
        
        //init MCPeerID with customName
        //peer = MCPeerID(displayName: customName)
        peer = MCPeerID(displayName: uuid)
        
        /* Init Session */
        initSession()
        
        /* Init Advertiser */
        let discoveryInfo = ["nastyFishPartnerIdentifier":uuid,
                             "customName":customName]
        initAdvertiser(withDiscoveryInfo: discoveryInfo)
        
        /* Init Browser */
        initBrowser()
        
        //Define this object as Observer for following notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMPCReceivedDataWithNotification),
                                               name: NSNotification.Name("receivedMPCDataNotification"),
                                               object: nil)

        
    }
    deinit {
        session.disconnect()
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Initialize - Session, Browser, Advertiser                                          *
     * ------------------------------------------------------------------------------------ */
    
    func initSession(){
        session = MCSession(peer: self.peer,
                            securityIdentity: nil,
                            encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
    }
    
    func initSession(withSecurityIdentity securityIdent: [Any]){
        session = MCSession(peer: self.peer,
                            securityIdentity: securityIdent,
                            encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
    }
    
    func initSession(forPeer peer: MCPeerID, withSecurityIdentity securityIdent: [Any]?){
        if !(securityIdent == nil){
            self.peer = peer
            initSession(withSecurityIdentity: securityIdent!)
        } else {
            //for the case that the customName will be changed
            self.peer = peer
            initSession()
        }
    }
    
    func initAdvertiser(){
        advertiser = MCNearbyServiceAdvertiser(peer: self.peer,
                                               discoveryInfo: nil,
                                               serviceType: "nastyfish-mpc")
        advertiser.delegate = self
    }
    
    func initAdvertiser(withDiscoveryInfo discInfo: [String:String]){
        advertiser = MCNearbyServiceAdvertiser(peer: self.peer,
                                               discoveryInfo: discInfo,
                                               serviceType: "nastyfish-mpc")
        advertiser.delegate = self
    }
    
    func initBrowser(){
        browser = MCNearbyServiceBrowser(peer: self.peer,
                                         serviceType: "nastyfish-mpc")
        browser.delegate = self
    }
    
    
    /* ------------------------------------------------------------------------------------ *
     *   Start & Stop - Browser, Advertiser                                                 *
     * ------------------------------------------------------------------------------------ */
    
    /**
        Starts advertising for nearby peers via MultipeerConnectivity Framework
     */
    func startAdvertisingForPartners(){
        if self.isAdvertising == true {
            NSLog("%@", "did not start to advertise, already are advertising")
        } else {
            advertiser.startAdvertisingPeer()
            self.isAdvertising = true
        }
    }
    /**
        Stops browsing for nearby peers via MultipeerConnectivity Framework
     */
    func stopAdvertisingForPartners(){
        if self.isAdvertising == false {
            NSLog("%@", "could not stop to advertise, are not advertising")
        } else {
            advertiser.stopAdvertisingPeer()
            self.isAdvertising = false
        }
    }
    /**
        Starts browsing for nearby peers via MultipeerConnectivity Framework
     */
    func startBrowsingForPartners(){
        if self.isBrowsing == true {
            NSLog("%@", "did not start to browse for peers, already are browsing")
        } else {
            browser.startBrowsingForPeers()
            self.isBrowsing = true
        }
    }
    /**
        Stops browsing for nearby peers via MultipeerConnectivity Framework
    */
    func stopBrowsingForPartners(){
        if self.isBrowsing == false {
            NSLog("%@", "can not stop to browse for peers, are not browsing")
        } else {
            browser.stopBrowsingForPeers()
            self.isBrowsing = false
        }

    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Advertiser                                                                         *
     * ------------------------------------------------------------------------------------ */
    //MCNearbyServiceAdvertiser Protocol START
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        
        invitingPartners.append(peerID)
        
        self.invitationHandler = invitationHandler as ((Bool, MCSession?) -> Void)!
        
        //call the delegate instance to handle the invitation
        //delegate?.invitationWasReceived(fromPeer: peerID.displayName)
        invitationHandler(true, self.session)
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
    
    /**
        Log if the browser did not start browsing
    */
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }
    
    /**
        Reacts on having found a user
     */
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        if !(info==nil){
            //let discoveryInfo = ["nastyFishPartnerIdentifier":uuid,"customName":customName]
            let vendorID = info?["nastyFishPartnerIdentifier"]
            let cName = info?["customName"]
            let pts : [String:(String,MCPeerID)] = [vendorID! : (cName!, peerID)]
            NSLog("%@", "Communication: found a peer with info: \(pts)")
            partnerInfoByVendorID[vendorID!] = (cName!, peerID)
        }
        
        foundPartners.append(peerID)
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
        
        delegate?.foundPeers()
    }
    
    /**
        In case of a peer is lost, this function will be called to drop the peer's info
     
        - Parameter browser: the delegate that handles the lostPeer event
     
        - Parameter peerID: the MCPeerID that was lost
    */
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPartners.enumerated() {
            if(aPeer == peerID){
                foundPartners.remove(at: index)
                break
            }
        }
        
        for (key, tupel) in partnerInfoByVendorID {
            if (tupel.1 == peerID) {
                partnerInfoByVendorID.removeValue(forKey: key)
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
        switch(state){
        case MCSessionState.connected:
            NSLog("%@", "didChangeStateConnected: \(peerID) connected to \(session)")
            //delegate?.connectedWithPeer(peerID: peerID.displayName)
            
        case MCSessionState.connecting:
            NSLog("%@", "didChangeStateConnecting: \(peerID) is connecting to \(session)")
            
        default:
            NSLog("%@", "didChangeStateNotConnected: \(peerID) did not connect to \(session)")
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data as AnyObject, "fromPeer": peerID]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedMPCDataNotification"),
                                        object: dictionary)
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    //MCSession Protocol END
    
    
    func getFoundPartners() -> [MCPeerID] {
        return foundPartners
    }
    
    func getInvitingPartners() -> [MCPeerID] {
        return invitingPartners
    }
    
    /**
        Returns a list of all peers' customNames
     */
    func peerCustomNames() -> [String] {
        var peerCustomNames = [String]()
        for tupel in partnerInfoByVendorID.values {
            peerCustomNames.append(tupel.0)
        }
        return peerCustomNames
    }
    
    /**
        Returns the uuid for a specified name
     
        - Parameter name: the customName that should be mapped to a uuid
    */
    func resolvePartnerInfo(forName name: String) -> String {
        var nfIdentifier = ""
        for (key, tupel) in partnerInfoByVendorID {
            if tupel.0 == name {
                nfIdentifier = key
            }
        }
        return nfIdentifier
    }
    
    /**
        Returns the customName for a specified uuid
     
        - Parameter uuid: the identifer for a participating peer that should be mapped to a name
     */
    func resolvePartnerInfo(forUuid uuid: String) -> String {
        return (partnerInfoByVendorID[uuid]?.0)!
    }
    
    /**
        Returns the MCPeerID for a specified identifier for a partner
     
        - Parameter key: String that indetifies the user (in our case: identifierForVendorID.uuidString)
     */
    func resolveMCPeerIDForVendorID(_ key: String) -> MCPeerID {
        return (partnerInfoByVendorID[key]?.1)!
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Sending Data                                                                       *
     * ------------------------------------------------------------------------------------ */
    
    /**
        Sends a Dictionary by using the session.send() function. The dictionary will be archived first and the sent
     
        - Parameter dictionary: Dictionary<String, String> containing the data 
     
        - Parameter targetPeer: MCPeerID that defines the partner that should receive the data
     */
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let peersArray = NSArray(object: targetPeer)
        
        var wasSentSuccessful : Bool = true
        do {
            try session.send(dataToSend, toPeers: peersArray as! [MCPeerID], with: MCSessionSendDataMode.reliable)
        } catch {
            NSLog("%@", "\(error.localizedDescription)")
            wasSentSuccessful = false
            return wasSentSuccessful
        }
        return wasSentSuccessful
    }
    
    /**
     Function to send a TransactioneMessage defined in TransactionManagerHelper.
     The Receiver info is contained within the TransactionMessage
     
     - Parameter data: TransactionMessage Struct containing all Information to be sent
     
     */
    func sendToPartner(_ data: TransactionMessage) -> Bool {
//        var senderId, senderName, receiverId, receiverName: String
//        var transactionId: UUID, transactionDescription: String, isIncomming: Bool, imageURL: String?
//        var dueWhenTransactionIsDue: Transaction?
        //Lookup the receiving MCPeerID
        
        //let peer = resolveMCPeerID(forKey: data.receiverId)
        let peer = resolveMCPeerIDForVendorID(data.receiverId)
        
        var dataToSend : Data
        do {
            dataToSend = try TransactionMessage.encode(transactionMessage: data)
        } catch {
            
            NSLog("%@", "*** ERR *** sendToPartner: \(NSException.debugDescription())")
            
        }
        
        // variable to check if sent was successful
        var sentSuccessful : Bool = false
        
        do {
            try session.send(dataToSend, toPeers: [peer], with: MCSessionSendDataMode.reliable)
            sentSuccessful = true
        } catch {
            NSLog("%@", "\(error.localizedDescription)")
            return sentSuccessful
        }
        return sentSuccessful
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Receiving Data                                                                     *
     * ------------------------------------------------------------------------------------ */
    
    /** 
     Reacts on the Notification for the case that data is received through MpC
     */
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let transaction = TransactionMessage.decode(data: data! as Data)

        delegate?.receivedData(transaction!)
    }

}

protocol CommControllerDelegate {
    
    func foundPeers()
    func lostPeer()
    //func invitationWasReceived(fromPeer: String)
    //func connectedWithPeer(peerID: String) // Brauchen wir die noch? Ich hab das mal auf String geändert
    func receivedData(_ transaction: TransactionMessage)

}
