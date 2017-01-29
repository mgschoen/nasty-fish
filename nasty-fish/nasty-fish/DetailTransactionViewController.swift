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
    
    
    @IBOutlet weak var loandebtImage: UIImageView!
    @IBOutlet weak var itemDescription: UILabel!
    
    @IBOutlet weak var loandebtLabel: UILabel!
    @IBOutlet weak var peerNameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    
    @IBOutlet weak var returnedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
  
    override func viewWillAppear(_ animated: Bool ){
        super.viewWillAppear(animated)
        
        let returnDate = transaction?.returnDate
        
        if let incomingBool = transaction?.incoming {
            if incomingBool{
                loandebtLabel.text = "Borrowed from"
                
                if returnDate == nil {
                    loandebtImage.image = #imageLiteral(resourceName: "InFishBig")
                }else{
                    loandebtImage.image = #imageLiteral(resourceName: "InFishBigClose")
                }
            }else{
                loandebtLabel.text =  "Lend to"
                if returnDate == nil {
                    loandebtImage.image = #imageLiteral(resourceName: "OutFishBig")
                }else{
                    loandebtImage.image = #imageLiteral(resourceName: "OutFishBigClose")
                }
            }
        }
        
        if let descript = transaction?.itemDescription {
            itemDescription.text = descript
        }
        
        if let peerName = transaction?.peer?.customName {
            peerNameLabel.text = peerName
        }
        
        if let moneyBool = transaction?.isMoney {
            if moneyBool {
                amountLabel.text = "Amount 💰"
            }else{
                amountLabel.text = "Amount ⚖"
            }
        
          
            if let quantityInt = transaction?.quantity {
                if moneyBool {
                    quantityLabel.text = String(format: "%.2f", Double(quantityInt / 100)) + "€"
                }else{
                    quantityLabel.text = String(quantityInt)
                }
            }
        }
        
        if returnDate != nil {
            returnedLabel.text = "Returned on"
            
            // http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
            // formating returnDate to a good readable string
            let formatter = DateFormatter()
            formatter.dateStyle = DateFormatter.Style.long
            formatter.timeStyle = DateFormatter.Style.none
            
            dateLabel.text = formatter.string(from: returnDate as! Date)
            
        }else{
            returnedLabel.text = "Not returned yet"
            dateLabel.text = "..."
        }
    }
      

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
