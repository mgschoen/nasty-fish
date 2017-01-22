//
//  MoreController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 07.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit

class MoreController: UITableViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var AppInstanceIdLabel: UILabel!
    @IBOutlet weak var UserCustomNameLabel: UILabel!
    
    
    // MARK: - IBAction
    @IBAction func initWithDefaultData(_ sender: UIButton) {
        let dc = (UIApplication.shared.delegate as! AppDelegate).dataController
        let populator = Populator(dc:dc!)
        if (!populator.storageIsPopulated()) {
            populator.populate()
            let alert = UIAlertController(title: "Debug message", message: "Dummy Data created successfully.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Debug message", message: "Dummy Data already exists.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Default override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        let dc = (UIApplication.shared.delegate as! AppDelegate).dataController
        AppInstanceIdLabel.text = "\(dc!.appInstanceId!)"
        if let customName = dc!.fetchUserCustomName() {
            UserCustomNameLabel.text = "\(customName)"
        } else {
            UserCustomNameLabel.text = "[noname]"
        }
    }
}
