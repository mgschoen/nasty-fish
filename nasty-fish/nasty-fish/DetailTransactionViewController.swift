//
//  DetailTransactionViewController.swift
//  nasty-fish
//
//  Created by Qendresa Iljazi on 17.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit

class DetailTransactionViewController: UITableViewController {

    var transactionManager:TransactionManager?
    var transaction:Transaction? = nil;
    var alert: UIAlertController?
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var peer: UILabel!
    
    @IBOutlet weak var isMoney: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var loandebt: UILabel!
   
    @IBOutlet weak var loandebtImage: UIImageView!
  
    @IBOutlet weak var returnStartDate: UIButton!
    @IBOutlet weak var datum: UILabel!
    
    @IBOutlet weak var closedLabel: UILabel!
    
    // Action handler that tries to communicate a transaction close
    // request to the transaction peer.
    @IBAction func returnButtonClicked(_ sender: Any) {
        
        if (transaction != nil && transactionManager != nil) {
            
            // Is the transaction already closed?
            if (transaction?.returnDate == nil) {
                
                let commController = transactionManager?.commController
                let dataController = transactionManager?.dataController
                
                // Are we currently connected to the peer of this transaction?
                var peerIsActive:Bool = false
                for (key, _) in (commController?.partnerInfoByVendorID)! {
                    if (key == transaction?.peer?.icloudID!) {
                        peerIsActive = true
                        break
                    }
                }
                
                if (peerIsActive) {
                    
                    alert = showWaitAlert()
                    
                    // We are connected to the peer - send him a close request
                    let closeMessage = TransactionMessage(type: MessageType.close.rawValue,
                                                          status: MessageStatus.request.rawValue,
                                                          senderId: (dataController?.appInstanceId)!,
                                                          senderName: (dataController?.fetchUserCustomName())!,
                                                          receiverId: (transaction?.peer?.icloudID)!,
                                                          receiverName: (transaction?.peer?.customName)!,
                                                          transactionId: (transaction?.uuid)!,
                                                          transactionDescription: (transaction?.itemDescription)!,
                                                          isIncomming: (transaction?.incoming)!,
                                                          isMoney: (transaction?.isMoney)!,
                                                          quantity: (UInt)((transaction?.quantity)!),
                                                          category: nil,
                                                          dueDate: nil,
                                                          imageURL: nil)
                    
                    let succeed = transactionManager?.sendData(closeMessage)
                    
                    // If sending fails, notify the user
                    if (!succeed!) {
                        
                        hideAlert()
                        
                        let alert = UIAlertController(title: "Nasty!",
                                                      message: "Something went wrong while closing this transaction. Check your logs for more info.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ugh", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                    // If sending was successfull, we are now listening for peer's reply
                    // with the actOnTransactionReplyNotification handler
                    
                } else {
                    
                    // We are not connected to the peer - do nothing and notify the user about it
                    let alert = UIAlertController(title: "Peer not found",
                                                  message: "Cannot close transaction. Your friend needs to be nearby in order to let him know you closed this transaction.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            } else {
                
                // Transaction is already closed - do nothing and notify the user about it
                let alert = UIAlertController(title: "Relax...",
                                              message: "This item has already been returned. ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        transactionManager = (UIApplication.shared.delegate as! AppDelegate).transactionManager
        
        // Listen for reply notifications in order to detect answers to close requests
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionReplyNotification),
                                               name: .transactionReplyNotification,
                                               object: nil)

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  
    override func viewWillAppear(_ animated: Bool ){
        
        super.viewWillAppear(animated)
      
        
        if let descript = transaction?.itemDescription {
            
            itemDescription.text = descript
        }
        if let peerName = transaction?.peer?.customName {
            peer.text = peerName
        }
        if let moneyBool = transaction?.isMoney {
            if moneyBool {
                isMoney.text = "Money"
                
            }else{
                isMoney.text = "Item"
            }
        
          
        if let quantityInt = transaction?.quantity {
               
            if moneyBool {
                quantity.text = String(format: "%.2f", Double(quantityInt / 100)) + "€"
                
                 }else{
                    
                quantity.text = String(quantityInt)
                }
                
            }
            
        }
        
        if let incomingBool = transaction?.incoming {
            if incomingBool{
                loandebt.text = "Lend"
                loandebtImage.image = #imageLiteral(resourceName: "InFish")
                
           
            }else{
                loandebt.text = "Borrow"
                loandebtImage.image = #imageLiteral(resourceName: "OutFish")
        
   
            }
            
            }
        if let rDate = transaction?.returnDate{
                datum.text = String( describing: rDate)
            }else{
                datum.text = "none"
        }
        
        closedLabel.text = (transaction?.returnDate == nil) ? "open" : "closed"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Callback fired when reply from peer is received
    func actOnTransactionReplyNotification (_ notification: NSNotification) {
        NSLog("\(notification)")
        
        let answerMessage = notification.userInfo?["TransactionMessage"] as! TransactionMessage
        
        // Are we dealing with an answer to our close request?
        if (answerMessage.type == "close") {
            
            hideAlert()
            
            // Has peer user accepted the close request?
            if (answerMessage.status == "accepted") {
                
                // Update visual representation
                closedLabel.text = (transaction?.returnDate == nil) ? "open" : "closed"
                
                // Notify user about success
                let alert = UIAlertController(title: "Transaction closed",
                                              message: "You have successfully closed this transaction.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Delicious", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                // Do not change anything and notify user about the rejection
                let alert = UIAlertController(title: "Nasty!",
                                              message: "Your friend has rejected your close request.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ugh", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
    }
    
    func hideAlert() {
        if alert != nil {
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    // http://stackoverflow.com/a/40570379/3309527
    func showWaitAlert() -> UIAlertController {
        
        hideAlert()
        
        let sendAlert = UIAlertController(title: "Closing Transaction", message: " ", preferredStyle: .alert)
        
        sendAlert.addAction(UIAlertAction(title: "Cancel",
                                          style: UIAlertActionStyle.cancel,
                                          handler: nil))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        sendAlert.view.addSubview(activityIndicator)
        
        let xConstraint = NSLayoutConstraint(item: activityIndicator,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: sendAlert.view,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: sendAlert.view,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0)
        
        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        self.present(sendAlert, animated: true, completion: nil)
        
        return sendAlert
        
    }

}
