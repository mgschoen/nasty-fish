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
    
    // MARK: - IBActions
//    @IBAction func tappedSave(_ sender: UIBarButtonItem) {
//        let itemDescription = transactionDescription.text
//        let knownPeer = pickerData[peerPicker.selectedRow(inComponent: 0)]
//        let incomming = false
//        let isMoney = false
//        let quantity = 1
//        
//        ((UIApplication.shared.delegate as! AppDelegate).dataController?.storeNewTransaction(
//            itemDescription: itemDescription!,
//            peer: knownPeer,
//            incoming: incomming,
//            isMoney: isMoney,
//            quantity: UInt(quantity),
//            category: nil,
//            dueDate: nil,
//            imageURL: nil,
//            dueWhenTransactionIsDue: nil))
//    }
    
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
    
    
    
    // MARK: - Variables
    var pickerData = [KnownPeer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
        if let ident = identifier {
            if ident == "SaveNewTransaction" {
                if (transactionDescription.text?.isEmpty)! {
                    return false
                }
                
                // Money
                if belongings.selectedSegmentIndex == 0 {
                    let formatter = NumberFormatter()
                    formatter.generatesDecimalNumbers = true
                    formatter.numberStyle = NumberFormatter.Style.decimal
                    if (formatter.number(from: amount.text!) as? NSDecimalNumber) == nil  {
                        return false
                    }
                }
                
                // Item
                if belongings.selectedSegmentIndex == 1 {
                    if Int(quantity.text!)! <= 0 {
                        return false
                    }
                }
                
                //        let knownPeer = pickerData[peerPicker.selectedRow(inComponent: 0)]
                //        let incomming = false
                //        let isMoney = false
                //        let quantity = 1
                
            }
        }
        return true
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
    
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
