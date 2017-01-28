//
//  AlertHelper.swift
//  nasty-fish
//
//  Created by Martin Schön on 28.01.17.
//  Copyright © 2017 Gruppe 08. All rights reserved.
//

import Foundation
import UIKit

protocol AlertHelperProtocol {
    var alert:UIAlertController? {get set}
    func hideAlert()
}

class AlertHelper : NSObject {
    
    // http://stackoverflow.com/a/40570379/3309527
    static func getWaitAlert(title: String) -> UIAlertController {
        
        let sendAlert = UIAlertController(title: title, message: " ", preferredStyle: .alert)
        
        sendAlert.addAction(UIAlertAction(title: "Cancel",
                                          style: UIAlertActionStyle.cancel,
                                          handler: nil))
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        sendAlert.view.addSubview(activityIndicator)
        
        let xConstraint = NSLayoutConstraint(item: activityIndicator,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: sendAlert.view,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: sendAlert.view,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0)
        
        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        return sendAlert
        
    }
    
    static func getAcceptTransactionAlert(transaction: TransactionMessage) -> UIAlertController {
        
        let alert = UIAlertController(title: "Accept Transaction?",
                                      message: "\(transaction.senderName) wants to send you the transaction:\n\(transaction.transactionDescription)\n\nDo you accept it?",
            preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No",
                                     style: .cancel,
                                     handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.process(received: transaction, accepted: false)
        })
        
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.process(received: transaction, accepted: true)
        })
        
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        return alert
        
    }
    
    static func getCloseTransactionAlert(transaction: TransactionMessage) -> UIAlertController {
        let alert = UIAlertController(title: "Close Transaction?",
                                      message: "\(transaction.senderName) wants to close the transaction:\n\(transaction.transactionDescription)\n\nDo you accept that?",
            preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No",
                                     style: .cancel,
                                     handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.process(received: transaction, accepted: false)
        })
        
        let yesAction = UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: {
                                        (_)in
                                        (UIApplication.shared.delegate as! AppDelegate).transactionManager?.process(received: transaction, accepted: true)
        })        
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        return alert
    }
    
    static func getCustomAlert (title: String, message: String, buttonLabel: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonLabel, style: .default, handler: nil))
        return alert
    }
}
