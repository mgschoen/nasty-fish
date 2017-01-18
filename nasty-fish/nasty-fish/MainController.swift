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
        }
    }
    
    
    var dataController: DataController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        // If user has no nickname show settings view
        if dataController?.fetchUserCustomName() == nil {
            self.performSegue(withIdentifier: "Settings", sender: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
