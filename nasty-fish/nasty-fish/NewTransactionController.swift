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
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var direction: UISegmentedControl!
    @IBOutlet weak var transactionDescription: UITextField!
    @IBOutlet weak var belongings: UISegmentedControl!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var peerPicker: UIPickerView!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    
    // MARK: - IBActions
    @IBAction func belongingsChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
        checkUserInput()
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
        
        checkUserInput()
    }
    
    @IBAction func editingChangedTextField(_ sender: UITextField) {
        checkUserInput()
    }
    
    // setting stepper value after user changed quntity via keyboard
    @IBAction func quantityEditingEnd(_ sender: UITextField) {
        quantityStepper.value = Double(sender.text!)!
    }
    
    @IBAction func quickQuantityTapped(_ sender: UIStepper) {
        quantity.text = String(Int(sender.value))
        
        checkUserInput()
    }
    
    
    // MARK: - Variables
    var pickerData = [KnownPeer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.peerPicker.delegate = self
        self.peerPicker.dataSource = self
        
        // Handle the text field’s user input through delegate callbacks.
        self.transactionDescription.delegate = self
        self.amount.delegate = self
        self.quantity.delegate = self
        
        pickerData = ((UIApplication.shared.delegate as! AppDelegate).dataController?.fetchPeers())!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    
    // Mark: - Helper
    func checkUserInput() {
        var isValid = true
        
        // Check Descriptin
        if (transactionDescription.text?.isEmpty)! {
            isValid = false
        }
        
        // Check Money
        if belongings.selectedSegmentIndex == 0 {
            let formatter = NumberFormatter()
            formatter.generatesDecimalNumbers = true
            formatter.numberStyle = NumberFormatter.Style.currency
            
            print("amount.text as string: \(formatter.string(from: amount.text!))")
            
            if (formatter.number(from: amount.text!) as? NSDecimalNumber) == nil  {
                isValid = false
            }
        }
        
        // Check Item
        if belongings.selectedSegmentIndex == 1 {
            if (quantity.text?.isEmpty)! {
                isValid = false
            }
            else {
                if Int(quantity.text!)! <= 0 {
                    isValid = false
                }
            }
        }
        
        saveButton.isEnabled = isValid
    }

}


extension NewTransactionController: UITextFieldDelegate {
    
    // Mark: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Hide the keyboard.
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField,
                            shouldChangeCharactersIn range: NSRange,
                            replacementString string: String) -> Bool {
        
        //
        if textField == amount {
            if  let amount = textField.text {
                let amountArr = amount.components(separatedBy: ",")
                
                if amountArr.count == 2 && amountArr[1].characters.count > 1 && string != "" {
                    return false
                }
            }
        }
        
        return true
    }
}
