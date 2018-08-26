//
//  UserAccount.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

class UserAccount: NSObject, Codable {
    var userID: Int = 0
    var username: String = ""
    var userEmail: String = ""
    var accountType: Int = 0
    var grade: Int = 0
    var classInitial: String = ""
    var isManager: Bool = false
    
    override var description: String {
        return "User Account (id: \(userID), email: \(userEmail))"
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "id"
        //case username
        case userEmail = "email"
        case accountType = "type"
        //case grade
        case classInitial = "classinitial"
        case isManager = "ismanager"
        case username, grade
    }
    
    required init(from decoder: Decoder) throws {
        let decodeContainer = try decoder.container(keyedBy: CodingKeys.self)
        userID = try decodeContainer.decode(Int.self, forKey: .userID)
        username = try decodeContainer.decode(String.self, forKey: .username)
        userEmail = try decodeContainer.decode(String.self, forKey: .userEmail)
        accountType = try decodeContainer.decode(Int.self, forKey: .accountType)
        grade = try decodeContainer.decode(Int.self, forKey: .grade)
        classInitial = try decodeContainer.decode(String.self, forKey: .classInitial)
        isManager = try decodeContainer.decode(Bool.self, forKey: .isManager)
    }
    
    init(dictionary: [String:Any]) {
        userID = dictionary["id"] as! Int
        username = dictionary["username"] as? String ?? ""
        userEmail = dictionary["email"] as! String
        accountType = dictionary["type"] as! Int
        grade = dictionary["grade"] as? Int ?? 0
        classInitial = dictionary["classinitial"] as? String ?? ""
        isManager = dictionary["ismanager"] as? Bool ?? false
        super.init()
    }
    
    func updateInfo(_ newUsername: String, _ newGrade: Int, _ newClass: String, _ completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        let urlString = MainServerAddress + "/updateaccountinfo.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "id=\(self.userID)&username=\(newUsername)&grade=\(newGrade)&classinitial=\(newClass)"
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
                    self.username = newUsername
                    self.grade = newGrade
                    self.classInitial = newClass
                    
                    completion(true, nil)
                } else {
                    let errString = responseDict["error"] as! String
                    completion(false, errString)
                }
            }
        }
        dataTask.resume()
    }
    
    func updatePassword(_ oldPassword: String, _ newPassword: String, _ completion: @escaping (_ success: Bool, _ errStr: String?) -> ()) {
        let urlString = MainServerAddress + "/login/changepass.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "changepass=1&email=\(userEmail)&password=\(oldPassword)&newpass=\(newPassword)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    if (error as! URLError).code == URLError.Code.notConnectedToInternet {
                        completion(false, "Please get on the internet.")
                    }
                    completion(false, "Error accessing server.")
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
                    completion(true, nil)
                } else {
                    let errCode = responseDict["error"] as! Int
                    var errString = ""
                    if errCode == 1 {
                        errString = "Wrong password."
                    } else if errCode == 2 {
                        errString = "Server error while updating."
                    }
                    completion(false, errString)
                }
            }
        }
        dataTask.resume()
    }
}
