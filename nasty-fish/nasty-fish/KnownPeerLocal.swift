//
//  KnownPeerLocal.swift
//  nasty-fish
//
//  Created by Martin Schön on 18.11.16.
//  Copyright © 2016 Gruppe 08. All rights reserved.
//

import Foundation

class KnownPeerLocal : NSObject {
    
    let icloudID : String
    var customName : String?
    var transactions : NSArray

    init (icloudID: String, customName: String?) {
        self.icloudID = icloudID
        if (customName != nil) {
            self.customName = customName
        }
        self.transactions = NSArray()
    }
    
}
