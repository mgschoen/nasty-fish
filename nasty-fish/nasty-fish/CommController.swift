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
        //  DONE FTM: Different name chosen by group; -> identifierForVendor?.uuid String managed by DataController
        //  WAS: 
        //peer = MCPeerID(displayName: UIDevice.current.name)
        
//        if !(appDelegate.dataController?.fetchUserCustomName() == nil){
//        //get UIDevice.current.identifierForVendor?.uuid from DataController Instance
        peer = MCPeerID(displayName: (appDelegate.dataController?.fetchUserCustomName())!)
//        } else {
        
//        //170113 Changing the String:
//        //peer = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
//        peer = MCPeerID(displayName: UIDevice.current.name)
////        }
        
        uuid = (appDelegate.dataController?.appInstanceId)!
        
        print(peer)
        print(peer.displayName)
        
        /* Init Session */
        //session's encryptionPreference is now MCEncryptionPreference.required
        //session's encryptionPreference could be MCEncryptionPreference.none
        //Changing to none could be a workaround for the notConnected issue
        //session = MCSession(peer: peer)
        //Using equivalent alternative:
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        
        /* Init Advertiser */
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "nastyfish-mpc")
        advertiser.delegate = self
        
        
        /* Init Browser */
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "nastyfish-mpc")
        browser.delegate = self
        
        //FOR NOW
        //Define this object as Observer for following notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMPCReceivedDataWithNotification),
                                               name: NSNotification.Name("receivedMPCDataNotification"),
                                               object: nil)
        
        //instantiation of the CommControllerDelegate
        //has to be done before the startBrowsingForPeers call
        delegate = ServiceDel()
        
        //start browsing
        //browser.startBrowsingForPeers()
        //isBrowsing = true
        startBrowsingForPartners()
        
        //start advertising right at the beginning
        //advertiser.startAdvertisingPeer()
        //isAdvertising = true
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
    
    
    /**
        Sends data over a MultipeerConnectivity session. Takes a Dictionary containing the composed Transaction Information
     
        - Parameter transaction: the composed data that has to be sent
     
    */
    func sendTransactionToPeer(transaction: [String:Any]) -> (Bool, uuid: String) {
        //May be changed
        return sendUsingUserInfo(uuid: (transaction["uuid"])! as! String, customName: (transaction["customName"])! as! String, data: transaction) as! (Bool, uuid: String)
    }
    
    /**
        Sends data over a MultipeerConnectivity session. Resolves a peer using its unique identifier and takes a Dictionary containing the Information that has to be sent
     
        - Parameter uuid: the users unique identifying string
     
        - Parameter customName: the human easily readable name chosen by the user
     
        - Parameter data: a Dictionary taking a String key and String value with data to be sent
     
    */
    
    func sendUsingUserInfo(uuid : String, customName : String, data : [String : Any]) -> (successful:Bool, receiverUUID : String){
        
        var peerID = resolveMCPeerID(forKey: uuid)
//        var transaction = [String:Any]()
//        transaction["uuid"] = uuid
//        transaction["customName"] = customName
//        transaction.
        var sentSuccessful : Bool = false
        
        if session.connectedPeers.contains(peerID) {
            let dataToSend = NSKeyedArchiver.archivedData(withRootObject: data)
            do {
                try session.send(dataToSend,
                                 toPeers: [peerID],
                                 with: MCSessionSendDataMode.reliable)
                sentSuccessful = true
            } catch {
                NSLog("%@", "\(error.localizedDescription)")
                return (sentSuccessful, uuid)
            }
            
        }
        return (sentSuccessful, uuid)
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
            //foundPartnersDictionary[(info?.first?.key)!] = info!.first?.value
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
            delegate?.connectedWithPeer(peerID: peerID)
            
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
     Function to react on the Notification for the case that data is received through MpC
     */
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
//        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        //let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        let transaction = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! TransactionMessage
        
        // Check if there's an entry with the "message" key.
//        if let nftransaction = dataDictionary["nftransaction"] {
//            // Make sure that the transaction-text is different to "_end_nfcommunication_".
//            if nftransaction != "_end_nfcommunication_"{
//                // Create a new dictionary and set the sender and the received transaction to it.
//                var nfTransactionsDictionary: [String: String] = ["sender": fromPeer.displayName, "nftransaction": nftransaction]
//                
//                // Add this dictionary to the messagesArray array.
//                nfTransactionsArray.append(nfTransactionsDictionary)
//                NSLog("%@", "NFTransaction appended to array")
//                
//                //UPDATE VIEW LIKE
//                // Reload the tableview data and scroll to the bottom using the main thread.
////                OperationQueue.main.addOperation({ () -> Void in
////                    self.updateTableview()
////                })
//            }
//            else{
//                // In this case an "_end_nfcommunication_" transaction-text was received.
//                // One could show an alert view to the user.
//                
//                    session.disconnect()
//                
//            }
//        }
        
        delegate?.receivedData(transaction)
        
        //IF Close 
        //session.disconnect()
        
        // Case Peer new & Transaction New
        // Case Peer known & Transaction New
        // Case Peer new & Transaction Old -> Err
        // Case Peer known & Transaction old -> close
        
        //delegate
        
    }
    
    //TODO
    
    //Update Method in Case the CustomName has been changed
    //Notification nfCustomNameChanged
    //Update name
    //Create new peer : MCPeerID
    //reinit session etc
    
}

protocol CommControllerDelegate {
    
    func foundPeers()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
    func receivedData(_ transaction: TransactionMessage)

}
