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
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var peer: UILabel!
    
    @IBOutlet weak var isMoney: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var loandebt: UILabel!
   
    @IBOutlet weak var loandebtImage: UIImageView!
  
    @IBOutlet weak var returnStartDate: UIButton!
    
    @IBOutlet weak var closedLabel: UILabel!
    
    @IBAction func returnButtonClicked(_ sender: Any) {
        
        if (transaction != nil && transactionManager != nil) {
            
            NSLog("# # # Transaction found: \((transaction?.itemDescription!)!) # # #")
            
            NSLog("Peer of this transaction: \((transaction?.peer?.icloudID!)!) - \((transaction?.peer?.customName)!)")
            
            let commController = transactionManager?.commController
            let dataController = transactionManager?.dataController
            
            var peerIsActive:Bool = false
            
            for (key, _) in (commController?.partnerInfoByVendorID)! {
                if (key == transaction?.peer?.icloudID!) {
                    peerIsActive = true
                    break
                }
            }
            
            if (peerIsActive) {
                
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
                
                if (succeed)! {
                    
                    let alert = UIAlertController(title: "Transaction closed",
                                                  message: "You have successfully closed this transaction.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Delicious", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let alert = UIAlertController(title: "Nasty!",
                                                  message: "Something went wrong while closing this transaction. Check your logs for more info.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ugh", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            } else {
                
                let alert = UIAlertController(title: "Peer not found",
                                              message: "Cannot close transaction. Your friend needs to be nearby in order to let him know you closed this transaction.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        transactionManager = (UIApplication.shared.delegate as! AppDelegate).transactionManager
        
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
                isMoney.text = "item"
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
                loandebt.text = "loan"
                loandebtImage.image = #imageLiteral(resourceName: "InFish")
                
           
            }else{
                loandebt.text = "debt"
                loandebtImage.image = #imageLiteral(resourceName: "OutFish")
        
   
            }
        }
        
        closedLabel.text = (transaction?.returnDate == nil) ? "open" : "closed"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
