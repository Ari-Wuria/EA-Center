//
//  EnrichmentActivity.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Cocoa

class EnrichmentActivity: NSObject {
    var id: Int
    var name: String
    var shortDescription: String
    
    init(dictionary: [String:AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        shortDescription = dictionary["shortdesc"] as! String
    }
}
