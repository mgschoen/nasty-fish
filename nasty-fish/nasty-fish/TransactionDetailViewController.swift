//
//  TransactionDetailViewController.swift
//  nasty-fish
//
//  Created by Qendresa Iljazi on 15.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//


import UIKit
import CoreData

class TransactionDetailViewController: UITableViewController {
    

    @IBOutlet weak var transactionDescription: UILabel!
    
    @IBOutlet weak var peer: UILabel!
    @IBOutlet weak var amount: UILabel!
    
     @IBOutlet weak var titelDescription: UINavigationItem!
  
    /*
     
     @IBOutlet weak var titelDescription: UINavigationItem!
     
     @IBOutlet weak var transactionDescription: UILabel!
     @IBOutlet weak var amount: UILabel!
     @IBOutlet weak var peer: UILabel!
     
     */
    
    //var text:String?
    
    
    // MARK: - Variables
    //bei "Back" muss nochmal geprüft werden
    var transaction:Transaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
//        self.navigationItem.title = transaction?.itemDescription
        
        self.navigationController?.navigationBar.topItem?.title = "itemDescription"
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        super.viewWillAppear(animated)
        
        print("* * * * * * Transaction description: \(transaction?.itemDescription)")
        
        
        transactionDescription.text = transaction?.itemDescription
        
        amount.text = String(describing: (transaction?.quantity)!)
        
        peer.text = String(describing: (transaction?.peer?.customName)!)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

