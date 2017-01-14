//
//  SettingsController.swift
//  nasty-fish
//
//  Created by manu on 07.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    @IBOutlet weak var nickName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        nickName.text = (UIApplication.shared.delegate as! AppDelegate).dataController!.fetchUserCustomName()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        var isValid = true
        
        if let ident = identifier {
            if ident == "SaveToMain" || ident == "CancelToMain" {
            
                // Check Descriptin
                if (nickName.text?.isEmpty)! {
                    setLeftViewMode(field: nickName, isValid: false)
                    
                    isValid = false
                }
                else {
                    setLeftViewMode(field: nickName, isValid: true)
                }
 
            
            }
        }
        
        return isValid
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // https://stackoverflow.com/questions/1906799/uitextfield-validation-visual-feedback
    func setLeftViewMode(field: UITextField, isValid: Bool ) {
        if isValid == false {
            field.leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            imageView.image =   UIImage(named: "in")
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            field.leftView = imageView;
        } else {
            field.leftViewMode = UITextFieldViewMode.never
            field.leftView = nil;
        }
    }

}
