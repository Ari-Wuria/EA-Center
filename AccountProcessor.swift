//
//  AccountProcessor.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/30.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

class AccountProcessor {
    class func sendLoginRequest(_ email: String, _ passEnc: String, _ completion: @escaping (_ success: Bool, _ errorCode: Int?, _ errorMsg: String?) -> ()) {
        let urlString = MainServerAddress + "/login/login.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "login=1&email=\(email)&password=\(passEnc)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, -1, error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                DispatchQueue.main.async {
                    completion(false, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //print("No JSON data")
                DispatchQueue.main.async {
                    completion(false, -3, "No JSON Data")
                }
                return
            }
            
            let failure = responseDict["failure"] as! Bool
            if failure == true {
                // Fail
                let reason = responseDict["error"] as! Int
                var reasonString: String = "Unknown Reason"
                if reason == 1 {
                    //self.verifyLabel.stringValue = "Wrong Password"
                    reasonString = "Wrong Password"
                } else if reason == 2 {
                    //self.verifyLabel.stringValue = "Did you forget to activate?"
                    reasonString = "Did you forgot to activate?"
                } else if reason == 3 {
                    //self.verifyLabel.stringValue = "Please register first"
                    reasonString = "Please register first"
                }
                DispatchQueue.main.async {
                    completion(false, reason, reasonString)
                }
                return
            }
            
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    // We will use the errorCode variable to pass the user id
                    let userID = responseDict["userid"] as! Int
                    completion(true, userID, nil)
                }
            }
        }
        dataTask.resume()
    }
    
    class func encrypt(_ str: String) -> String? {
        return aesEncrypt(str, GlobalAESKey, GlobalAESIV)
    }
    
    class func validateEmail(_ str: String) -> Bool {
        if isValidEmail(str) && isBCISEmail(str) {
            return true
        }
        return false
    }
    
    class func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    class func isBCISEmail(_ testStr: String) -> Bool {
        if testStr.hasSuffix("@mybcis.cn") || testStr.count == 20 {
            return true
        }
        
        if testStr.hasSuffix("@bcis.cn") {
            return true
        }
        
        return false
    }
    
    class func retriveUserAccount(from userID: Int, completion: @escaping (_ account: UserAccount?, _ errorCode: Int?, _ errorString: String?) -> ()) {
        let urlString = MainServerAddress + "/accountfromid.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "inputid=\(userID)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, -1, error!.localizedDescription)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                DispatchQueue.main.async {
                    completion(nil, -2, "Wrong Status Code: \(httpResponse.statusCode)")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //print("No JSON data")
                DispatchQueue.main.async {
                    completion(nil, -3, "No JSON Data")
                }
                return
            }
            
            let userAccount = UserAccount(dictionary: responseDict)
            DispatchQueue.main.async {
                completion(userAccount, nil, nil)
            }
        }
        dataTask.resume()
    }
    
    class func name(from email: String, completion: @escaping (_ name: String?) -> ()) {
        let urlString = MainServerAddress + "/namefromemail.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(email)"
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!)
            guard jsonData is [String:Any] else {
                // No name, return name not set
                DispatchQueue.main.async {
                    completion("")
                }
                return
            }
            
            let responseDict = jsonData as! [String:Any]
            
            let name = responseDict["name"] as? String
            if name != nil {
                DispatchQueue.main.async {
                    completion(name)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
}
