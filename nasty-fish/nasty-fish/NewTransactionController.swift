//
//  NewTransactionController.swift
//  nasty-fish
//
//  Created by manu on 17.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit

class NewTransactionController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var direction: UISegmentedControl!
    @IBOutlet weak var belongings: UISegmentedControl!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var transactionDescription: UITextField!
    @IBOutlet weak var peerPicker: UIPickerView!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    
    // MARK: - IBActions
    @IBAction func belongingsChanged(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            TableViewCellMoney.isHidden = false
//            TableViewCellItem.isHidden = true
//            
//        }else{
//            TableViewCellMoney.isHidden = true
//            TableViewCellItem.isHidden = false
//        }
        
        tableView.reloadData()
    }

    @IBAction func quickAmountTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            amount.text = "5,00"
        }
        else if sender.selectedSegmentIndex == 1 {
            amount.text = "10,00"
        }
        else if sender.selectedSegmentIndex == 2 {
            amount.text = "20,00"
        }
    }
    
    @IBAction func quantityEditingEnd(_ sender: UITextField) {
        quantityStepper.value = Double(sender.text!)!
    }
    
    @IBAction func quickQuantityTapped(_ sender: UIStepper) {
        quantity.text = String(Int(sender.value))
    }
    
    
    // MARK: - Variables
    var pickerData = [KnownPeer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.peerPicker.delegate = self
        self.peerPicker.dataSource = self
        
        pickerData = ((UIApplication.shared.delegate as! AppDelegate).dataController?.fetchPeers())!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        var isValid = true
        
        if let ident = identifier {
            if ident == "SaveNewTransaction" {
                // Check Descriptin
                if (transactionDescription.text?.isEmpty)! {
                    setLeftViewMode(field: transactionDescription, isValid: false)
                    
                    isValid = false
                }
                else {
                    setLeftViewMode(field: transactionDescription, isValid: true)
                }
                
                // Check Money
                if belongings.selectedSegmentIndex == 0 {
                    let formatter = NumberFormatter()
                    formatter.generatesDecimalNumbers = true
                    formatter.numberStyle = NumberFormatter.Style.decimal
                    if (formatter.number(from: amount.text!) as? NSDecimalNumber) == nil  {
                        setLeftViewMode(field: amount, isValid: false)
                        
                        isValid = false
                    }
                    else {
                        setLeftViewMode(field: amount, isValid: true)
                    }
                }
                
                // Check Item
                if belongings.selectedSegmentIndex == 1 {
                    if Int(quantity.text!)! <= 0 {
                        setLeftViewMode(field: quantity, isValid: false)
                        
                        isValid = false
                    }
                    else {
                        setLeftViewMode(field: quantity, isValid: true)
                    }
                }
            }
        }
        
        return isValid
    }
    
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
    
    // MARK: - Table view data source
    
    // https://stackoverflow.com/questions/29886642/hide-uitableview-cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 && belongings.selectedSegmentIndex == 1 {
            return 0.0
        }
        
        if indexPath.section == 2 && indexPath.row == 2 && belongings.selectedSegmentIndex == 1 {
            return 0.0
        }
        
        if indexPath.section == 2 && indexPath.row == 3 && belongings.selectedSegmentIndex == 0 {
            return 0.0
        }
        
        if indexPath.section == 2 && indexPath.row == 4 && belongings.selectedSegmentIndex == 0 {
            return 0.0
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            return 165.0
        }
        
        return 44.0
    }
    
    
    // MARK: - UIPickerView
    
    // The number of columns of data
    @available(iOS 2.0, *)
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].customName
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
