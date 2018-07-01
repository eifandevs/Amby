//
//  Qass_DevelopUITests.swift
//  Qass-DevelopUITests
//
//  Created by tenma on 2018/04/03.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import XCTest
import UIKit

@testable import Qass_Develop

class Qass_DevelopUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        Springboard.deleteMyApp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testScenario() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        app = XCUIApplication()

        // キーボードの表示を待つ
        waitExist(element: app.keyboards.firstMatch)
        XCTAssertTrue(app.keys["A"].exists) // 英語キーボードのみ

        // ----- 検索 -----
        do {
            app.keys["A"].tap()
            app.keys["m"].tap()
            app.keys["a"].tap()
            app.keys["z"].tap()
            app.keys["o"].tap()
            app.keys["n"].tap()
            app.buttons["Search"].tap()

            // 初回google検索結果表示時は、言語設定のモーダルが表示されるので、それを待つ
            waitExist(element: app.links["Change to English"])
            app.links["Change to English"].tap()

            // ----- 適当にリンクタップ -----
            app.links["Welcome to Prime Video"].tap()
            waitExist(element: app.links["Help"])
        }
        
        // ----- ヒストリーバック -----
        do {
            let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            let coord2 = coord1.withOffset(CGVector(dx: coord1.screenPoint.x + 40, dy: 0))
            coord1.press(forDuration: 0.1, thenDragTo: coord2)
            waitExist(element: app.links["Welcome to Prime Video"])
        }

        // ----- ヒストリーフォワード -----
        do {
            let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0))
            let coord2 = coord1.withOffset(CGVector(dx: 0.99, dy: 0))
            coord1.press(forDuration: 0.1, thenDragTo: coord2)
            waitExist(element: app.links["Help"])
        }
    }

    private func waitExist(element: XCUIElement) {
        let notExists = NSPredicate(format: "exists == true")
        expectation(for: notExists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 60, handler: nil)
        sleep(2)
    }

}
