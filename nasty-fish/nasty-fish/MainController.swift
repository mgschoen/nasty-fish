//
//  MainController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 14.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit

class MainController: UITabBarController {
    
    // MARK: - @IBAction
    
    @IBAction func cancelToMain(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveToMain(segue:UIStoryboardSegue) {
        if let settings = segue.source as? SettingsController {
            dataController?.set (userCustomName: settings.nickName)
            
            transactionManager.restartCommunicationController()
        }
    }
    
    
    // MARK: - Variable
    
    var dataController: DataController? = nil
    var transactionManager: TransactionManager!
    
    
    // MARK: - Default override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController!
        transactionManager = (UIApplication.shared.delegate as! AppDelegate).transactionManager!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        // Ckeck for user custom name, if user has no custom name show settings view
        if dataController?.fetchUserCustomName() == nil {
            self.performSegue(withIdentifier: "Settings", sender: self)
        }
        else {
            transactionManager.initializeCommunicationController()
        }
    }
}
