//
//  NewTransactionController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 17.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit

class NewTransactionController: UITableViewController {
    
    // MARK: - @IBOutlet
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var directionImage: UIImageView!
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var belongingsSegmentControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var peerPicker: UIPickerView!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    
    // MARK: - IBActions
    
    @IBAction func saveButtonTaped(_ sender: UIBarButtonItem) {
        
        let transaction = TransactionData(userId: ((UIApplication.shared.delegate as! AppDelegate).dataController?.appInstanceId)!,
                                          userName: ((UIApplication.shared.delegate as! AppDelegate).dataController?.fetchUserCustomName())!,
                                          peerId: peer,
                                          peerName: "[Undefined]",
                                          transactionId: UUID(),
                                          transactionDescription: transactionDescription,
                                          isIncomming: isIncomming,
                                          isMoney: isMoney,
                                          quantity: quantity,
                                          category: nil,
                                          dueDate: nil,
                                          imageURL: nil,
                                          dueWhenTransactionIsDue: nil)
        
        
        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.processTransaction(newTransaction: transaction)
                
        
        
//        let alert = UIAlertController(title: "Order Placed!", message: "Thank you for your order.\nWe'll ship it to you soon!", preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//            (_)in
//            self.performSegue(withIdentifier: "savedTransaction", sender: self)
//        })
//        
//        alert.addAction(OKAction)
//        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            directionImage.image = #imageLiteral(resourceName: "InFish")
        }
        else {
            directionImage.image = #imageLiteral(resourceName: "OutFish")
        }
    
    
    }
    
    @IBAction func belongingsChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
        
        checkUserInput()
    }

    @IBAction func quickAmountTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            amountTextField.text = "5,00"
        }
        else if sender.selectedSegmentIndex == 1 {
            amountTextField.text = "10,00"
        }
        else if sender.selectedSegmentIndex == 2 {
            amountTextField.text = "20,00"
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
        quantityTextField.text = String(Int(sender.value))
        
        checkUserInput()
    }
    
    
    // MARK: - Variables
    
    var pickerData = [String]()
    
    
    // MARK: - Getter
    
    var savedTransaction: Transaction?
    
    var transactionDescription: String {
        get {
            return descriptionTextField.text!
        }
    }
    
    var peer: String {
        get {
            return self.pickerData[self.peerPicker.selectedRow(inComponent: 0)]
        }
    }
    
    var isIncomming: Bool {
        get {
            return (self.directionSegmentedControl.selectedSegmentIndex == 0 ? true : false)
        }
    }
    
    var isMoney: Bool {
        get {
            return (self.belongingsSegmentControl.selectedSegmentIndex == 0 ? true : false)
        }
    }
    
    var amount: UInt {
        get {
            let formatter = NumberFormatter()
            formatter.generatesDecimalNumbers = true
            formatter.numberStyle = NumberFormatter.Style.decimal
        
            if let amount = (formatter.number(from: amountTextField.text!) as? Decimal) {
                let size = (amount * Decimal(100))
                let result = NSDecimalNumber(decimal: size)
                
                print("NewTransactionController.amount: \(result)")
                return UInt(result)
            }
            else {
                print("NewTransactionController.amount: Error")
                return UInt(1)
            }
        }
    }
    
    var quantity: UInt {
        get {
            if let quantity = UInt(quantityTextField.text!) {
                print("NewTransactionController.quantity: \(quantity)")
                return quantity
            }
            else {
                print("NewTransactionController.quantity: Error")
                return UInt(1)
            }
        }
    }
    
    
    // MARK: - Default override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.peerPicker.delegate = self
        self.peerPicker.dataSource = self
        
        // Handle the text field’s user input through delegate callbacks.
        self.descriptionTextField.delegate = self
        self.amountTextField.delegate = self
        self.quantityTextField.delegate = self
        
        // hide keyboard when user taps outside of textfield
        // https://stackoverflow.com/questions/27878732/swift-how-to-dismiss-number-keyboard-after-tapping-outside-of-the-textfield
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(NewTransactionController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        // Register to receive notification in your class
        // Observe listen for transactionSavedNotificationKey
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NewTransactionController.actOnTransactionSavedNotification),
                                               name: .transactionSavedNotification,
                                               object: nil)
        // load P2P clients
        pickerData = ((UIApplication.shared.delegate as! AppDelegate).transactionManager?.fetchClients())!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

        
    // MARK: - Table view data source
    
    // hide and show rows of static table
    // https://stackoverflow.com/questions/29886642/hide-uitableview-cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 && belongingsSegmentControl.selectedSegmentIndex == 1 {
            return 0.0
        }
        
        if indexPath.section == 1 && indexPath.row == 2 && belongingsSegmentControl.selectedSegmentIndex == 1 {
            return 0.0
        }
        
        if indexPath.section == 1 && indexPath.row == 3 && belongingsSegmentControl.selectedSegmentIndex == 0 {
            return 0.0
        }
        
        if indexPath.section == 1 && indexPath.row == 4 && belongingsSegmentControl.selectedSegmentIndex == 0 {
            return 0.0
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            return 165.0
        }
        
        return 44.0
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    */
    
    
    // MARK: - Notification
    
    func actOnTransactionSavedNotification(_ notification: NSNotification) {
        if let transaction = notification.userInfo?["transaction"] as? Transaction {
            savedTransaction = transaction;
            
            self.performSegue(withIdentifier: "savedTransaction", sender: self)
        }
        else {
            savedTransaction = nil
            
            let alert = UIAlertController(title: "Transmission failed",
                                          message: "Transaction was not created successfully.",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: UIAlertActionStyle.default,
                                          handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Helper
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func checkUserInput() {
        var isValid = true
        
        // Check Descriptin
        if (descriptionTextField.text?.isEmpty)! {
            isValid = false
        }
        
        // Check Money
        if belongingsSegmentControl.selectedSegmentIndex == 0 {
            let formatter = NumberFormatter()
            formatter.generatesDecimalNumbers = true
            formatter.numberStyle = NumberFormatter.Style.decimal
            
            print("checkUserInput amountTextField.text: \(amountTextField.text)")
            if (formatter.number(from: amountTextField.text!) as? NSDecimalNumber) == nil  {
                isValid = false
            }
        }
        
        // Check Item
        if belongingsSegmentControl.selectedSegmentIndex == 1 {
            if (quantityTextField.text?.isEmpty)! {
                isValid = false
            }
            else {
                if Int(quantityTextField.text!)! <= 0 {
                    isValid = false
                }
            }
        }
        
        saveButton.isEnabled = isValid
    }

}

extension NewTransactionController: UIPickerViewDelegate, UIPickerViewDataSource {
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
        return pickerData[row]
    }
}

extension NewTransactionController: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
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
        if textField == amountTextField {
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

//extension NewTransactionController: TransactionManagerDelegate {
//    func transactionSaved(transaction: Transaction?) {
//        if (transaction != nil) {
//            self.performSegue(withIdentifier: "savedTransaction", sender: self)
//        }
//    }
//}
