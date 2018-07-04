//
//  UserAccount.swift
//  EA Center
//
//  Created by Tom Shen on 2018/7/4.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

class UserAccount: NSObject {
    var userID: Int
    var username: String
    var userEmail: String
    var accountType: Int
    var grade: Int
    var classInitial: String
    var isManager: Bool
    /*
    init(userID: Int, username: String, userEmail: String, accountType: Int) {
        self.userID = userID
        self.username = username
        self.userEmail = userEmail
        self.accountType = accountType
        super.init()
    }
    */
    init(dictionary: [String:Any]) {
        self.userID = dictionary["id"] as! Int
        self.username = dictionary["username"] as? String ?? ""
        self.userEmail = dictionary["email"] as! String
        self.accountType = dictionary["type"] as! Int
        self.grade = dictionary["grade"] as? Int ?? 0
        self.classInitial = dictionary["classinitial"] as? String ?? ""
        self.isManager = dictionary["ismanager"] as! Bool
        super.init()
    }
    
    func updateInfo(_ newUsername: String, _ newGrade: Int, _ newClass: String, _ completion: @escaping (_ success: Bool, _ errString: String?) -> ()) {
        self.username = newUsername
        self.grade = newGrade
        self.classInitial = newClass
        
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
