//
//  TransactionsViewController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 04.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit
import CoreData

class TransactionsViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    @IBOutlet weak var preFilter: UISegmentedControl!
    
    // MARK: - @IBAction
    @IBAction func cancelToTransactions(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveNewTransaction(segue:UIStoryboardSegue) {
        if let newTransactionController = segue.source as? NewTransactionController {
            let itemDescription = newTransactionController.transactionDescription.text
            let knownPeer = newTransactionController.pickerData[newTransactionController.peerPicker.selectedRow(inComponent: 0)]
            let incomming = (newTransactionController.direction.selectedSegmentIndex == 0 ? true : false)
            let isMoney = (newTransactionController.belongings.selectedSegmentIndex == 0 ? true : false)
            
            var quantity = 0
            if (isMoney) {
//                let amount = newTransactionController.amount.text
                quantity = 1
            }
            else {
                quantity = Int(newTransactionController.quantity.text!)!
            }
            
            let transaction = ((UIApplication.shared.delegate as! AppDelegate).dataController?.storeNewTransaction(
                itemDescription: itemDescription!,
                peer: knownPeer,
                incoming: incomming,
                isMoney: isMoney,
                quantity: UInt(quantity),
                category: nil,
                dueDate: nil,
                imageURL: nil,
                dueWhenTransactionIsDue: nil))
            
            transactions.insert(transaction!, at: 0)     //.append(test!)
            
            //            print(test?.itemDescription ?? "No Transaction")
        }
        
        preFilterContent(scope: preFilter.selectedSegmentIndex)
    }
    
    @IBAction func preFilterChanged(_ sender: UISegmentedControl) {
        preFilterContent(scope: sender.selectedSegmentIndex)
    }
    
    
    
    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    
    var transactions = [Transaction]()
    var preFilterdTransactions = [Transaction]()
    var filteredTransactions = [Transaction]()
    

    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.scopeButtonTitles = ["All", "Loan", "Debt", "Past"]
//        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        
//        searchController.searchResultsUpdater = self
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.sizeToFit()
//        self.tableView.tableHeaderView = searchController.searchBar
        
        transactions = ((UIApplication.shared.delegate as! AppDelegate).dataController?.fetchTransactions())!
        // Sorting transcactions by startDate, so that the newest commes first
        // https://stackoverflow.com/questions/26577496/how-do-i-sort-a-swift-array-containing-instances-of-nsmanagedobject-subclass-by
        transactions.sort(by: {($0.startDate as! Date) > ($1.startDate as! Date)})
        
        preFilterContent(scope: 0)
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTransactions.count
        }
        return preFilterdTransactions.count
    }
    
 
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath)
//        cell.textLabel?.text = descriptions[indexPath.item]
//        cell.detailTextLabel?.text = peers[indexPath.item]
//        cell.im.imageView = Assets
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath)
        let transaction: Transaction
        if searchController.isActive && searchController.searchBar.text != "" {
            transaction = filteredTransactions[indexPath.row]
        } else {
            transaction = preFilterdTransactions[indexPath.row]
        }
        cell.textLabel?.text = transaction.itemDescription
        cell.detailTextLabel?.text = transaction.peer?.customName
        
        if (transaction.incoming) {
            cell.imageView?.image = UIImage(named: "in")
        }else{
            cell.imageView?.image = UIImage(named: "out")
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "TransactionDetailViewController", sender: indexPath)
//    }
   
    
    
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
    
    // MARK: - UISearchResultsUpdating
    @available(iOS 8.0, *)
    public func updateSearchResults(for searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
//    }
    
    func preFilterContent(scope: Int) {
        preFilterdTransactions = transactions.filter { transaction in
            var categoryMatch = false
            
            if scope == 1 {
                categoryMatch = transaction.incoming
            }
            else if scope == 2 {
                categoryMatch = !transaction.incoming
            }
            else if scope == 3 {
                categoryMatch = transaction.returnDate is Date
            }
            else {
                categoryMatch = true
            }
            
            return categoryMatch
        }
        
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredTransactions = preFilterdTransactions.filter { transaction in
//            var categoryMatch = false
//            
//            if scope == "Loan" {
//                categoryMatch = transaction.incoming
//            }
//            else if scope == "Debt" {
//                categoryMatch = !transaction.incoming
//            }
//            else if scope == "Past" {
//                categoryMatch = false
//            }
//            else {
//                categoryMatch = true
//            }
            
//            return categoryMatch && ((transaction.itemDescription?.lowercased().contains(searchText.lowercased()))! || (transaction.peer?.customName!.lowercased().contains(searchText.lowercased()))!)
            
            return ((transaction.itemDescription?.lowercased().contains(searchText.lowercased()))! || (transaction.peer?.customName!.lowercased().contains(searchText.lowercased()))!)
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let transaction: Transaction
                if searchController.isActive && searchController.searchBar.text != "" {
                    transaction = filteredTransactions[indexPath.row]
                } else {
                    transaction = preFilterdTransactions[indexPath.row]
                }
                let controller = segue.destination as! TransactionDetailViewController
                controller.transaction = transaction
                //controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                //controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}
