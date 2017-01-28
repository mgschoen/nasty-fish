//
//  TransactionsViewController.swift
//  nasty-fish
//
//  Created by Manuel Hartmann on 04.12.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import UIKit
import CoreData

class TransactionsController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, AlertHelperProtocol {
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var preFilter: UISegmentedControl!
    
    
    // MARK: - @IBAction
    
    @IBAction func cancelToTransactions(segue:UIStoryboardSegue) {
    }
    
    @IBAction func saveNewTransaction(segue:UIStoryboardSegue) {
        // Now done by notification and TransactionManager
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
    
    
    // MARK: - Variable
    
    // https://www.raywenderlich.com/113772/uisearchcontroller-tutorial
    let searchController = UISearchController(searchResultsController: nil)
    
    var transactions = [Transaction]()
    var preFilterdTransactions = [Transaction]()
    var filteredTransactions = [Transaction]()
    var alert: UIAlertController?
    

    // MARK: - Default override
    
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
        
        // Observe listen for transactionRequestNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionRequestNotification),
                                               name: .transactionRequestNotification,
                                               object: nil)
        
        // Observe listen for transactionReplyNotification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.actOnTransactionReplyNotification),
                                               name: .transactionReplyNotification,
                                               object: nil)
        
        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // only needed for debug data remove in releas version
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
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
                let controller = segue.destination as! DetailTransactionViewController
                controller.transaction = transaction
                
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
            
            if scope == 0 {
                categoryMatch = transaction.returnDate == nil
            }
            else if scope == 1 {
                categoryMatch = transaction.returnDate == nil && !transaction.incoming
            }
            else if scope == 2 {
                categoryMatch = transaction.returnDate == nil && transaction.incoming
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
    
    func actOnTransactionReplyNotification(_ notification: NSNotification) {
        if let transaction = (notification.userInfo?["TransactionMessage"] as? TransactionMessage) {
            if transaction.status == MessageStatus.accepted.rawValue {
                DispatchQueue.main.async(execute: {
                    self.fetchData()
                })
            }
        }
    }

    func actOnTransactionRequestNotification(_ notification: NSNotification) {
        if let transaction = (notification.userInfo?["TransactionMessage"] as? TransactionMessage) {
            
            if transaction.type == MessageType.create.rawValue {
                alert = AlertHelper.getAcceptTransactionAlert(transaction: transaction)
                self.present(alert!, animated: true, completion: nil)
            }
            
            if transaction.type == MessageType.close.rawValue {
                alert = AlertHelper.getCloseTransactionAlert(transaction: transaction)
                self.present(alert!, animated: true, completion: nil)
            }
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
    
    func hideAlert() {
        if alert != nil {
            print("[TransactionsController] hideAlert()")
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
                self.alert = nil
            })
        }
    }
}
