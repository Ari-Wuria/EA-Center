//
//  EA_Center_UI_Tests.swift
//  EA Center UI Tests
//
//  Created by Tom Shen on 2018/8/7.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import XCTest

class EA_Center_UI_Tests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
/*
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
*/
    func testViewingTabs() {
        // Test tapping on all tabs
        let tabBarsQuery = XCUIApplication().tabBars
        let allEasButton = tabBarsQuery.buttons["All EAs"]
        let myEasButton = tabBarsQuery.buttons["My EAs"]
        let meButton = tabBarsQuery.buttons["Me"]
        myEasButton.tap()
        meButton.tap()
        myEasButton.tap()
        allEasButton.tap()
        myEasButton.tap()
        meButton.tap()
        myEasButton.tap()
        allEasButton.tap()
    }
    
    func testViewingDescription() {
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Test EA 3"]/*[[".cells.staticTexts[\"Test EA 3\"]",".staticTexts[\"Test EA 3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Test EA 3"].buttons["All EAs"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Test EA 1"]/*[[".cells.staticTexts[\"Test EA 1\"]",".staticTexts[\"Test EA 1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Test EA 1"].buttons["All EAs"].tap()
    }
    
    func testSwipingTextView() {
        let app = XCUIApplication()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Test EA 1"]/*[[".cells.staticTexts[\"Test EA 1\"]",".staticTexts[\"Test EA 1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView/*@START_MENU_TOKEN@*/.swipeUp()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        textView.swipeDown()
        textView.swipeUp()
        textView.swipeDown()
        app.navigationBars["Test EA 1"].buttons["All EAs"].tap()
    }
}
