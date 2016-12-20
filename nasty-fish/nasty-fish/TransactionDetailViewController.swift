//
//  TransactionDetailViewController.swift
//  nasty-fish
//
//  Created by Qendresa Iljazi on 19.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit
import CoreData

class TransactionDetailViewController: UIViewController {
    
    @IBOutlet weak var transactionDescription: UILabel!
  
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var peer: UILabel!
    
    //var text:String?


    // MARK: - Variables
    var transaction:Transaction? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
