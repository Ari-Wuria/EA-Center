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
    var approved: Int
    var categoryID: Int
    var startDate: Date?
    var endDate: Date?
    
    override init() {
        // Initialize with default values
        id = 0
        name = ""
        shortDescription = ""
        location = ""
        days = []
        weekMode = 1
        timeMode = 1
        minGrade = 6
        maxGrade = 12
        proposal = ""
        leaderEmails = []
        supervisorEmails = []
        approved = 0
        categoryID = 0
        //startDate = Date()
        //endDate = Date()
        super.init()
    }
    
    init(dictionary: [String:Any]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        shortDescription = dictionary["shortdesc"] as? String ?? ""
        location = dictionary["location"] as? String ?? ""
        days = (dictionary["days"] as? String)?.split(separator: ",").map{Int($0)} as? [Int] ?? []
        weekMode = dictionary["weekmode"] as? Int ?? 1
        timeMode = dictionary["timemode"] as? Int ?? 1
        minGrade = dictionary["mingrade"] as? Int ?? 6
        maxGrade = dictionary["maxgrade"] as? Int ?? 12
        proposal = dictionary["proposal"] as? String ?? ""
        
        // Split the leaders
        leaderEmails = (dictionary["leaderemail"] as? String)?.split(separator: ",").map{String($0)} ?? []
        supervisorEmails = (dictionary["supervisoremail"] as? String)?.split(separator: ",").map{String($0)} ?? []
        
        approved = dictionary["approved"] as? Int ?? 0
        categoryID = dictionary["category"] as? Int ?? 0
        
        // Start date and end date is optional
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        startDate = dateFormatter.date(from: dictionary["startdate"] as? String ?? "")
        endDate = dateFormatter.date(from: dictionary["enddate"] as? String ?? "")
        
        super.init()
    }
    
    /// Create a new EA and add it to database with default values
    /// @param name: Name of EA
    class func create(withName name: String, email leaderEmail: String, completion: @escaping (_ success: Bool, _ ea: EnrichmentActivity?, _ errStr: String?) -> ()) {
        // Experimenting with hash API protection
        let hashiv = randomAlphanumericString(length: 16)
        let hashEncrypted = aesEncrypt(GlobalAPIHash, GlobalAPIEncryptKey, hashiv)!
        
        //print("Hash: \(hashEncrypted), iv: \(hashiv)")
        
        let urlString = MainServerAddress + "/manageea/createea"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "name=\(name)&email=\(leaderEmail)&hash=\(hashEncrypted)&hashkey=\(hashiv)"
        request.httpBody = postString.data(using: .utf8)
        
        // Temporary
        //URLCache.shared.removeAllCachedResponses()
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, nil, error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                DispatchQueue.main.async {
                    completion(false, nil, "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //print("No JSON data")
                DispatchQueue.main.async {
                    completion(false, nil, "No JSON Data")
                }
                return
            }
            
            let success = responseDict["success"] as! Bool
            DispatchQueue.main.async {
                if success {
                    let resultID = responseDict["resultid"] as! Int
                    let newEA = EnrichmentActivity()
                    newEA.id = resultID
                    newEA.name = name
                    newEA.leaderEmails = [leaderEmail]
                    completion(true, newEA, nil)
                } else {
                    let errString = responseDict["error"] as! String
                    completion(false, nil, errString)
                }
            }
        }
        dataTask.resume()
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
    
    func weekModeForDisplay() -> String {
        switch weekMode {
        case 1:
            return "Every Week"
        case 2:
            return "Every 2 Weeks"
        case 3:
            return "Every Month"
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
    
    func updateShortDesc(newShortDesc: String, completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let urlString = MainServerAddress + "/updateeadesc.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "updateea=1&id=\(id)&shortdesc=\(newShortDesc)"
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
                    self.shortDescription = newShortDesc
                    
                    completion(true, nil)
                } else {
                    let errString = responseDict["error"] as! String
                    completion(false, errString)
                }
            }
        }
        dataTask.resume()
    }
    
    func updateProposal(newProposal: String, completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let urlString = MainServerAddress + "/updateeadesc.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "updateea=2&id=\(id)&proposal=\(newProposal)"
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
                    self.proposal = newProposal
                    
                    completion(true, nil)
                } else {
                    let errString = responseDict["error"] as! String
                    completion(false, errString)
                }
            }
        }
        dataTask.resume()
    }
    
    func updateLeader(newLeader: UserAccount, isSupervisor: Bool, completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let supervisor = (isSupervisor) ? 1 : 0
        let newEmail = newLeader.userEmail
        let newEmailString: String
        if supervisor == 0 {
            // Leader email count will never be 0
            newEmailString = leaderEmails.joined(separator: ",") + ",\(newEmail)"
        } else {
            if supervisorEmails.count == 0 {
                newEmailString = newEmail
            } else {
                newEmailString = supervisorEmails.joined(separator: ",") + ",\(newEmail)"
            }
        }
        
        updateLeaderString(supervisor, newEmailString, completion)
    }
    
    func deleteLeader(email: String, isSupervisor: Bool, completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let supervisor = (isSupervisor) ? 1 : 0
        let newEmailString: String
        if supervisor == 0 {
            // Leader email count will never be 0
            //newEmailString = leaderEmails.joined(separator: ",") + ",\(newEmail)"
            let index = leaderEmails.firstIndex(of: email)!
            var copy = leaderEmails
            copy.remove(at: index)
            newEmailString = copy.joined(separator: ",")
        } else {
            let index = supervisorEmails.firstIndex(of: email)!
            var copy = supervisorEmails
            copy.remove(at: index)
            newEmailString = copy.joined(separator: ",")
        }
        
        updateLeaderString(supervisor, newEmailString, completion)
    }
    
    private func updateLeaderString(_ isSupervisor: Int, _ leaderString: String, _ completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let urlString = MainServerAddress + "/updateealeader.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "id=\(id)&issupervisor=\(isSupervisor)&email=\(leaderString)"
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
                    if isSupervisor == 1 {
                        self.supervisorEmails = leaderString.split(separator: ",").map{String($0)}
                    } else {
                        self.leaderEmails = leaderString.split(separator: ",").map{String($0)} 
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
    
    func checkOwner(_ validateEmail: String) -> Bool {
        // TODO: Check online too!
        if leaderEmails.contains(validateEmail) || supervisorEmails.contains(validateEmail) {
            return true
        } else {
            return false
        }
    }
}
