//
//  TransactionsViewController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 04.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit
import CoreData

class TransactionsController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    
    @IBOutlet weak var preFilter: UISegmentedControl!
    
    // MARK: - @IBAction
    @IBAction func cancelToTransactions(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveNewTransaction(segue:UIStoryboardSegue) {
        // Now done by notification and TransactionManager
        
//        if let controller = segue.source as? NewTransactionController {
////            let transaction = ((UIApplication.shared.delegate as! AppDelegate).dataController?.storeNewTransaction(
////                itemDescription: newTransaction.transactionDescription,
////                peer: newTransaction.peer,
////                incoming: newTransaction.isIncomming,
////                isMoney: newTransaction.isMoney,
////                quantity: (newTransaction.isMoney ? newTransaction.amount : newTransaction.quantity ),
////                category: nil,
////                dueDate: nil,
////                imageURL: nil,
////                dueWhenTransactionIsDue: nil))
//            
//            if let transaction = controller.savedTransaction {
//                transactions.insert(transaction, at: 0)
//            }
//        }
//        
//        preFilterContent(scope: preFilter.selectedSegmentIndex)
    }
    
    @IBAction func deleteTransaction (segue: UIStoryboardSegue) {
//        if let detailController = segue.source as? DetailTransactionViewController {
//            
//            let dc = (UIApplication.shared.delegate as! AppDelegate).dataController!
//            
//            dc.delete(transaction: detailController.transaction!)
//            
//            fetchData()
//        }
    }
    
    @IBAction func preFilterChanged(_ sender: UISegmentedControl) {
        preFilterContent(scope: sender.selectedSegmentIndex)
    }
    
    
    // MARK: - Variables
    
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
        definesPresentationContext = true
        searchController.searchBar.delegate = self;
        tableView.tableHeaderView = searchController.searchBar
        
//        searchController.searchResultsUpdater = self
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.searchBar.sizeToFit()
//        self.tableView.tableHeaderView = searchController.searchBar
        
        
        // Register to receive notification
        
        // Observe listen for transactionSavedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionSavedNotification),
                                               name: .transactionSavedNotification,
                                               object: nil)
        
        // Observe listen for transactionClosedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionClosedNotification),
                                               name: .transactionClosedNotification,
                                               object: nil)
        
        // Observe listen for transactionSavedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnCreateTransactionNotification),
                                               name: .createTransactionNotification,
                                               object: nil)
        
        // Observe listen for transactionSavedNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnCloseTransactionNotification),
                                               name: .closeTransactionNotification,
                                               object: nil)
        
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
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
            cell.imageView?.image = #imageLiteral(resourceName: "InFish") // Magic foo don't need to write UIImage(named: "InFish")
        }else{
            cell.imageView?.image = #imageLiteral(resourceName: "OutFish")
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
                //                let controller = segue.destination as! DetailTransactionViewController
                //                controller.transaction = transaction
                
                //controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                //controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
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
            return ((transaction.itemDescription?.lowercased().contains(searchText.lowercased()))! || (transaction.peer?.customName!.lowercased().contains(searchText.lowercased()))!)
        }
        
        tableView.reloadData()
    }
    
    
    // MARK: - Notification
    
    func actOnTransactionSavedNotification(_ notification: NSNotification) {
        if (notification.userInfo?["isCreated"] as! Bool) {
            fetchData()
        }
    }
    
    func actOnTransactionClosedNotification(_ notification: NSNotification) {
        if (notification.userInfo?["isClosed"] as! Bool) {
            fetchData()
        }
    }
    
    func actOnCreateTransactionNotification(_ notification: NSNotification) {
        if let transaction = (notification.userInfo?["transaction"] as? TransactionData) {
            showAcceptTransactionAlert(transaction: transaction)
        }
    }
    
    func actOnCloseTransactionNotification(_ notification: NSNotification) {
        if let transaction = (notification.userInfo?["transaction"] as? Transaction) {
            showCloseTransactionAlert(transaction: transaction)
        }
    }
    
    
    // MARK: - Helper
    
    func fetchData() {
        transactions = (UIApplication.shared.delegate as! AppDelegate).dataController!.fetchTransactions()
        
        // Sorting transcactions by startDate, so that the newest commes first
        // https://stackoverflow.com/questions/26577496/how-do-i-sort-a-swift-array-containing-instances-of-nsmanagedobject-subclass-by
        transactions.sort(by: {($0.startDate as! Date) > ($1.startDate as! Date)})
        
        preFilterContent(scope: preFilter.selectedSegmentIndex)
    }
    
    func showAcceptTransactionAlert(transaction: TransactionData) {
        let alert = UIAlertController(title: "Accept Transaction?",
                                      message: "\(transaction.senderName) wants to send you the transaction:\n\(transaction.transactionDescription)\n\nDo you accept it?",
                                      preferredStyle: .alert)
    
        let noAction = UIAlertAction(title: "No",
                                     style: .cancel,
                                     handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.receiveAndProcess(create: transaction, accepted: false)
        })
    
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.receiveAndProcess(create: transaction, accepted: true)
        })
    
    
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCloseTransactionAlert(transaction: Transaction) {
        let alert = UIAlertController(title: "Close Transaction?",
                                      message: "\(transaction.peer?.customName) wants to close the transaction:\n\(transaction.itemDescription)\n\nDo you accept that?",
                                      preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No",
                                     style: .cancel,
                                     handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.receiveAndProcess(close: transaction, accepted: false)
        })
        
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.receiveAndProcess(close: transaction, accepted: true)
        })
        
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
    }
}
