//
//  Qas_DevelopUITests.swift
//  Qas-DevelopUITests
//
//  Created by tenma on 2018/04/03.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest

class Qas_DevelopUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        sleep(5)
        if app.keyboards.count > 0 {
            app.keys["A"].tap()
            app.keys["a"].tap()
            app.keys["a"].tap()
            app.buttons["Search"].tap()
            sleep(6)
    //        waitForExpectations(timeout: 5, handler: nil)
            let launguageLink = app.links.element(boundBy: 1)
            launguageLink.tap()
        }
        app.links.element(boundBy: 30).tap()
//        app.links["WAY OF GLORY"].tap()
        sleep(6)
    }
    
}
