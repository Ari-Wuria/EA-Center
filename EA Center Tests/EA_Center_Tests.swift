//
//  EA_Center_Tests.swift
//  EA Center Tests
//
//  Created by Tom Shen on 2018/8/7.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import XCTest
@testable import EA_Center

class EA_Center_Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
/*
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    */
    func testRetrivingEAs() {
        // Modified version of downloadEAList()
        let urlString = MainServerAddress + "/manageea/getealist.php"
        let url = URL(string: urlString)!
        
        let session = URLSession.shared
        var eaList = [EnrichmentActivity]()
        
        let promise = expectation(description: "EA Download Success")
        let dataTask = session.dataTask(with: url) { (data, urlReponse, error) in
            guard error == nil else {
                // Can't download with an error
                //print("Error: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    XCTFail("Can not download with error: \(error!)")
                }
                return
            }
            
            let httpResponse = urlReponse as? HTTPURLResponse
            guard httpResponse?.statusCode == 200 else {
                // Wrong response code
                //print("Response code not 200")
                DispatchQueue.main.async {
                    XCTFail("Not a 200 response from server \(httpResponse!.statusCode)")
                }
                return
            }
            
            let responseDict = try! JSONSerialization.jsonObject(with: data!) as? [String:AnyObject]
            guard let response = responseDict else {
                // Not a dictionary or it doesn't exist
                //print("Not a dictionary")
                DispatchQueue.main.async {
                    XCTFail("No JSON data")
                }
                return
            }
            
            let eaArray = response["allea"] as! [[String:AnyObject]]
            for eaDictionary in eaArray {
                let enrichmentActivity = EnrichmentActivity(dictionary: eaDictionary)
                eaList.append(enrichmentActivity)
            }
            // Success!
            promise.fulfill()
        }
        dataTask.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
    }

}
