//
//  DetailTransactionViewController.swift
//  nasty-fish
//
//  Created by Qendresa Iljazi on 17.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit

class DetailTransactionViewController: UITableViewController {

    
    var transaction:Transaction? = nil;
    
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var peer: UILabel!
    
    
    @IBOutlet weak var isMoney: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    @IBOutlet weak var `return`: UIButton!
    
    @IBOutlet weak var loandebt: UILabel!
    
   
   @IBOutlet weak var loandebtImage: UIImageView!
  


   //popup Msg for delete Transaction
        
        @IBAction func showAlert() {
            let alertController = UIAlertController(title: "Delete Transaction", message: "Are you sure you what to delete the Transaction?", preferredStyle: .alert)
            
            
           
            
            let deleteAction = UIAlertAction(title: "delete", style: .destructive, handler: nil)
            alertController.addAction(deleteAction)
            
            
            
            
            
            
            let cancelAction
                = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            
            
            //present(alertController, animated: true, completion: nil)
          self.present(alertController, animated: true, completion: nil)
            
            
        }
    
    
    

        override func viewDidLoad() {
        super.viewDidLoad()


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
                    quantity.text = "Money"
                    
                }else{
                    
                    quantity.text = String(quantityInt)
                }
                
                
            }
        }
        if let incomingBool = transaction?.incoming {
            if incomingBool{
                loandebt.text = "loan"
                loandebtImage.image = UIImage(named: "in")
                
           
            }else{
                loandebt.text = "debt"
                loandebtImage.image = UIImage (named: "out")
           
            }
          
            }
        
      
   
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
