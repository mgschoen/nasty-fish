//
//  NewTransactionController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 17.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit

class NewTransactionController: UITableViewController, AlertHelperProtocol {
    
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
        
        let transaction = TransactionMessage(type: MessageType.create.rawValue,
                                          status: MessageStatus.request.rawValue,
                                          senderId: ((UIApplication.shared.delegate as! AppDelegate).dataController?.appInstanceId)!,
                                          senderName: ((UIApplication.shared.delegate as! AppDelegate).dataController?.fetchUserCustomName())!,
                                          receiverId: ((UIApplication.shared.delegate as! AppDelegate).transactionManager?.resolvePeerName(peer))!,
                                          receiverName: peer,
                                          transactionId: UUID().uuidString,
                                          transactionDescription: transactionDescription,
                                          isIncomming: isIncomming,
                                          isMoney: isMoney,
                                          quantity: isMoney ? amount : quantity,
                                          category: nil,
                                          dueDate: nil,
                                          imageURL: nil)
        
        let succeed = (UIApplication.shared.delegate as! AppDelegate).transactionManager?.sendData(transaction)
        
        if (succeed)! {
            
            alert = AlertHelper.getWaitAlert(title:"Sending transaction")
            self.present(alert!, animated: true, completion: nil)
            
        } else {
            alert = AlertHelper.getCustomAlert(title: "Sending transaction failed",
                                               message: "Transaction was not send successfully.",
                                               buttonLabel: "Ok")
            self.present(alert!, animated: true, completion: nil)
            (UIApplication.shared.delegate as! AppDelegate).transactionManager?.restartCommunicationController()
        }
    }
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            directionImage.image = #imageLiteral(resourceName: "OutFish")
        }
        else {
            directionImage.image = #imageLiteral(resourceName: "InFish")
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
    
    
    // MARK: - Variable
    
    var pickerData = [String]()
    var alert: UIAlertController?
    
    
    // MARK: - Getter
    
    var savedTransaction: Transaction?
    
    var transactionDescription: String {
        get {
            return descriptionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    var peer: String {
        get {
            return self.pickerData[self.peerPicker.selectedRow(inComponent: 0)]
        }
    }
    
    var isIncomming: Bool {
        get {
            return (self.directionSegmentedControl.selectedSegmentIndex == 0 ? false : true)
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
        
        // Register to receive notification
        // Observe listen for transactionSavedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionReplyNotification),
                                               name: .transactionReplyNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOntransactionPeersChangedNotification),
                                               name: .transactionPeersChangedNotification,
                                               object: nil)
        
        // load P2P clients
        pickerData = ((UIApplication.shared.delegate as! AppDelegate).transactionManager?.fetchPeerNames())!
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
    
    // MARK: - Notification
    
    func actOnTransactionReplyNotification(_ notification: NSNotification) {
        print("[NewTransactionController] L 245 hideAlert() called")
        hideAlert()
        
        if let transaction = (notification.userInfo?["TransactionMessage"] as? TransactionMessage) {
            if transaction.status == MessageStatus.accepted.rawValue {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "savedTransaction", sender: self)
                })
            }
            else {
                //hideAlert()
                alert = AlertHelper.getCustomAlert(title: "Transaction declined",
                                                   message: "\(transaction.senderName) declined to accept the transaction:\n\(transaction.transactionDescription)",
                                                   buttonLabel: "Ok")
                self.present(alert!, animated: true, completion: nil)
            }
        }
    }
    
    func actOntransactionPeersChangedNotification(_ notification: NSNotification) {
        pickerData = ((UIApplication.shared.delegate as! AppDelegate).transactionManager?.fetchPeerNames())!
        peerPicker.reloadAllComponents()
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
        
        // Check Peer
        if pickerData.count == 0 {
            isValid = false
        }
        
        saveButton.isEnabled = isValid
    }
    
    func hideAlert() {
        DispatchQueue.main.async(execute: {
            if self.alert != nil {
                self.dismiss(animated: false, completion: nil)
                self.alert = nil
            }
        })
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // checks amountTextField, so the user only can enter valide values for money
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
