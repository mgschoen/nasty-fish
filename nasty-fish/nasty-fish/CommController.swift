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
        
    var foundPartners = [MCPeerID]()
    var invitingPartners = [MCPeerID]()
    var foundPartnersAdvertisedData = Dictionary<MCPeerID, Dictionary<String, String>>()
    var nfTransactionsArray: [Dictionary<String, String>] = []
    
    var foundPartnersDictionary = [String:String]()
    
    var foundPartnersInfoKeys = [String]()
    var foundPartnersInfoValues = [String]()
    
    var foundPartnersIDs = [String]()
    var foundPartnersCustomNames = [String]()
    
    var isAdvertising: Bool
    var isBrowsing: Bool
    
    //completion handler declaration
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    override init(){
        isAdvertising = false
        isBrowsing = false
        
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
        
        super.init()
        
        //init MCPeerID with customName
        peer = MCPeerID(displayName: customName)
        
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
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPartners.append(peerID)
        if (!(info == nil)) {
            //Get additional info from the Data sent during the advertising process
            if(foundPartnersAdvertisedData.isEmpty || foundPartnersAdvertisedData[peerID] == nil){
                //if key not already in dictionary add it
                foundPartnersAdvertisedData[peerID] = info
            }
            foundPartnersIDs.append((info?["nastyFishPartnerIdentifier"])!)
            foundPartnersCustomNames.append((info?["customName"])!)
        }
        //inviteAllPeers()
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
        
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
        switch(state){
        case MCSessionState.connected:
            NSLog("%@", "didChangeStateConnected: \(peerID) connected to \(session)")
            delegate?.connectedWithPeer(peerID: peerID.displayName)
            
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
    
    /**
     Returns all online peers and their customName as a Dicionary
     */
    func fetchParticipatingIDsAndCustomNameFromInfo() -> (Dictionary<String, String>) {
        var idNames = [String:String]()
        //foundPartnersAdvertisedData : Dictionary<MCPeerID, Dictionary<String, String>>()
        for peer in foundPartnersAdvertisedData.keys {
            //THIS MIGHT NEED SOME WORK
            idNames[(foundPartnersAdvertisedData[peer]!.first?.key)!] = foundPartnersAdvertisedData[peer]!.first?.value
        }
        return idNames
    }

    func fetchParticipatingIDs() -> [String] {
        return [String](foundPartnersDictionary.keys)
    }
    
    func getFoundPartnersInfo() -> ([String], [String]) {
        return (foundPartnersIDs, foundPartnersCustomNames)
    }
    
    func getFoundPartners() -> [MCPeerID] {
        return foundPartners
    }
    
    func getInvitingPartners() -> [MCPeerID] {
        return invitingPartners
    }
    /**
        Searches the corresponding MultipeerConnectivity Peer ID (MCPeerID) among all found peers
     
        - Parameter nastyFishPartnerIdentifier: The UUID-String that identifies each partner for transactions
    */
    func resolveMCPeerID(forKey nastyFishPartnerIdentifier: String) -> MCPeerID {
        if !(foundPartnersIDs.contains(nastyFishPartnerIdentifier)){
           NSLog("%@", "Could not resolve Transaction Receiver - Unknown Peer String")
        }
        let index = foundPartnersIDs.index(of: nastyFishPartnerIdentifier)!
        return foundPartners[index]
    }
    
    /* ------------------------------------------------------------------------------------ *
     *   Sending Data                                                                       *
     * ------------------------------------------------------------------------------------ */
    
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
        let peer = resolveMCPeerID(forKey: data.receiverId)
        // unarchive TransactionMessage
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: data)
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
        let transaction = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! TransactionMessage

        delegate?.receivedData(transaction)
    }

}

protocol CommControllerDelegate {
    
    func foundPeers()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: String) // Brauchen wir die noch? Ich hab das mal auf String geändert
    func receivedData(_ transaction: TransactionMessage)

}
