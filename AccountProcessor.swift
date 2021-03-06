//
//  AccountProcessor.swift
//  EA Center
//
//  Created by Tom Shen on 2018/6/30.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import Foundation

class AccountProcessor {
    class func sendLoginRequest(_ email: String, _ passEnc: String, _  pushToken: String? = nil, _ deviceIdentifier: String? = nil, _ deviceName: String? = nil, _ completion: @escaping (_ success: Bool, _ errorCode: Int?, _ errorMsg: String?) -> ()) {
        let urlString = MainServerAddress + "/login/login.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // Split iOS and macOS code to support push notification (disable for simulator)
        #if os(iOS)
        #if !targetEnvironment(simulator)
        var postString = "login=1&email=\(email)&password=\(passEnc)&mobile=1"
        if let token = pushToken {
            postString.append(contentsOf: "&pushtoken=\(token)")
        }
        if let identifier = deviceIdentifier {
            postString.append(contentsOf: "&mobileidentifier=\(identifier)")
        }
        if let deviceName = deviceName {
            postString.append(contentsOf: "&mobilename=\(deviceName)")
        }
        #else
        let postString = "login=1&email=\(email)&password=\(passEnc)"
        #endif
        #elseif os(OSX)
        let postString = "login=1&email=\(email)&password=\(passEnc)"
        #endif
        
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
                    if let deviceID = responseDict["identifier"] {
                        if let deviceID = deviceID as? String {
                            if deviceID.count > 0 {
                                print("Received identifier: \(deviceID)")
                                let nameOfDevice = responseDict["devicename"] as! String
                                completion(true, userID, "device_id_received:\(deviceID):\(nameOfDevice)")
                            } else {
                                completion(true, userID, nil)
                            }
                        }
                    } else {
                        completion(true, userID, nil)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    class func sendLogoutRequest(_ userid: Int, _ completion: @escaping (_ success: Bool, _ errorMsg: String?) -> ()) {
        let urlString = MainServerAddress + "/login/logout.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let postString = "userid=\(userid)"
        
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
            
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } else {
                let errStr = responseDict["errStr"] as? String
                if let errStr = errStr {
                    DispatchQueue.main.async {
                        completion(false, errStr)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "No error message :(")
                    }
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
    
    class func isAlphanumeral(_ testStr: String) -> Bool {
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits
        
        if testStr.rangeOfCharacter(from: letters) != nil && testStr.rangeOfCharacter(from: digits) != nil {
            return true
        } else {
            return false
        }
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
            /*
            print("\(String(data: data!, encoding: .utf8))")
            // Experimenting with Swift JSONDecoder
            let decoder = JSONDecoder()
            do {
                //let result = try decoder.decode(UserAccount.self, from: data!)
                let result = try decoder.decode(UserAccount.self, from: data!)
                DispatchQueue.main.async {
                    completion(result, nil, nil)
                }
            } catch {
                //print("No JSON data")
                DispatchQueue.main.async {
                    completion(nil, -3, "No JSON Data\n" + error.localizedDescription)
                }
                return
            }
 */
            
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
    
    class func sendRegistrationData(_ email: String, _ encryptedPassword: String, _ accountType: Int, completion: @escaping (_ success: Bool, _ errStr: String) -> ()) {
        let urlString = MainServerAddress + "/login/register.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "register=1&type=\(accountType)&password=\(encryptedPassword)&email=\(email)"
        //let postStringEscaped = postString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        //request.httpBody = postStringEscaped?.data(using: .utf8)
        request.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                if (error as! URLError).code == URLError.Code.notConnectedToInternet {
                    //self.statusLabel.stringValue = "Please get on the internet"
                    completion(false, "Please get on the internet")
                } else {
                    //self.statusLabel.stringValue = "Register failed with error"
                    completion(false, "Register failed with error")
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                //self.statusLabel.stringValue = "Register failed: Wrong status code (\(httpResponse.statusCode))"
                completion(false, "Register failed: Wrong status code (\(httpResponse.statusCode))")
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //self.statusLabel.stringValue = "Register failed: No JSON data)"
                completion(false, "Register failed: No JSON data)")
                return
            }
            
            let failure = responseDict["failure"] as! Bool
            if failure == true {
                // Fail
                let reason = responseDict["error"] as! Int
                DispatchQueue.main.async {
                    if reason == 1 {
                        //self.statusLabel.stringValue = "Account already exist"
                        completion(false, "Account already exist")
                    } else if reason == 2 {
                        //self.statusLabel.stringValue = "Please activate account. Don't register again."
                        completion(false, "Please activate account. Don't register again.")
                    }
                    return
                }
            }
            
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    //let window = self.view.window?.windowController as! LoginWindowController
                    //window.registerFinished(withEmail: email)
                    completion(true, email)
                }
            }
        }
        dataTask.resume()
    }
    
    class func sendForgotPasswordRequest(_ email: String, _ encryptedPassword: String, completion: @escaping (_ success: Bool, _ errStr: String) -> ()) {
        let urlString = MainServerAddress + "/login/forgotpass.php"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "forgot=1&password=\(encryptedPassword)&email=\(email)"
        //let postStringEscaped = postString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        //request.httpBody = postStringEscaped?.data(using: .utf8)
        request.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                //print("Error: \(error!.localizedDescription)")
                if (error as! URLError).code == URLError.Code.notConnectedToInternet {
                    //self.statusLabel.stringValue = "Please get on the internet"
                    DispatchQueue.main.async {
                        completion(false, "Please get on the internet")
                    }
                } else {
                    //self.statusLabel.stringValue = "Register failed with error"
                    DispatchQueue.main.async {
                        completion(false, "Reset failed with an error")
                    }
                }
                return
            }
            
            let httpResponse = response as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                //print("Wrong Status Code")
                //self.statusLabel.stringValue = "Register failed: Wrong status code (\(httpResponse.statusCode))"
                DispatchQueue.main.async {
                    completion(false, "Reset failed: Wrong status code (\(httpResponse.statusCode))")
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
            guard let responseDict = jsonData else {
                //self.statusLabel.stringValue = "Register failed: No JSON data)"
                DispatchQueue.main.async {
                    completion(false, "Reset failed: No JSON data)")
                }
                return
            }
            /*
            let failure = responseDict["failure"] as! Bool
            if failure == true {
                // Fail
                let reason = responseDict["error"] as! Int
                DispatchQueue.main.async {
                    if reason == 1 {
                        //self.statusLabel.stringValue = "Account already exist"
                        completion(false, "Account already exist")
                    } else if reason == 2 {
                        //self.statusLabel.stringValue = "Please activate account. Don't register again."
                        completion(false, "Please activate account. Don't register again.")
                    }
                    return
                }
            }
            */
            let success = responseDict["success"] as? Bool
            if success == true {
                DispatchQueue.main.async {
                    //let window = self.view.window?.windowController as! LoginWindowController
                    //window.registerFinished(withEmail: email)
                    completion(true, email)
                }
            } else {
                DispatchQueue.main.async {
                    //let window = self.view.window?.windowController as! LoginWindowController
                    //window.registerFinished(withEmail: email)
                    let errStr = responseDict["errorString"]
                    completion(false, errStr as! String)
                }
            }
        }
        dataTask.resume()
    }
}
