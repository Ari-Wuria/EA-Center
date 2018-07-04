//
//  EnrichmentActivity.swift
//  EA Center Mac
//
//  Created by Tom Shen on 2018/6/25.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

class EnrichmentActivity: NSObject {
    var id: Int
    var name: String
    var shortDescription: String
    var location: String
    var days: [Int]
    var weekMode: Int
    var timeMode: Int
    var minGrade: Int
    var maxGrade: Int
    var proposal: String
    var leaderEmails: [String]
    var supervisorEmails: [String]
    var approved: Bool
    
    override init() {
        // Placeholder
        id = 0
        name = ""
        shortDescription = ""
        location = ""
        days = []
        weekMode = 0
        timeMode = 0
        minGrade = 0
        maxGrade = 0
        proposal = ""
        leaderEmails = []
        supervisorEmails = []
        approved = false
        super.init()
    }
    
    init(dictionary: [String:Any]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        shortDescription = dictionary["shortdesc"] as? String ?? ""
        location = dictionary["location"] as? String ?? ""
        days = (dictionary["days"] as? String)?.split(separator: ",").map{Int($0)} as? [Int] ?? []
        weekMode = dictionary["weekmode"] as? Int ?? 0
        timeMode = dictionary["timemode"] as? Int ?? 0
        minGrade = dictionary["mingrade"] as? Int ?? 0
        maxGrade = dictionary["maxgrade"] as? Int ?? 0
        proposal = dictionary["proposal"] as? String ?? ""
        leaderEmails = (dictionary["leaderemail"] as? String)?.split(separator: ",").map{String($0)} ?? []
        supervisorEmails = (dictionary["supervisoremail"] as? String)?.split(separator: ",").map{String($0)} ?? []
        approved = dictionary["approved"] as? Bool ?? false
        super.init()
    }
    
    func timeModeForDisplay() -> String {
        switch timeMode {
        case 1:
            return "3:30 - 4:30"
        case 2:
            return "4:30 - 5:30"
        case 3:
            return "3:30 - 5:30"
        default:
            return "Invalid Timemode"
        }
    }
}
