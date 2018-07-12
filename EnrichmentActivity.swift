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
        
        // Split the leaders
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
    
    func updateDetail(newWeekMode: Int, newTimeMode: Int, newLocation: String, newMinGrade: Int, newMaxGrade: Int, newShortDesc: String?, newProposal: String?, newDays: String, completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let urlString = MainServerAddress + "/updateeainfo.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        var postString = "updateea=1&id=\(self.id)&weekmode=\(newWeekMode)&timemode=\(newTimeMode)&location=\(newLocation)&mingrade=\(newMinGrade)&maxgrade=\(newMaxGrade)&days=\(newDays)"
        if newShortDesc != nil {
            postString += "&shortdesc=\(newShortDesc!)"
        }
        if newProposal != nil {
            postString += "&proposal=\(newProposal!)"
        }
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                DispatchQueue.main.async {
                    completion(false, "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //print("No JSON data")
                DispatchQueue.main.async {
                    completion(false, "No JSON Data")
                }
                return
            }
            
            let success = responseDict["success"] as! Bool
            DispatchQueue.main.async {
                if success {
                    self.weekMode = newWeekMode
                    self.timeMode = newTimeMode
                    self.location = newLocation
                    self.minGrade = newMinGrade
                    self.maxGrade = newMaxGrade
                    self.days = newDays.split(separator: ",").map{Int($0)} as? [Int] ?? []
                    if newShortDesc != nil {
                        self.shortDescription = newShortDesc!
                    }
                    if newProposal != nil {
                        self.proposal = newProposal!
                    }
                    
                    completion(true, nil)
                } else {
                    let errString = responseDict["error"] as! String
                    completion(false, errString)
                }
            }
        }
        dataTask.resume()
    }
}
